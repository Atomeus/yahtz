local Drawing = require("ui.drawing")
local Controls = require("ui.controls")
local text, sound = Drawing.text, Drawing.sound
local HighScores = require("game.high_scores")
local NameEntry = {}

local function append(state, value)
  if #state.entry_name < HighScores.NAME_LIMIT then state.entry_name = state.entry_name .. value end
end

function NameEntry.draw(state, navigate, save)
  local function button(...) return Controls.button(state, ...) end
  text("NEW HIGH SCORE!", 150, 26, gfx.COLOR_YELLOW)
  text(tostring(state.session:view().score) .. " POINTS - ENTER YOUR NAME", 114, 47, gfx.COLOR_PEACH)
  gfx.rect_fill(78, 69, 324, 24, gfx.COLOR_DARK_BLUE)
  text((state.entry_name or "") .. "_", 88, 73, gfx.COLOR_WHITE)
  local letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  for i = 1, #letters do
    local letter = letters:sub(i, i)
    local x, y = 70 + ((i - 1) % 9) * 38, 103 + math.floor((i - 1) / 9) * 22
    button(99 + i, x, y, 34, 20, letter, function()
      append(state, letter)
    end, #state.entry_name < HighScores.NAME_LIMIT)
  end
  button(136, 70, 195, 106, 20, "Space", function()
    append(state, " ")
  end, #state.entry_name < HighScores.NAME_LIMIT)
  button(137, 184, 195, 106, 20, "Delete", function()
    state.entry_name = state.entry_name:sub(1, -2)
  end, #state.entry_name > 0)
  button(138, 70, 221, 220, 22, "Save score", function()
    if state.high_score_handled then return end
    state.high_scores = HighScores.record(state.high_scores or {}, state.entry_name, state.session:view().score)
    state.high_score_handled = true
    navigate("menu", 1)
    save()
    sound("score")
  end)
  button(139, 298, 221, 110, 22, "Skip", function()
    state.high_score_handled = true
    navigate("game", 33)
    save()
  end)
  text(HighScores.NAME_LIMIT .. " characters / blank name saves as PLAYER", 78, 245, gfx.COLOR_PEACH)
end

return NameEntry
