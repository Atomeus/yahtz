local Jokers = require("game.jokers")
local Scoring = require("scoring")
local Session = require("game.session")
local Summary = require("game.results_summary")
local Lines = require("game.lines")

local seen = {}
for seed = 1, 200 do
  local choices, unique = Jokers.deal(seed), {}
  assert(#choices == 3 and table.concat(choices) == table.concat(Jokers.deal(seed)))
  for _, id in ipairs(choices) do
    assert(Jokers.get(id) and not unique[id], "A draft must contain three distinct known jokers")
    unique[id], seen[id] = true, true
  end
end
assert(#Jokers == 12)
for _, joker in ipairs(Jokers) do assert(seen[joker.id], "Every joker must be reachable in a draft") end
assert(table.concat(Jokers.deal(1)) ~= table.concat(Jokers.deal(2)))

local examples = {
  {"little_ones", {1,1,2,3,4}, 10}, {"little_ones", {1,1,1,1,1}, 25},
  {"little_ones", {2,2,2,2,2}, 0},
  {"bookends", {2,6,3,1,2}, 10}, {"bookends", {6,6,6,6,6}, 10}, {"bookends", {1,2,3,4,5}, 0},
  {"rainbow", {1,2,3,5,6}, 15}, {"rainbow", {1,2,3,4,5}, 15}, {"rainbow", {1,2,3,5,5}, 0},
  {"odd_todd", {1,3,5,3,1}, 15}, {"odd_todd", {5,5,5,5,5}, 15}, {"odd_todd", {1,3,5,3,2}, 0},
  {"even_steven", {2,4,6,4,2}, 15}, {"even_steven", {6,6,6,6,6}, 15}, {"even_steven", {2,4,6,4,1}, 0},
  {"step_up", {1,2,3,4,5}, 20}, {"step_up", {5,4,3,2,1}, 20}, {"step_up", {1,2,1,2,1}, 20},
  {"step_up", {1,2,4,5,6}, 15}, {"step_up", {6,6,6,6,6}, 0},
  {"opposites", {1,6,1,6,1}, 20}, {"opposites", {6,1,6,1,6}, 20},
  {"opposites", {2,5,3,4,6}, 10}, {"opposites", {6,6,6,6,6}, 0},
}
for _, example in ipairs(examples) do
  local faces = table.concat(example[2])
  local scored, ordinary = Scoring.evaluate(example[2], example[1]), Scoring.evaluate(example[2])
  assert(scored.joker_bonus == example[3], example[1] .. " bonus mismatch")
  assert(scored.base_score == ordinary.base_score and scored.total == ordinary.total + example[3])
  assert(table.concat(example[2]) == faces)
end

-- Worked all-ones boards cover attribution, one-time events, and reloads for all twelve jokers.
local totals = {pair_pay = 600, short_run = 500, thrifty = 550, crossroads = 600,
  little_ones = 750, bookends = 600, rainbow = 500, odd_todd = 650,
  even_steven = 500, step_up = 500, opposites = 500, star = 520}
for _, joker in ipairs(Jokers) do
  local game, line_count, star_events = Session.new(joker.id, 1), 0, 0
  for turn = 1, 5 do
    local boundary = game:snapshot()
    boundary.dice = {1,1,1,1,1}
    game = Session.resume(boundary)
    game:begin_placement()
    for die = 1, 5 do assert(game:place(die, (turn - 1) * 5 + die)) end
    local before = game:view()
    local preview = game:preview()
    assert(game:view().score == before.score and game:view().rng == before.rng)
    local event_total = 0
    for _, event in ipairs(preview.events) do
      event_total = event_total + event.points
      if event.kind == "line" then line_count = line_count + 1 end
      if event.joker == "star" then
        assert(turn == 5 and event.scope == "board" and event.points == 20)
        star_events = star_events + 1
      end
    end
    assert(event_total == preview.points)
    assert(game:confirm())
    assert(not game:confirm())
    game = Session.resume(game:snapshot())
    assert(game:view().score == preview.total)
  end
  local view = game:view()
  assert(view.phase == "results" and view.score == totals[joker.id], joker.id .. " total mismatch")
  assert(line_count == (joker.id == "crossroads" and 12 or 10))
  assert(star_events == (joker.id == "star" and 1 or 0))
  assert(Summary.calculate(view).contribution == totals[joker.id] - 500)
  assert(not game:confirm() and not game:finish_scoring())
end

-- Both diagonals can fill together before board completion and must never pay again.
local snapshot = Session.new("crossroads", 1):snapshot()
snapshot.turn, snapshot.dice = 3, {1,1,1,1,1}
for _, cell in ipairs({1,7,19,25,5,9,17,21,2,4}) do snapshot.board[cell] = 1 end
local crossroads = Session.resume(snapshot)
crossroads:begin_placement()
for die, cell in ipairs({6,8,10,12}) do crossroads:place(die, cell) end
local rng, history = crossroads:view().rng, #crossroads.history
local predicted = crossroads:preview(5, 13)
assert(predicted.points == 150 and #predicted.lines == 3)
assert(crossroads:view().rng == rng and #crossroads.history == history and crossroads:view().board[13] == 0)
crossroads:place(5, 13)
crossroads:confirm()
local committed = crossroads:snapshot()
assert(committed.scored_lines.diagonal1 and committed.scored_lines.diagonal2)
local resumed = Session.resume(committed)
resumed:begin_placement()
for _, line in ipairs(resumed:preview().lines) do assert(Lines.decode(line.id) ~= "diagonal") end
assert(Lines.contains("diagonal1", 13) and Lines.contains("diagonal2", 13))
assert(not Lines.contains("diagonal1", 5) and Lines.contains("diagonal2", 5))
assert(table.concat(Lines.faces({1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}, "diagonal2"), ",") == "5,9,13,17,21")

local star_board = {}
for cell = 1, 25 do star_board[cell] = 6 end
star_board[8], star_board[14] = 1, 1
assert(Scoring.board_bonus(star_board, "star") == 10)
for _, cell in ipairs({8,12,14,18}) do star_board[cell] = 1 end
assert(Scoring.board_bonus(star_board, "star") == 0, "Diagonal matches must not count")
star_board[1] = 0
assert(Scoring.board_bonus(star_board, "star") == 0, "Star requires a completed board")
print("twelve-joker drafts, worked bonuses, full-board attribution, diagonal score-once and Star passed")
