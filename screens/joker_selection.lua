local Drawing = require("ui.drawing")
local Controls = require("ui.controls")
local text = Drawing.text
local JOKERS = require("game.jokers")
local JokerSelection = {}

function JokerSelection.draw(state, navigate, start, toggle_motion)
  local function button(...) return Controls.button(state, ...) end
  text("YAHTZ", 26, 27, gfx.COLOR_YELLOW)
  text("THE LITTLE DICE TABLE", 26, 41, gfx.COLOR_PEACH)
  text("Five turns.", 26, 82, gfx.COLOR_PEACH)
  text("Ten scoring lines.", 26, 104, gfx.COLOR_PEACH)
  text("Choose your advantage.", 26, 126, gfx.COLOR_PEACH)
  button(5, 26, 193, 164, 24, "Main menu", function() navigate("menu", 1) end)
  text("FIVE TURNS. TEN LINES.", 26, 242, gfx.COLOR_PEACH)
  text("PICK YOUR JOKER", 222, 48, gfx.COLOR_YELLOW)
  for i, joker in ipairs(JOKERS) do
    local y = 70 + (i - 1) * 51
    button(i, 220, y, 242, 45, "", function() start(joker.id) end)
    text(joker.name, 229, y + 5, gfx.COLOR_YELLOW)
    text(joker.text, 229, y + 18)
    text(joker.hint, 229, y + 30, gfx.COLOR_PEACH)
  end
  text("Mouse / directions + " .. (input.mapping_for(input.BTN1) or "?"), 222, 233, gfx.COLOR_PEACH)
  button(4, 222, 245, 240, 11, "Motion: " .. (state.reduced_motion and "reduced" or "bouncy"), toggle_motion)
end

return JokerSelection
