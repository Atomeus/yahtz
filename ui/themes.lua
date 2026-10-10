local Themes = {}

-- Palette colors only. Dark surfaces keep small bitmap text easy to read.
-- Definitions are independent of ownership/unlock rules.
Themes.options = {
  {
    id = "classic", name = "Classic Table", description = "Green trim, midnight felt, cream dice",
    table = gfx.COLOR_DARK_BLUE, panel = gfx.COLOR_BLACK,
    frame = gfx.COLOR_DARK_GREEN, accent = gfx.COLOR_YELLOW,
    secondary = gfx.COLOR_PEACH, die = gfx.COLOR_PEACH,
  },
  {
    id = "midnight", name = "Midnight", description = "Black felt, blue trim, pale dice",
    table = gfx.COLOR_BLACK, panel = gfx.COLOR_DARK_BLUE,
    frame = gfx.COLOR_BLUE, accent = gfx.COLOR_PINK,
    secondary = gfx.COLOR_WHITE, die = gfx.COLOR_WHITE,
  },
  {
    id = "plum", name = "Plum Velvet", description = "Purple felt, pink trim, peach accents",
    table = gfx.COLOR_DARK_PURPLE, panel = gfx.COLOR_DARK_BLUE,
    frame = gfx.COLOR_PINK, accent = gfx.COLOR_PEACH,
    secondary = gfx.COLOR_WHITE, die = gfx.COLOR_PEACH,
  },
  {
    id = "golden", name = "Golden Hour", description = "Black felt, orange trim, golden dice",
    table = gfx.COLOR_BLACK, panel = gfx.COLOR_DARK_BLUE,
    frame = gfx.COLOR_ORANGE, accent = gfx.COLOR_YELLOW,
    secondary = gfx.COLOR_PEACH, die = gfx.COLOR_YELLOW,
  },
}

for _, theme in ipairs(Themes.options) do
  theme.text = gfx.COLOR_WHITE
  theme.muted = gfx.COLOR_LIGHT_GRAY
  theme.border = gfx.COLOR_LIGHT_GRAY
  theme.disabled = theme.panel
  theme.pip = gfx.COLOR_BLACK
  theme.die_fixed = gfx.COLOR_LIGHT_GRAY
  theme.die_selected = theme.id == "golden" and gfx.COLOR_WHITE or gfx.COLOR_YELLOW
  theme.ghost = gfx.COLOR_DARK_GRAY
  theme.ghost_pip = gfx.COLOR_WHITE
end

function Themes.get(id)
  for _, theme in ipairs(Themes.options) do
    if theme.id == id then return theme end
  end
  return Themes.options[1]
end

-- Transient drawing context only; selected identity is saved in application state.
local current
function Themes.use(id)
  current = Themes.get(id)
end

function Themes.colors()
  return current or Themes.options[1]
end

return Themes
