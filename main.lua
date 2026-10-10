local JOKERS = {
  { id = "pair_pay", name = "PAIR PAY", text = "+10 for every repeated face", hint = "Pairs, triples and more all pay." },
  { id = "short_run", name = "SHORT RUN", text = "Any four distinct faces: 30", hint = "Build little runs your own way." },
  { id = "thrifty", name = "THRIFTY", text = "+5 for each unused roll", hint = "Keep your first roll. Keep the change." },
}

function _config()
  return { name = "Yahtz - The little dice table", game_id = "com.ethan.yahtz", game_width = 480, game_height = 270, pixel_perfect = true }
end

function _init()
  State = { screen = "jokers", focus = 1, time = 0, reduced_motion = false }
end

local function text(value, x, y, color)
  gfx.text(value, x, y, color or gfx.COLOR_WHITE)
end

local function die(face, x, y, size, selected)
  gfx.rect_fill(x + 2, y + 3, size, size, gfx.COLOR_DARK_BLUE)
  gfx.rect_fill(x, y, size, size, selected and gfx.COLOR_YELLOW or gfx.COLOR_PEACH)
  gfx.rect(x, y, size, size, gfx.COLOR_BROWN)
  local dots = { {5}, {1,9}, {1,5,9}, {1,3,7,9}, {1,3,5,7,9}, {1,3,4,6,7,9} }
  for _, p in ipairs(dots[face]) do
    local col, row = (p - 1) % 3, math.floor((p - 1) / 3)
    gfx.rect_fill(x + math.floor(size * (0.23 + col * 0.23)), y + math.floor(size * (0.23 + row * 0.23)), 3, 3, gfx.COLOR_DARK_BLUE)
  end
end

function _update(dt)
  State.time = State.time + dt
  if input.pressed(input.UP) then State.focus = (State.focus + 1) % 3 + 1 end
  if input.pressed(input.DOWN) then State.focus = State.focus % 3 + 1 end
  local mx, my = input.mouse()
  if input.mouse_pressed(input.MOUSE_LEFT) and mx >= 220 and mx < 462 and my >= 70 and my < 223 then
    State.focus = math.min(3, math.floor((my - 70) / 51) + 1)
  end
end

function _draw()
  gfx.clear(gfx.COLOR_DARK_BLUE)
  gfx.rect_fill(8, 8, 464, 254, gfx.COLOR_BROWN)
  gfx.rect_fill(12, 12, 456, 246, gfx.COLOR_DARK_GREEN)
  text("YAHTZ", 26, 27, gfx.COLOR_YELLOW)
  text("THE LITTLE DICE TABLE", 26, 41, gfx.COLOR_PEACH)
  for row = 0, 4 do
    for col = 0, 4 do
      local x, y = 27 + col * 35, 68 + row * 35
      gfx.rect_fill(x, y, 31, 31, gfx.COLOR_DARK_BLUE)
      if row == col or row + col == 4 then die((row + col) % 6 + 1, x + 2, y + 2, 26, false) end
    end
  end
  text("FIVE TURNS. TEN LINES.", 26, 247, gfx.COLOR_PEACH)
  text("PICK YOUR JOKER", 222, 48, gfx.COLOR_YELLOW)
  for i, joker in ipairs(JOKERS) do
    local y = 70 + (i - 1) * 51
    gfx.rect_fill(220, y, 242, 45, i == State.focus and gfx.COLOR_DARK_BLUE or gfx.COLOR_BROWN)
    if i == State.focus then gfx.rect(220, y, 242, 45, gfx.COLOR_YELLOW) end
    text(joker.name, 229, y + 5, gfx.COLOR_YELLOW)
    text(joker.text, 229, y + 18)
    text(joker.hint, 229, y + 30, gfx.COLOR_PEACH)
  end
  text("Choose with mouse or direction actions", 222, 233, gfx.COLOR_PEACH)
  text("Your table is nearly ready...", 222, 247)
end
