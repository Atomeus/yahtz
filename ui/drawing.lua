local Drawing = {}

function Drawing.text(value, x, y, color)
  gfx.text(tostring(value), x, y, color or gfx.COLOR_WHITE)
end

function Drawing.die(face, x, y, size, selected, fixed, ghost)
  gfx.rect_fill(x + 2, y + 3, size, size, gfx.COLOR_DARK_BLUE)
  local fill = ghost and gfx.COLOR_DARK_GRAY or (selected and gfx.COLOR_YELLOW or (fixed and gfx.COLOR_LIGHT_GRAY or gfx.COLOR_PEACH))
  gfx.rect_fill(x, y, size, size, fill)
  gfx.rect(x, y, size, size, gfx.COLOR_BROWN)
  local dots = { {5}, {1,9}, {1,5,9}, {1,3,7,9}, {1,3,5,7,9}, {1,3,4,6,7,9} }
  for _, p in ipairs(dots[face] or {}) do
    local col, row = (p - 1) % 3, math.floor((p - 1) / 3)
    gfx.rect_fill(x + math.floor(size * (0.23 + col * 0.23)), y + math.floor(size * (0.23 + row * 0.23)), 3, 3, ghost and gfx.COLOR_LIGHT_GRAY or gfx.COLOR_DARK_BLUE)
  end
end

function Drawing.sound(name, pitch)
  sfx.play_ex(name, 0.45, pitch or 1, 0)
end


return Drawing
