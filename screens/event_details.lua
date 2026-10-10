local Themes = require("ui.themes")
local Controls = require("ui.controls")
local Drawing = require("ui.drawing")
local Lines = require("game.lines")
local EventDetails = {}

function EventDetails.draw(state, scope, event, close)
  local title, details
  if scope == "board" then
    title = "BOARD EVENT: THREE ROWS"
    details = {
      "Finish at least three rows with exactly 20 pips each.",
      "All five dice in each row must be placed.",
      "Columns and diagonals do not count.",
      "Earn +50 once, when the whole board is finished.",
      "Missing this objective costs nothing.",
    }
  elseif event.operation == "line" then
    title = "TURN EVENT: MARKED LINE"
    details = {
      "Complete " .. Lines.label(event.line) .. " this turn with exactly " .. event.target .. " pips.",
      "Its board label is highlighted.",
      "Earn an extra copy of its ordinary combination score.",
      "Joker bonuses and rule improvements are not doubled.",
      "Pays once on confirmation; expires after this turn.",
      "Missing it costs nothing; events cannot be exchanged.",
    }
  else
    local addition = event.operation == "sum"
    title = "TURN EVENT: ADJACENT " .. (addition and "SUM" or "PRODUCT")
    details = {
      "Place two neighboring dice whose " .. (addition and "sum" or "product") .. " is " .. event.target .. ".",
      "They must touch horizontally or vertically.",
      "At least one die must be placed this turn.",
      "Earn +10 once, even if several pairs qualify.",
      "Pays on confirmation; expires after this turn.",
      "Missing it costs nothing; events cannot be exchanged.",
    }
  end
  local colors = Themes.colors()
  gfx.rect_fill(42, 36, 396, 198, colors.panel)
  gfx.rect(42, 36, 396, 198, colors.border)
  Drawing.text(title, 62, 52, colors.accent)
  for i, line in ipairs(details) do
    Drawing.text(line, 62, 80 + (i - 1) * 20, colors.text)
  end
  Controls.button(state, 45, 62, 204, 356, 22, "Back to game", close)
end

return EventDetails
