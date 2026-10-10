local Themes = require("ui.themes")
local Controls = require("ui.controls")
local Drawing = require("ui.drawing")
local JOKERS = require("game.jokers")
local JokerDetails = {}

function JokerDetails.draw(state, id, close)
  local colors = Themes.colors()
  local joker = JOKERS.get(id)
  if not joker then return end
  gfx.rect_fill(64, 58, 352, 154, colors.panel)
  gfx.rect(64, 58, 352, 154, colors.border)
  Drawing.text(joker.name, 84, 74, colors.accent)
  for i, line in ipairs(joker.details) do
    Drawing.text(line, 84, 102 + (i - 1) * 20, colors.text)
  end
  Controls.button(state, 42, 84, 176, 312, 24, "Back to game", close)
  Drawing.text("Your board stays exactly as you left it.", 84, 225, colors.secondary)
end

return JokerDetails
