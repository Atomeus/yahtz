local Themes = require("ui.themes")
local Drawing = require("ui.drawing")
local Controls = require("ui.controls")
local text = Drawing.text
local JOKERS = require("game.jokers")
local JokerSelection = {}

function JokerSelection.draw(state, navigate, start)
  local colors = Themes.colors()
  local function button(...) return Controls.button(state, ...) end
  text("YAHTZ", 26, 27, colors.accent)
  text("THE LITTLE DICE TABLE", 26, 41, colors.secondary)
  text("Five turns.", 26, 82, colors.secondary)
  text("Three random jokers.", 26, 104, colors.secondary)
  text("Choose your advantage.", 26, 126, colors.secondary)
  button(5, 26, 193, 164, 24, "Main menu", function() navigate("menu", 1) end)
  text("PICK ONE. MAKE IT COUNT.", 26, 242, colors.secondary)
  text("PICK YOUR JOKER", 222, 48, colors.accent)
  for i, id in ipairs(state.joker_choices or {}) do
    local joker = JOKERS.get(id)
    local y = 70 + (i - 1) * 53
    button(i, 220, y, 242, 51, "", function() start(joker.id) end)
    text(joker.name, 229, y + 1, colors.accent)
    text(joker.text, 229, y + 17)
    text(joker.hint, 229, y + 33, colors.secondary)
  end
  text("Mouse / directions + " .. (input.mapping_for(input.BTN1) or "?"), 222, 233, colors.secondary)
end

return JokerSelection
