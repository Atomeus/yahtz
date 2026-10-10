-- Exercise the public engine callbacks with input and persistence adapters.
local function copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, item in pairs(value) do result[key] = copy(item) end
  return result
end
local saved, pressed, mouse_click, mx, my
local labels, rectangles, score_labels = {}, {}, {}
local function noop() end
gfx = setmetatable({
  text = function(value) labels[#labels + 1] = value end,
  text_ex = function(value) score_labels[#score_labels + 1] = value end,
  rect = function(x, y, w, h, color) rectangles[#rectangles + 1] = {x, y, w, h, color} end,
  rect_fill = noop, clear = noop,
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
  measure_text = function(value) return #value * 6, 7 end,
}
require("main")
local function draw()
  labels, rectangles, score_labels = {}, {}, {}
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
  assert(has_label("PICK YOUR JOKER"))
  click(230, 80)
  assert(State.session:view().phase == "rolling")
end
local function same(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for k, v in pairs(a) do if not same(v, b[k]) then return false end end
  for k in pairs(b) do if a[k] == nil then return false end end
  return true
end

local function change_theme_in_game()
  local before = State.session:view()
  local boundary = State.session:snapshot()
  local event_timer, selected = State.event_timer, State.selected
  click(200, 24)
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

local function inspect_joker()
  local before, timer = State.session:view(), State.event_timer
  click(380, 28)
  assert(has_label("Each distinct repeated face adds +10 per line."))
  assert(has_label("Example: 2,2,5,5,5 adds +20 bonus points."))
  tick(2)
  assert(same(State.session:view(), before) and State.event_timer == timer)
  -- The dialog has no underlying gameplay targets.
  click(250, 120)
  assert(same(State.session:view(), before))
  key(input.BTN1)
  assert(State.screen == "game" and not State.joker_info and State.focus == 41)
end

local function complete_board()
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
      inspect_joker()
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
  assert(has_label("NEW HIGH SCORE!"))
end
boot()
assert(has_label("HIGH SCORES"))
assert(State.theme == "classic", "Old saves must default to Classic")
click(330, 80)
assert(has_label("CHOOSE YOUR COLORS"))
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
inspect_joker()
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
click(300, 158) -- Adjustment.
assert(State.session:view().adjustments == 1)
click(50, 60) -- Preserve an unconfirmed placement and its undo history too.
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
assert(has_label("HIGH SCORES") and #saved.high_scores == 1)
local score = saved.high_scores[1].score
boot()
assert(has_label(saved.high_scores[1].name))
click(180, 110)
assert(has_label("BOARD COMPLETE!") and not has_label("NEW HIGH SCORE!"))
assert(#saved.high_scores == 1 and saved.high_scores[1].score == score)
boot()
click(330, 80)
click(40, 190)
click(40, 250)
play()
complete_board()
click(310, 230) -- Skip qualifying name entry.
assert(has_label("BOARD COMPLETE!") and #saved.high_scores == 1)
click(250, 245)
click(180, 110)
assert(has_label("BOARD COMPLETE!") and not has_label("NEW HIGH SCORE!"))
-- Existing save shape also permits a blank name and fallback to PLAYER.
saved.high_score_handled = false
boot()
click(180, 110)
assert(has_label("NEW HIGH SCORE!"))
click(80, 230)
assert(#saved.high_scores == 2)
local found_player = false
for _, entry in ipairs(saved.high_scores) do
  if entry.name == "PLAYER" then found_player = true end
end
assert(found_player)
print("lifecycle navigation, controls, full boards, resume, preferences and name entry passed")
