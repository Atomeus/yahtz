local Events = require("game.events")
local Session = require("game.session")
local Scoring = require("scoring")
local Summary = require("game.results_summary")
local Jokers = require("game.jokers")
local function empty()
  local board = {}
  for i = 1, 25 do board[i] = 0 end
  return board
end
local function objective(operation, target, line)
  return {active = {id = operation .. target, operation = operation, target = target, line = line}}
end
local board = empty()
board[1], board[2], board[6] = 3, 4, 4
local event = objective("sum", 7)
assert(#Events.evaluate(event, board, {}, {}) == 0, "Old pairs cannot earn a turn reward")
local payouts = Events.evaluate(event, board, {[1] = true}, {})
assert(#payouts == 1 and payouts[1].points == 10, "Multiple matches pay once")
board = empty()
board[5], board[6] = 3, 4
assert(#Events.evaluate(event, board, {[5] = true}, {}) == 0, "Rows must not wrap")
board[6], board[7] = 0, 4
assert(#Events.evaluate(event, board, {[5] = true}, {}) == 0, "Diagonal cells are not adjacent")
board[10] = 4
assert(#Events.evaluate(event, board, {[10] = true}, {}) == 1, "Vertical adjacency qualifies")
assert(#Events.evaluate(objective("product", 12), board, {[5] = true}, {}) == 1)
board[5], board[10] = 0, 0
assert(#Events.evaluate(event, board, {[7] = true}, {}) == 0, "Empty cells never qualify")

local line = Scoring.evaluate({6, 6, 6, 1, 1}, "pair_pay")
line.id, line.faces = "row1", {6, 6, 6, 1, 1}
payouts = Events.evaluate(objective("line", 20, "row1"), empty(), {}, {line})
assert(payouts[1].points == 25, "Multiplier excludes Pair Pay's +20")
assert(#Events.evaluate(objective("line", 15, "row1"), empty(), {}, {line}) == 0)
assert(#Events.evaluate(objective("line", 20, "column1"), empty(), {}, {line}) == 0)
assert(#Events.evaluate(objective("line", 20, "row1"), empty(), {}, {}) == 0, "Previously scored line cannot pay")
line = Scoring.evaluate({1, 2, 3, 3, 6}, "short_run")
line.id, line.faces = "row2", {1, 2, 3, 3, 6}
payouts = Events.evaluate(objective("line", 15, "row2"), empty(), {}, {line})
assert(payouts[1].points == 15, "Multiplier excludes rule-changing joker improvements")

board = empty()
for row = 1, 5 do
  for col, face in ipairs(row <= 3 and {6, 6, 6, 1, 1} or {1, 1, 1, 1, 1}) do
    board[(row - 1) * 5 + col] = face
  end
end
assert(Events.board_progress(board) == 3)
payouts = Events.evaluate(event, board, {}, {})
assert(#payouts == 1 and payouts[1].points == 50)
board[25] = 0
assert(#Events.evaluate(event, board, {}, {}) == 0, "Board event waits for all 25 cells")
local seen, deck = {}, Events.new(1)
local scored = {row1 = true, column5 = true}
for turn = 1, 5 do
  Events.deal(deck, scored)
  assert(not seen[deck.active.id])
  seen[deck.active.id] = true
  assert(not deck.active.line or not scored[deck.active.line], "Marked lines are unfinished")
end

-- Preview is reversible; awards, deck and RNG commit only at turn boundaries.
local fixture = Session.new("pair_pay", 1):snapshot()
fixture.dice = {6, 6, 6, 1, 1}
fixture.objectives.active = {id = "line20", operation = "line", target = 20, line = "row1"}
local game = Session.resume(fixture)
game:begin_placement()
for die = 1, 4 do game:place(die, die) end
local before = game:snapshot()
local prediction = game:preview(5, 5)
assert(prediction.event_bonus == 25 and prediction.total == 70)
assert(game:view().objectives.contribution == 0 and #game:view().objectives.remaining == #before.objectives.remaining)
game:place(5, 5)
assert(game:preview().total == prediction.total)
game:undo()
assert(game:preview().event_bonus == 0)
game:place(5, 5)
local committed = assert(game:confirm())
assert(#committed == 3 and committed[3].kind == "event")
assert(game:snapshot().score == 70 and game:snapshot().objectives.contribution == 25)
assert(game:snapshot().objectives.line_bonuses.row1 == 25)
local summary_board = {}
for cell = 1, 25 do summary_board[cell] = cell <= 5 and fixture.dice[cell] or 1 end
local boosted = Summary.calculate({board = summary_board, joker = "pair_pay", score = 0,
  objectives = game:snapshot().objectives})
assert(boosted.strongest.id == "row1" and boosted.strongest.total == 70,
  "Strongest-line ranking includes its recorded event bonus")
assert(not game:confirm())
local restored = Session.resume(game:snapshot())
game:finish_scoring()
assert(game:view().objectives.active.id == restored:view().objectives.active.id)
assert(game:view().objectives.rng == restored:view().objectives.rng)
assert(table.concat(game:view().dice) == table.concat(restored:view().dice))

-- New objectives do not change the legacy dice stream or retrofit old boards.
local legacy = Session.new("thrifty", 1):snapshot()
legacy.objectives = nil
local old = Session.resume(legacy)
local modern = Session.new("thrifty", 1)
for turn = 1, 5 do
  assert(table.concat(old:view().dice) == table.concat(modern:view().dice))
  for _, session in ipairs({old, modern}) do
    session:begin_placement()
    for die = 1, 5 do session:place(die, (turn - 1) * 5 + die) end
    session:confirm()
    session:finish_scoring()
  end
end
assert(old:view().objectives == nil and old:view().phase == "results")
assert(Summary.calculate(old:view()).event_contribution == nil)
assert(Summary.calculate(modern:view()).event_contribution == modern:view().objectives.contribution)

-- Final confirmation can earn both event rewards, once, and persist them before animation.
fixture = Session.new("thrifty", 1):snapshot()
fixture.turn, fixture.score = 5, 100
fixture.board = board
fixture.board[25] = 0
for i = 21, 24 do fixture.board[i] = 0 end
for row = 1, 4 do fixture.scored_lines["row" .. row] = true end
fixture.dice = {3, 4, 1, 1, 1}
fixture.objectives.active = {id = "sum7", operation = "sum", target = 7}
game = Session.resume(fixture)
game:begin_placement()
for die = 1, 5 do game:place(die, 20 + die) end
prediction = game:preview()
assert(prediction.event_bonus == 60)
game:confirm()
restored = Session.resume(game:snapshot())
assert(restored:view().phase == "results" and restored:view().objectives.contribution == 60)
assert(not restored:confirm())
local summary = Summary.calculate(restored:view())
assert(summary.event_contribution == 60 and summary.contribution == 10)
-- Every joker keeps its own payout while a line event adds only ordinary points.
for _, joker in ipairs(Jokers) do
  local snapshot = Session.new(joker.id, 1):snapshot()
  snapshot.dice = {1, 2, 3, 4, 5}
  snapshot.objectives.active = {id = "line15", operation = "line", target = 15, line = "row1"}
  local combined = Session.resume(snapshot)
  combined:begin_placement()
  for die = 1, 5 do combined:place(die, die) end
  local preview = combined:preview()
  assert(preview.event_bonus == 40, joker.id .. " must not alter the ordinary event multiplier")
  assert(preview.total == Scoring.evaluate(snapshot.dice, joker.id).total + 40
    + (joker.id == "thrifty" and 10 or 0))
  combined:confirm()
  assert(combined:snapshot().objectives.contribution == 40)
end
print("event qualification, random dealing, payouts, previews, resume, legacy compatibility and all-joker integration passed")
