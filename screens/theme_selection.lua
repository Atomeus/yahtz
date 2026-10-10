local Themes = require("ui.themes")
local Controls = require("ui.controls")
local Drawing = require("ui.drawing")
local ThemeSelection = {}

function ThemeSelection.draw(state, return_from_themes, select_theme)
  local colors = Themes.colors()
  Drawing.text("CHOOSE YOUR COLORS", 24, 24, colors.accent)
  Drawing.text("All themes available. Select to apply.", 24, 42, colors.secondary)

  for i, theme in ipairs(Themes.options) do
    local y = 66 + (i - 1) * 38
    local selected = theme.id == state.theme
    Controls.button(state, i, 24, y, 216, 30,
      (selected and "* " or "  ") .. theme.name,
      function() select_theme(theme.id) end)
    for j, color in ipairs({theme.table, theme.frame, theme.die, theme.accent}) do
      gfx.rect_fill(174 + (j - 1) * 14, y + 19, 10, 7, color)
    end
  end

  -- Preview uses the same drawing roles as the full board.
  gfx.rect_fill(260, 66, 196, 140, colors.frame)
  gfx.rect_fill(264, 70, 188, 132, colors.table)
  Drawing.text("TABLE PREVIEW", 278, 82, colors.text)
  Drawing.die(5, 280, 105, 32, false, false, false)
  Drawing.die(3, 324, 105, 32, true, false, false)
  Drawing.die(6, 368, 105, 32, false, true, false)
  gfx.rect_fill(278, 152, 158, 24, colors.panel)
  Drawing.text("125 POINTS", 288, 160, colors.accent)
  Drawing.text("SELECTED / FIXED", 278, 185, colors.secondary)
  Drawing.text(Themes.get(state.theme).description, 24, 224, colors.secondary)
  local return_label = state.theme_return and state.theme_return.screen == "game"
    and "Back to game" or "Main menu"
  Controls.button(state, 5, 24, 242, 130, 18, return_label, return_from_themes)
  Drawing.text("Choice saves automatically", 206, 247, colors.muted)
end

return ThemeSelection
