-- Exercise the public engine callbacks with input and persistence adapters.
local function copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, item in pairs(value) do result[key] = copy(item) end
  return result
end
local saved, pressed, mouse_click, mx, my
local labels, rectangles, score_labels = {}, {}, {}
local text_positions = {}
local fills = {}
local function noop() end
gfx = setmetatable({
  text = function(value, x, y)
    labels[#labels + 1] = value
    text_positions[#text_positions + 1] = {value = value, x = x, y = y}
  end,
  text_ex = function(value) score_labels[#score_labels + 1] = value end,
  rect = function(x, y, w, h, color) rectangles[#rectangles + 1] = {x, y, w, h, color} end,
  rect_fill = function(x, y, w, h, color) fills[#fills + 1] = {x, y, w, h, color} end,
  clear = noop,
}, {__index = function(_, key)
  assert(key:match("^COLOR_"), "Unexpected drawing API: " .. key)
  return key
end})
sfx = {play_ex = noop}
music = {play_ex = noop, mutate = noop}
input = {
  LEFT = "left", RIGHT = "right", UP = "up", DOWN = "down",
  BTN1 = "select", BTN2 = "undo", BTN3 = "skip", MOUSE_LEFT = "mouse",
  pressed = function(action) return pressed == action end,
  mouse = function() return mx or -1, my or -1 end,
  mouse_pressed = function() return mouse_click end,
  mapping_for = function(action) return action end,
}
usagi = {
  elapsed = 1,
  save = function(value) saved = copy(value) end,
  load = function() return copy(saved) end,
  measure_text = function(value) return #value * 6, 16 end,
}
require("main")
local function draw()
  labels, rectangles, score_labels = {}, {}, {}
  text_positions = {}
  fills = {}
  _draw()
end
local function tick(dt)
  _update(dt or 0)
  pressed, mouse_click = nil, false
  draw()
end
local function click(x, y)
  mx, my, mouse_click = x, y, true
  tick()
end
local function key(action)
  pressed = action
  tick()
end
local function has_label(value)
  for _, label in ipairs(labels) do if label == value then return true end end
  return false
end
local function boot()
  _init()
  draw()
end
local function play()
  click(180, 80)
  if has_label("Start a new board?") then click(160, 170) end
  assert(has_label("PICK YOUR JOKER"))
  click(230, 80)
  assert(State.session:view().phase == "rolling")
  assert(State.session:view().objectives.active.id == saved.session.objectives.active.id)
  local board_objective, turn_objective = false, false
  for _, item in ipairs(text_positions) do
    if item.value:match("^Board: rows =20") or item.value:match("^Turn: ") then
      local width, height = usagi.measure_text(item.value)
      assert(item.x + width <= 222 and item.y + height <= 270, "Objectives must fit below the board")
      board_objective = board_objective or item.value:match("^Board:") ~= nil
      turn_objective = turn_objective or item.value:match("^Turn:") ~= nil
    end
  end
  assert(board_objective and turn_objective, "Both objective durations stay visible during play")
end
local function same(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for k, v in pairs(a) do if not same(v, b[k]) then return false end end
  for k in pairs(b) do if a[k] == nil then return false end end
  return true
end

local function visit_menu_in_game(use_actions)
  local live, boundary = State.session:view(), State.session:snapshot()
  local history, selected = copy(State.session.history), State.selected
  local timer, index, events = State.event_timer, State.event_index, copy(State.events)
  local persisted = copy(saved)
  if use_actions then
    State.focus = 1
    key(input.UP)
    assert(State.focus == 46, "Direction actions must reach the logo from the board")
    key(input.BTN1)
  else click(50, 24) end
  assert(State.screen == "menu" and has_label("Continue") and State.focus == 2)
  tick(2)
  key(input.BTN3) -- Gameplay shortcuts cannot advance payouts from the menu.
  assert(State.event_timer == timer and State.event_index == index)
  assert(same(State.session:view(), live) and same(State.session:snapshot(), boundary))
  assert(same(saved, persisted), "Returning to the menu must not save unconfirmed actions")
  click(180, 80)
  assert(has_label("Start a new board?") and #State.buttons == 2)
  assert(State.focus == 11, "Replacement confirmation defaults to Back")
  click(330, 80) -- Underlying menu actions must not be active.
  assert(has_label("Start a new board?") and State.screen == "menu")
  click(290, 170)
  assert(has_label("Continue") and not has_label("Start a new board?"))
  click(180, 80)
  key(input.BTN2)
  assert(not has_label("Start a new board?"), "The remappable back action dismisses confirmation")
  key(input.DOWN)
  assert(State.focus == 2)
  key(input.BTN1)
  assert(State.screen == "game" and State.focus == 46)
  assert(same(State.session:view(), live) and same(State.session:snapshot(), boundary))
  assert(same(State.session.history, history) and State.selected == selected)
  assert(State.event_timer == timer and State.event_index == index and same(State.events, events))
end

local function change_theme_in_game()
  local before = State.session:view()
  local boundary = State.session:snapshot()
  local event_timer, selected = State.event_timer, State.selected
  click(270, 24)
  assert(has_label("CHOOSE YOUR COLORS") and has_label("Back to game"))
  tick(2) -- Scoring must pause while choosing colors.
  assert(State.event_timer == event_timer)
  click(40, 114)
  assert(State.theme == "midnight" and saved.theme == "midnight")
  click(40, 250)
  assert(State.screen == "game" and State.focus == 40)
  assert(same(State.session:view(), before), "Changing colors must preserve the live turn")
  assert(same(State.session:snapshot(), boundary), "Changing colors must preserve the save boundary")
  assert(State.selected == selected and State.event_timer == event_timer)
end

local function inspect_events()
  local before, boundary = State.session:view(), State.session:snapshot()
  local timer, selected, history = State.event_timer, State.selected, #State.session.history
  click(80, 237)
  assert(has_label("BOARD EVENT: THREE ROWS"))
  assert(has_label("Columns and diagonals do not count."))
  assert(#State.buttons == 1 and State.buttons[1].id == 45, "Only the close control is active")
  tick(2)
  click(250, 120) -- No underlying board, dice, or action controls.
  assert(same(State.session:view(), before) and State.event_timer == timer)
  key(input.BTN2)
  assert(not State.event_info and State.focus == 43)
  key(input.DOWN)
  assert(State.focus == 44, "Directional navigation reaches the turn event")
  key(input.BTN1)
  assert(State.event_info == "turn" and has_label("Back to game"))
  assert(has_label("Missing it costs nothing; events cannot be exchanged."))
  for _, item in ipairs(text_positions) do
    local width, height = usagi.measure_text(item.value)
    assert(item.x >= 42 and item.x + width <= 438 and item.y >= 36 and item.y + height <= 234,
      "Event explanations must fit inside the panel")
  end
  tick(2)
  key(input.BTN1)
  assert(not State.event_info and State.focus == 44)
  assert(same(State.session:view(), before) and same(State.session:snapshot(), boundary))
  assert(State.event_timer == timer and State.selected == selected and #State.session.history == history)
end

local function inspect_joker()
  local before, timer = State.session:view(), State.event_timer
  click(380, 28)
  local details = require("game.jokers").get(before.joker).details
  assert(has_label(details[1]) and has_label(details[3]))
  tick(2)
  assert(same(State.session:view(), before) and State.event_timer == timer)
  -- The dialog has no underlying gameplay targets.
  click(250, 120)
  assert(same(State.session:view(), before))
  key(input.BTN1)
  assert(State.screen == "game" and not State.joker_info and State.focus == 41)
end

local function complete_board(enter_score)
  for turn = 1, 5 do
    click(365, 120) -- End rolling early.
    assert(State.session:view().phase == "placing")
    click(360, 230) -- Disabled until all five dice are placed.
    assert(State.session:view().phase == "placing")
    for die = 1, 5 do
      click(250 + (die - 1) * 44, 70)
      click(50 + (die - 1) * 36, 60 + (turn - 1) * 36)
    end
    click(360, 230)
    assert(State.session:view().phase == "resolving")
    assert(saved.session.phase == (turn == 5 and "results" or "rolling"))
    if turn == 1 then
      local event = State.events[1]
      assert(has_label("+" .. event.points), "Active payout must be visible even with reduced motion")
      assert(score_labels[1] == tostring(event.points) .. " POINTS", "Reduced motion shows the current payout immediately")
      local highlighted = false
      for _, rect in ipairs(rectangles) do
        if rect[1] == 42 and rect[2] == 53 and rect[3] == 35 and rect[5] == require("ui.themes").colors().accent then highlighted = true end
      end
      assert(highlighted, "Completed line cells must be highlighted")
      visit_menu_in_game(true)
      inspect_joker()
      inspect_events()
      change_theme_in_game()
      for _ = 1, 20 do
        if State.session:view().phase ~= "resolving" then break end
        tick(2)
      end
    else
      key(input.BTN3)
    end
  end
  assert(State.session:view().phase == "results")
  assert(has_label("BOARD COMPLETE!") and has_label("Save score"))
  assert(has_label("Events: +" .. saved.session.objectives.contribution))
  if enter_score == false then return end
  click(300, 182)
  assert(has_label("NEW HIGH SCORE!"))
end
boot()
assert(has_label("HIGH SCORES"))
assert(State.theme == "classic", "Old saves must default to Classic")
click(330, 80)
assert(has_label("CHOOSE YOUR COLORS"))
assert(has_label("Reach 200 points") and has_label("Reach 300 points") and has_label("Reach 400 points"))
for _, item in ipairs(text_positions) do
  if item.value == "Available" or item.value:match("^Reach %d+ points$") then
    local width, height = usagi.measure_text(item.value)
    local contained = false
    for _, control in ipairs(State.buttons) do
      if control.id <= 4 and item.x >= control.x and item.y >= control.y
        and item.x + width <= control.x + control.w and item.y + height <= control.y + control.h then
        contained = true
      end
    end
    assert(contained, item.value .. " must fit inside its theme box at the engine's 16px line height")
  end
end
local before_preview = copy(saved)
mx, my = 40, 114
tick()
assert(has_label("Midnight") and has_label("LOCKED: 200 POINTS"))
assert(same(saved, before_preview), "Hover previews must not save or equip a theme")
click(40, 114)
assert(State.theme == "classic" and saved.theme == "classic")
assert(State.colors_preview == "midnight" and has_label("Preview only - stays locked"))
key(input.DOWN)
key(input.BTN1)
assert(State.theme == "classic" and State.colors_preview == "plum",
  "Directional navigation previews locked colors without equipping them")
local Themes = require("ui.themes")
for index, theme in ipairs(Themes.options) do
  if index == 5 or index == 9 then click(420, 50) end
  click(40, 76 + ((index - 1) % 4) * 38)
  assert(has_label(theme.name) and has_label(theme.description))
  assert(State.theme == "classic" and saved.theme == "classic")
  assert(not State.owned_colors[theme.id] or theme.id == "classic")
  local felt = false
  for _, rect in ipairs(fills) do
    if rect[1] == 264 and rect[2] == 70 and rect[5] == theme.table then felt = true end
  end
  assert(felt, "The preview must render the selected theme's felt")
  assert(Themes.colors().id == "classic", "Preview drawing must restore the equipped palette")
end
click(40, 250)
assert(State.theme == "classic" and has_label("HIGH SCORES"))
click(330, 80)
assert(State.colors_preview == "classic", "Reopening Colors starts with the equipped theme")
-- Credit a legacy record, then keep the remaining lifecycle fixtures independent of ranking.
saved = {high_scores = {{name = "LEGACY", score = 400}}}
boot()
assert(saved.owned_colors.golden and #saved.pending_colors == 0)
saved.high_scores = {}
boot()
click(330, 80)
-- Directional actions reach and activate themes without a mouse.
key(input.DOWN)
key(input.BTN1)
assert(saved.theme == "midnight")
for index, id in ipairs({"classic", "midnight", "plum", "golden"}) do
  click(40, 76 + (index - 1) * 38)
  assert(State.theme == id and saved.theme == id)
  assert(has_label("* " .. require("ui.themes").get(id).name))
end
click(40, 250)
assert(has_label("HIGH SCORES"))
boot()
assert(State.theme == "golden", "Theme must persist after reload")
saved.theme = "removed-theme"
boot()
assert(State.theme == "classic", "Unknown saved themes must fall back safely")
click(330, 110) -- Motion now belongs to the main menu.
assert(saved.reduced_motion and has_label("Motion: reduced"))
boot()
assert(State.reduced_motion)
key(input.BTN1) -- Default main-menu focus.
assert(has_label("PICK YOUR JOKER"))
assert(not has_label("Motion: reduced"))
click(230, 80)
local original = table.concat(saved.session.dice, ",")
click(250, 70) -- Hold first die.
assert(State.session:view().held[1])
click(250, 120) -- Reroll.
visit_menu_in_game(false)
inspect_joker()
inspect_events()
change_theme_in_game()
boot()
click(180, 110) -- Continue discards unconfirmed actions on reload.
assert(table.concat(State.session:view().dice, ",") == original)
assert(not State.session:view().held[1] and State.reduced_motion)
click(365, 120)
-- Hover previews are distinct from committed scoring and directional focus takes over.
local live, boundary, undo_count = State.session:view(), State.session:snapshot(), #State.session.history
mx, my = 50, 60
tick()
assert(has_label("IF PLACED"))
mx, my = 475, 265
tick()
assert(not has_label("IF PLACED"), "Leaving the board clears pointer preview")
mx, my = 50, 60
tick()
assert(same(live, State.session:view()) and same(boundary, State.session:snapshot()))
assert(#State.session.history == undo_count)
State.focus = 1
key(input.RIGHT)
assert(State.focus == 2 and not State.pointer_mode and has_label("IF PLACED"))
key(input.BTN1)
assert(State.session:view().placements[1] == 2)
key(input.BTN2)
assert(State.session:view().placements[1] == 0)
-- Either adjustment direction must be legal regardless of the random first die.
click(State.session:view().dice[State.selected] == 6 and 260 or 300, 158)
assert(State.session:view().adjustments == 1)
click(50, 60) -- Preserve an unconfirmed placement and its undo history too.
visit_menu_in_game(true)
inspect_events()
change_theme_in_game()
key(input.BTN2)
assert(State.session:view().placements[1] == 0)
key(input.BTN2)
assert(State.session:view().adjustments == 2)
-- Start a fresh board through the menu after reload.
boot()
click(330, 80)
click(40, 152)
click(40, 250)
play()
complete_board()
assert(saved.results_previous_best == false)
key(input.RIGHT)
key(input.BTN1)
assert(State.entry_name == "B", "Directional focus must activate the selected letter")
for _ = 1, 15 do click(75, 110) end
assert(#State.entry_name == 12)
click(190, 200)
assert(#State.entry_name == 11)
click(75, 200)
assert(#State.entry_name == 12)
click(80, 230)
assert(has_label("BOARD COMPLETE!") and #saved.high_scores == 1)
assert(has_label("First recorded board") and saved.results_previous_best == false)
local score = saved.high_scores[1].score
boot()
assert(has_label(saved.high_scores[1].name))
click(180, 110)
assert(has_label("BOARD COMPLETE!") and not has_label("NEW HIGH SCORE!"))
assert(has_label("First recorded board"))
assert(#saved.high_scores == 1 and saved.high_scores[1].score == score)
boot()
click(330, 80)
click(40, 190)
click(40, 250)
play()
complete_board()
click(310, 230) -- Return from name entry without declining.
click(280, 209)
assert(has_label("Save this score?"))
click(280, 131) -- Explicitly decline and continue to menu.
assert(has_label("HIGH SCORES") and #saved.high_scores == 1)
click(180, 110)
assert(has_label("BOARD COMPLETE!") and not has_label("NEW HIGH SCORE!"))
-- Existing save shape also permits a blank name and fallback to PLAYER.
saved.high_score_handled = false
boot()
click(180, 110)
assert(has_label("BOARD COMPLETE!"))
click(300, 182)
assert(has_label("NEW HIGH SCORE!"))
click(80, 230)
assert(#saved.high_scores == 2)
local found_player = false
for _, entry in ipairs(saved.high_scores) do
  if entry.name == "PLAYER" then found_player = true end
end
assert(found_player)
-- Pending-score prompts keep the original comparison and require explicit decline.
saved.high_score_handled = false
saved.results_previous_best = saved.session.score + 7
boot()
click(180, 110)
assert(has_label("7 short of Table best"))
click(390, 210) -- Play again while pending.
assert(has_label("Save this score?"))
click(290, 165) -- Back keeps the score pending.
assert(has_label("Save score") and not saved.high_score_handled)
click(290, 209) -- Main menu while pending.
click(290, 97) -- Save from the prompt returns to summary.
assert(has_label("NEW HIGH SCORE!"))
click(80, 230)
assert(has_label("BOARD COMPLETE!") and has_label("7 short of Table best"))
click(390, 210) -- Inspect full ledger.
assert(has_label("SCORE DETAILS") and has_label("Back to summary"))
click(290, 246)
assert(has_label("BOARD COMPLETE!") and has_label("Play again"))
boot()
click(180, 110)
assert(has_label("7 short of Table best"))
click(290, 182)
assert(has_label("PICK YOUR JOKER"))
-- Legacy completed saves must not invent a previous record.
saved.results_previous_best, saved.results_record_known = nil, nil
boot()
click(180, 110)
assert(not has_label("7 short of Table best") and not has_label("First recorded board"))
-- A deterministic final turn exercises real completion without relying on random scores.
local Session = require("game.session")
local final_turn = Session.new("pair_pay", 1):snapshot()
final_turn.turn, final_turn.score = 5, 240
for cell = 1, 20 do final_turn.board[cell] = 1 end
for row = 1, 4 do final_turn.scored_lines["row" .. row] = true end
for die = 1, 5 do final_turn.dice[die] = 1 end
saved = {session = final_turn, theme = "classic", color_progression_version = 2,
  owned_colors = {classic = true}, reduced_motion = true}
boot()
assert(not State.owned_colors.midnight, "An unfinished board cannot unlock colors")
click(180, 110)
click(365, 120)
for die = 1, 5 do
  click(250 + (die - 1) * 44, 70)
  click(50 + (die - 1) * 36, 204)
end
click(360, 230)
assert(State.session:view().phase == "resolving" and saved.session.score == 600)
assert(saved.owned_colors.midnight and saved.owned_colors.plum and saved.owned_colors.golden)
assert(#saved.pending_colors == 9 and saved.theme == "classic")
boot() -- Restart before the final payouts finish.
click(180, 110)
assert(has_label("New colors: 9"))
tick(5)
assert(has_label("New colors: 9"), "Notices remain visible while viewing the summary")
click(100, 247)
assert(has_label("NEW COLORS UNLOCKED"))
for _, name in ipairs({"Midnight", "Plum Velvet", "Golden Hour", "Forest", "Cyberpunk", "Candyland", "Ocean", "Paper", "Dark"}) do
  assert(has_label(name), "Every unlocked theme must appear in the notice")
end
assert(#saved.pending_colors == 0)
click(280, 246)
-- Restore pending notices to separately exercise Back and Skip navigation.
saved.pending_colors = {"midnight", "plum", "golden", "forest", "cyberpunk", "candyland", "ocean", "paper", "dark"}
boot()
click(180, 110)
click(280, 209)
click(290, 165) -- Back from pending-score prompt does not acknowledge notices.
assert(has_label("New colors: 9"))
click(280, 209)
click(280, 131) -- Explicitly skip recording.
assert(saved.high_score_handled and #saved.high_scores == 0)
assert(saved.owned_colors.golden and #saved.pending_colors == 0)
boot()
click(180, 110)
assert(not has_label("New colors: 9") and State.owned_colors.golden)
click(280, 209)
click(330, 80)
click(40, 190)
assert(State.theme == "golden" and saved.theme == "golden")
-- Name entry and score details both acknowledge notices without changing ownership.
for _, destination in ipairs({"name", "details"}) do
  saved.pending_colors, saved.high_score_handled = {"midnight"}, false
  boot()
  click(180, 110)
  assert(has_label("New colors: 1"))
  click(280, destination == "name" and 182 or 237)
  assert(#saved.pending_colors == 0 and saved.owned_colors.golden)
  if destination == "name" then
    click(80, 230)
    assert(has_label("BOARD COMPLETE!") and #saved.high_scores == 1)
  else
    assert(has_label("SCORE DETAILS"))
    click(280, 246)
  end
  assert(not has_label("New colors: 1"))
end
-- Migration preserves an existing selection without gifting every color.
boot()
click(330, 80)
click(420, 50)
assert(has_label("  Forest") and has_label("  Ocean") and has_label("2 / 3"))
for index, id in ipairs({"forest", "cyberpunk", "candyland", "ocean"}) do
  click(40, 76 + (index - 1) * 38)
  assert(State.theme == id and saved.theme == id)
end
-- Page navigation also works through the remappable select action.
State.focus = 101
key(input.BTN1)
assert(has_label("  Paper") and has_label("  Dark") and has_label("3 / 3"))
click(40, 76)
assert(saved.theme == "paper")
click(40, 114)
assert(saved.theme == "dark")
click(280, 50)
assert(has_label("2 / 3"))
boot()
assert(State.theme == "dark", "Prestige theme choice must survive restart")
saved = {theme = "plum"}
boot()
assert(saved.theme == "plum" and saved.owned_colors.plum and not saved.owned_colors.midnight)
boot()
assert(State.theme == "plum" and not State.owned_colors.midnight)
saved.theme = "golden" -- An unowned selection in the current schema falls back.
boot()
assert(State.theme == "classic")
-- Exercise every drafted joker through the real application callbacks.
-- Live reload retains State from the version before draft seeds existed.
State.draft_seed = nil
click(180, 80)
assert(State.screen == "jokers" and #State.joker_choices == 3)
State.draft_seed, State.joker_choices = nil, nil
draw() -- Reload while already viewing the old joker selection screen.
assert(#State.joker_choices == 3)
local Jokers = require("game.jokers")
local Summary = require("game.results_summary")
for joker_index, joker in ipairs(Jokers) do
  saved = {color_progression_version = 2, owned_colors = {classic = true, midnight = true},
    reduced_motion = true}
  boot()
  local chosen_seed, slot
  for seed = 1, 200 do
    for index, id in ipairs(Jokers.deal((seed * 16807) % 2147483647)) do
      if id == joker.id then chosen_seed, slot = seed, index; break end
    end
    if chosen_seed then break end
  end
  assert(chosen_seed, "Every joker must be offered through the new-board flow")
  State.draft_seed = chosen_seed
  click(180, 80)
  local offered = table.concat(State.joker_choices, ",")
  assert(#State.joker_choices == 3)
  local visible = 0
  for _, candidate in ipairs(Jokers) do if has_label(candidate.name) then visible = visible + 1 end end
  assert(visible == 3, "Show exactly three offered jokers")
  tick(1)
  assert(table.concat(State.joker_choices, ",") == offered, "Redraws must not reroll the offer")
  for _, item in ipairs(text_positions) do
    for index, id in ipairs(State.joker_choices) do
      local candidate = Jokers.get(id)
      if item.value == candidate.name or item.value == candidate.text or item.value == candidate.hint then
        local width, height = usagi.measure_text(item.value)
        local top = 70 + (index - 1) * 53
        assert(item.x >= 220 and item.x + width <= 462 and item.y >= top and item.y + height <= top + 51,
          "Joker card text must fit with the engine's real line height")
      end
    end
  end
  if joker_index % 2 == 0 then
    State.focus = slot
    key(input.BTN1)
  else click(230, 80 + (slot - 1) * 53) end
  assert(State.session:view().joker == joker.id and saved.session.joker == joker.id)
  boot()
  click(180, 110)
  assert(State.session:view().joker == joker.id, "Continue must preserve the selected joker")
  complete_board(false)
  local result = Summary.calculate(State.session:view())
  assert(has_label(joker.name .. ": +" .. result.contribution), "Results must show accurate joker attribution")
  local points = 0
  for _, event in ipairs(saved.ledger) do points = points + event.points end
  assert(points == saved.session.score, "Ledger payouts must account for the whole board")
  local score = saved.session.score
  boot()
  click(180, 110)
  assert(State.session:view().score == score and State.session:view().joker == joker.id)
  assert(has_label(joker.name .. ": +" .. result.contribution))
  click(390, 209) -- Play again opens pending-record prompt.
  click(280, 131) -- Skip and continue to a fresh draft.
  assert(State.screen == "jokers" and #State.joker_choices == 3)
end
-- A replacement is explicit, and backing out of the draft still preserves the live board.
saved = {session = Session.new("pair_pay", 17):snapshot(), color_progression_version = 2,
  owned_colors = {classic = true}}
boot()
click(180, 110)
click(250, 70)
click(250, 120)
local old_session, old_live, old_saved = State.session, State.session:view(), copy(saved)
click(50, 24)
click(180, 80)
key(input.LEFT)
assert(State.focus == 10)
key(input.BTN1)
assert(State.screen == "jokers" and same(saved, old_saved))
click(50, 200) -- Leave joker selection without replacing anything.
click(180, 110)
assert(State.session == old_session and same(State.session:view(), old_live))
click(50, 24)
click(180, 80)
click(160, 170)
click(230, 80)
assert(State.screen == "game" and State.session ~= old_session)
assert(State.session:view().turn == 1 and State.session:view().score == 0)
assert(not State.session:view().held[1] and saved.session.turn == 1)
assert(State.game_menu_focus == nil)
print("lifecycle navigation, controls, full boards, resume, preferences and name entry passed")
