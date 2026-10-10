local Themes = {}

-- Palette colors only. Semantic ink colors keep text readable on each surface.
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
  {
    id = "forest", name = "Forest", description = "Black felt, green trim, leafy accents",
    table = gfx.COLOR_BLACK, panel = gfx.COLOR_DARK_BLUE,
    frame = gfx.COLOR_DARK_GREEN, accent = gfx.COLOR_GREEN,
    secondary = gfx.COLOR_WHITE, die = gfx.COLOR_GREEN,
  },
  {
    id = "cyberpunk", name = "Cyberpunk", description = "Midnight felt, neon pink and green",
    table = gfx.COLOR_DARK_BLUE, panel = gfx.COLOR_BLACK,
    frame = gfx.COLOR_PINK, accent = gfx.COLOR_GREEN,
    secondary = gfx.COLOR_PINK, die = gfx.COLOR_YELLOW,
  },
  {
    -- Keep the saved identity so Candyland owners retain their selection.
    id = "candyland", name = "Sketchbook", description = "White pages, pencil gray, blue ink",
    table = gfx.COLOR_WHITE, panel = gfx.COLOR_LIGHT_GRAY,
    frame = gfx.COLOR_DARK_GRAY, accent = gfx.COLOR_DARK_BLUE,
    text = gfx.COLOR_BLACK, secondary = gfx.COLOR_DARK_BLUE,
    muted = gfx.COLOR_DARK_BLUE, border = gfx.COLOR_DARK_BLUE,
    die = gfx.COLOR_WHITE,
  },
  {
    id = "ocean", name = "Ocean", description = "Deep blue felt, pale dice, white foam",
    table = gfx.COLOR_DARK_BLUE, panel = gfx.COLOR_BLACK,
    frame = gfx.COLOR_BLUE, accent = gfx.COLOR_WHITE,
    secondary = gfx.COLOR_LIGHT_GRAY, die = gfx.COLOR_WHITE,
  },
  {
    id = "paper", name = "Paper", description = "Cream paper, white panels, dark ink",
    table = gfx.COLOR_PEACH, panel = gfx.COLOR_WHITE,
    frame = gfx.COLOR_LIGHT_GRAY, accent = gfx.COLOR_DARK_BLUE,
    text = gfx.COLOR_BLACK, secondary = gfx.COLOR_DARK_PURPLE,
    muted = gfx.COLOR_DARK_BLUE, border = gfx.COLOR_DARK_BLUE,
    die = gfx.COLOR_WHITE,
  },
  {
    id = "dark", name = "Dark", description = "Black felt, charcoal trim, silver dice",
    table = gfx.COLOR_BLACK, panel = gfx.COLOR_BLACK,
    frame = gfx.COLOR_DARK_GRAY, accent = gfx.COLOR_WHITE,
    secondary = gfx.COLOR_LIGHT_GRAY, die = gfx.COLOR_LIGHT_GRAY,
  },
  {
    id = "blueprint", name = "Blueprint", description = "Blue drafting sheet, white lines, yellow marks",
    table = gfx.COLOR_DARK_BLUE, panel = gfx.COLOR_DARK_BLUE,
    frame = gfx.COLOR_BLUE, accent = gfx.COLOR_YELLOW,
    text = gfx.COLOR_WHITE, secondary = gfx.COLOR_WHITE,
    muted = gfx.COLOR_LIGHT_GRAY, border = gfx.COLOR_WHITE,
    die = gfx.COLOR_WHITE,
  },
}

for _, theme in ipairs(Themes.options) do
  theme.text = theme.text or gfx.COLOR_WHITE
  theme.muted = theme.muted or gfx.COLOR_LIGHT_GRAY
  theme.border = theme.border or gfx.COLOR_LIGHT_GRAY
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
