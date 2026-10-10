-- Contrast checks use the engine's documented default Pico-8 palette.
local names = {"BLACK", "DARK_BLUE", "DARK_PURPLE", "DARK_GREEN", "BROWN",
  "DARK_GRAY", "LIGHT_GRAY", "WHITE", "RED", "ORANGE", "YELLOW", "GREEN",
  "BLUE", "INDIGO", "PINK", "PEACH"}
gfx = {}
for i, name in ipairs(names) do gfx["COLOR_" .. name] = i end
local rgb = {
  "000000", "1d2b53", "7e2553", "008751", "ab5236", "5f574f", "c2c3c7", "fff1e8",
  "ff004d", "ffa300", "ffec27", "00e436", "29adff", "83769c", "ff77a8", "ffccaa",
}
local function luminance(index)
  local channels = {}
  for i = 1, 3 do
    local value = tonumber(rgb[index]:sub(i * 2 - 1, i * 2), 16) / 255
    channels[i] = value <= 0.04045 and value / 12.92 or ((value + 0.055) / 1.055) ^ 2.4
  end
  return channels[1] * 0.2126 + channels[2] * 0.7152 + channels[3] * 0.0722
end
local function contrast(foreground, background)
  local a, b = luminance(foreground), luminance(background)
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05)
end
local Themes = require("ui.themes")
assert(Themes.get(nil).id == "classic")
assert(Themes.get("obsolete").id == "classic")
for _, theme in ipairs(Themes.options) do
  Themes.use(theme.id)
  assert(Themes.colors().id == theme.id)
  for _, surface in ipairs({"table", "panel", "disabled"}) do
    for _, role in ipairs({"text", "secondary", "muted", "accent"}) do
      assert(contrast(theme[role], theme[surface]) >= 4.5,
        theme.id .. ": insufficient contrast for " .. role .. " on " .. surface)
    end
    assert(contrast(theme.accent, theme[surface]) >= 3, "Focus must be visible")
    assert(contrast(theme.border, theme[surface]) >= 3, "Control borders must be visible")
  end
  for _, role in ipairs({"die", "die_fixed", "die_selected"}) do
    assert(contrast(theme.pip, theme[role]) >= 4.5, "Dice faces must remain readable")
  end
  assert(contrast(theme.ghost_pip, theme.ghost) >= 4.5)
end
print("all theme text/pip pairs >= 4.5:1; focus/borders >= 3:1; fallback passed")
