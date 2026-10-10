local Themes = require("ui.themes")
local Controls = require("ui.controls")
local Drawing = require("ui.drawing")
local ThemeSelection = {}
local Unlocks = require("game.color_unlocks")

function ThemeSelection.draw(state, return_from_themes, select_theme)
  local colors = Themes.colors()
  Drawing.text("CHOOSE YOUR COLORS", 24, 24, colors.accent)
  Drawing.text("Hover or select a color to preview.", 24, 42, colors.secondary)

  local pages = math.ceil(#Themes.options / 4)
  local page = math.max(1, math.min(pages, state.colors_page or 1))
  local function change_page(delta)
    state.colors_page = page + delta
    state.focus = state.colors_page == pages and 100 or 101
  end
  Controls.button(state, 100, 260, 42, 60, 18, "Prev", function() change_page(-1) end, page > 1)
  Drawing.text(page .. " / " .. pages, 334, 43, colors.secondary)
  Controls.button(state, 101, 396, 42, 60, 18, "Next", function() change_page(1) end, page < pages)

  local preview_id = state.colors_preview or state.theme
  for i = (page - 1) * 4 + 1, math.min(#Themes.options, page * 4) do
    local theme = Themes.options[i]
    local y = 66 + ((i - 1) % 4) * 38
    local selected = theme.id == state.theme
    local owned = state.owned_colors[theme.id]
    local id = i <= 4 and i or i + 10
    if (state.pointer_mode and state.hover == id) or (not state.pointer_mode and state.focus == id) then
      preview_id = theme.id
    end
    Controls.button(state, id, 24, y, 216, 36, "",
      function()
        state.colors_preview = theme.id
        if owned then select_theme(theme.id) end
      end)
    Drawing.text((selected and "* " or "  ") .. theme.name, 32, y + 1,
      owned and colors.secondary or colors.muted)
    Drawing.text(owned and "Available" or ("Reach " .. Unlocks.required(theme.id) .. " points"),
      32, y + 18, colors.secondary)
    for j, color in ipairs({theme.table, theme.frame, theme.die, theme.accent}) do
      gfx.rect_fill(174 + (j - 1) * 14, y + 22, 10, 7, color)
    end
  end

  -- Preview uses the same drawing roles as the full board.
  local preview = Themes.get(preview_id)
  local preview_owned = state.owned_colors[preview.id]
  Themes.use(preview.id)
  gfx.rect_fill(260, 66, 196, 140, preview.frame)
  gfx.rect_fill(264, 70, 188, 132, preview.table)
  Drawing.text(preview.name, 278, 82, preview.text)
  Drawing.die(5, 280, 105, 32, false, false, false)
  Drawing.die(3, 324, 105, 32, true, false, false)
  Drawing.die(6, 368, 105, 32, false, true, false)
  gfx.rect_fill(278, 152, 158, 24, preview.panel)
  Drawing.text("125 POINTS", 288, 160, preview.accent)
  Drawing.text(preview_owned and "SELECTED / FIXED" or ("LOCKED: " .. Unlocks.required(preview.id) .. " POINTS"),
    278, 185, preview.secondary)
  Themes.use(state.theme)
  Drawing.text(preview.description, 24, 224, colors.secondary)
  local return_screen = state.theme_return and state.theme_return.screen
  local return_label = return_screen == "game" and "Back to game"
    or (return_screen == "results" and "Back to results" or "Main menu")
  Controls.button(state, 5, 24, 242, 130, 18, return_label, return_from_themes)
  Drawing.text(preview_owned and "Choice saves automatically" or "Preview only - stays locked", 206, 247, colors.muted)
end

return ThemeSelection
