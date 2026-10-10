local fills, outlines, texts = {}, {}, {}
gfx = setmetatable({
  rect_fill = function(...) fills[#fills + 1] = {...} end,
  rect = function(...) outlines[#outlines + 1] = {...} end,
  text = function(...) texts[#texts + 1] = {...} end,
  text_ex = function(...) texts[#texts + 1] = {...} end,
}, {__index = function(_, key) return key end})
usagi = {measure_text = function(label) return #label * 6, 7 end}
local Feedback = require("ui.scoring_feedback")
local Lines = require("game.lines")
local ScoreDisplay = require("ui.score_display")
local state = {event_timer = 0.03, event_index = 1, events = {{kind = "line", line = "row1", points = 50}}, reduced_motion = false}
local view = {phase = "resolving", score = 60, turn = 2}
assert(Lines.contains("row2", 6) and not Lines.contains("row2", 1))
assert(Lines.contains("column2", 7) and not Lines.contains("column2", 8))
Feedback.cell(state, state.events[1], 1, 42, 53, 36)
assert(#fills == 1 and fills[1][3] > 2 and fills[1][4] == 2, "Row sweep travels horizontally")
fills = {}
Feedback.cell(state, {kind = "line", line = "column1"}, 1, 42, 53, 36)
assert(#fills == 1 and fills[1][3] == 2 and fills[1][4] > 2, "Column sweep travels vertically")
fills = {}
state.reduced_motion = true
Feedback.cell(state, state.events[1], 1, 42, 53, 36)
assert(#fills == 0 and #outlines == 3, "Reduced motion has static cell outlines")
ScoreDisplay.draw(state, view)
assert(texts[#texts][1] == "60 POINTS")
state.reduced_motion = false
state.event_timer = 0
ScoreDisplay.draw(state, view)
assert(texts[#texts][1] == "10 POINTS", "Count waits for the sweep")
state.event_timer = 0.25
Feedback.draw(state, state.events[1], 42, 53, 36)
local origin = texts[#texts]
state.event_timer = 0.75
ScoreDisplay.draw(state, view)
assert(texts[#texts][1] == "60 POINTS", "Full contribution arrives before advancing")
state.event_timer = 0.44
Feedback.draw(state, state.events[1], 42, 53, 36)
assert(texts[#texts][2] < origin[2] and texts[#texts][3] < origin[3], "Points travel toward the total")
local before = #texts
state.event_timer = 0.45
Feedback.draw(state, state.events[1], 42, 53, 36)
assert(#texts == before, "Arriving label deposits into the score rather than covering it")
ScoreDisplay.draw(state, view)
assert(texts[#texts][1] == "10 POINTS", "Count begins on point arrival")
print("directional sweeps, static feedback, point travel and score timing passed")
-- Crossroads and Star identify their contributing cells in both motion modes.
outlines, fills = {}, {}
state.reduced_motion, state.event_timer = true, 0.1
Feedback.cell(state, {kind = "line", line = "diagonal2", joker = "crossroads"}, 5, 186, 53, 36)
Feedback.cell(state, {kind = "line", line = "diagonal2", joker = "crossroads"}, 1, 42, 53, 36)
assert(#outlines == 1 and #fills == 0, "Only the active diagonal is outlined with reduced motion")
outlines = {}
for cell = 1, 25 do Feedback.cell(state, {kind = "joker", joker = "star"}, cell, 42, 53, 36) end
assert(#outlines == 5, "Star identifies the center and its four orthogonal neighbors")
outlines, fills = {}, {}
state.reduced_motion, state.event_timer = false, 0.25
Feedback.cell(state, {kind = "line", line = "diagonal2", joker = "crossroads"}, 5, 186, 53, 36)
assert(#outlines == 1 and #fills == 1)
local start = #texts
Feedback.draw(state, {kind = "line", line = "diagonal2", joker = "crossroads", points = 50}, 42, 53, 36)
assert(#texts == start + 1 and texts[#texts][1] == "+50")
