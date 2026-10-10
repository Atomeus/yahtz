-- Exercise the public engine callbacks with input and persistence adapters.
local function copy(value)
  if type(value) ~= "table" then return value end
  local result = {}
  for key, item in pairs(value) do result[key] = copy(item) end
  return result
end
local saved, pressed, mouse_click, mx, my
local labels = {}
local function noop() end
gfx = setmetatable({
  text = function(value) labels[#labels + 1] = value end,
  text_ex = noop, rect = noop, rect_fill = noop, clear = noop,
}, {__index = function(_, key)
  assert(key:match("^COLOR_"), "Unexpected drawing API: " .. key)
  return key
end})
sfx = {play_ex = noop}
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
  labels = {}
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
key(input.BTN1) -- Default main-menu focus.
assert(has_label("PICK YOUR JOKER"))
click(230, 250)
assert(saved.reduced_motion)
click(230, 80)
local original = table.concat(saved.session.dice, ",")
click(250, 70) -- Hold first die.
assert(State.session:view().held[1])
click(250, 120) -- Reroll.
boot()
click(180, 110) -- Continue discards unconfirmed actions on reload.
assert(table.concat(State.session:view().dice, ",") == original)
assert(not State.session:view().held[1] and State.reduced_motion)
click(365, 120)
click(300, 158) -- Adjustment.
assert(State.session:view().adjustments == 1)
key(input.BTN2)
assert(State.session:view().adjustments == 2)
-- Start a fresh board through the menu after reload.
boot()
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
