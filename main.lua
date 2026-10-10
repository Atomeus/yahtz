local JOKERS = {
  { id = "pair_pay", name = "PAIR PAY", text = "+10 for every repeated face", hint = "Pairs and triples all pay." },
  { id = "short_run", name = "SHORT RUN", text = "Any four distinct faces: 30", hint = "Build little runs your own way." },
  { id = "thrifty", name = "THRIFTY", text = "+5 for each unused roll", hint = "Keep your rolls. Keep the change." },
}
local BOARD_X, BOARD_Y, CELL = 24, 49, 39

function _config()
  return { name = "Yahtz - The little dice table", game_id = "com.ethan.yahtz", game_width = 480, game_height = 270, pixel_perfect = true }
end

local function save()
  usagi.save({ session = State.session and State.session:snapshot(), reduced_motion = State.reduced_motion, ledger = State.ledger })
end

function _init()
  local saved = usagi.load() or {}
  State = { screen = "jokers", focus = 1, time = 0, reduced_motion = saved.reduced_motion or false, selected = 1, buttons = {}, events = {}, event_index = 1, event_timer = 0, ledger_offset = 1, ledger = saved.ledger or {} }
  if saved.session then
    local ok, session = pcall(function() return require("game.session").resume(saved.session) end)
    if ok and session then State.session, State.screen = session, "game" end
  end
end

local function text(value, x, y, color)
  gfx.text(tostring(value), x, y, color or gfx.COLOR_WHITE)
end

local function draw_die(face, x, y, size, selected, fixed)
  gfx.rect_fill(x + 2, y + 3, size, size, gfx.COLOR_DARK_BLUE)
  gfx.rect_fill(x, y, size, size, selected and gfx.COLOR_YELLOW or (fixed and gfx.COLOR_LIGHT_GRAY or gfx.COLOR_PEACH))
  gfx.rect(x, y, size, size, gfx.COLOR_BROWN)
  local dots = { {5}, {1,9}, {1,5,9}, {1,3,7,9}, {1,3,5,7,9}, {1,3,4,6,7,9} }
  for _, p in ipairs(dots[face] or {}) do
    local col, row = (p - 1) % 3, math.floor((p - 1) / 3)
    gfx.rect_fill(x + math.floor(size * (0.23 + col * 0.23)), y + math.floor(size * (0.23 + row * 0.23)), 3, 3, gfx.COLOR_DARK_BLUE)
  end
end

local function sound(name, pitch)
  sfx.play_ex(name, 0.45, pitch or 1, 0)
end

local function start(joker)
  State.session = require("game.session").new(joker, math.floor(usagi.elapsed * 1000000) + os.time())
  State.screen, State.focus, State.selected = "game", 26, 1
  State.events, State.ledger = {}, {}
  save()
end

local function act(method, ...)
  local ok, err = State.session[method](State.session, ...)
  State.message = err
  if ok then sound("clack"); State.bounce = State.time end
  return ok
end

local function finish_scoring()
  State.session:finish_scoring()
  State.event_index = #State.events + 1
  State.focus = 26
  save()
end

local function button(id, x, y, w, h, label, callback, enabled)
  State.buttons[#State.buttons + 1] = { id = id, x = x, y = y, w = w, h = h, callback = callback, enabled = enabled ~= false }
  if label then
    gfx.rect_fill(x, y, w, h, enabled == false and gfx.COLOR_BROWN or gfx.COLOR_DARK_BLUE)
    gfx.rect(x, y, w, h, State.focus == id and gfx.COLOR_YELLOW or gfx.COLOR_BROWN)
    text(label, x + 5, y + math.floor((h - 15) / 2), enabled == false and gfx.COLOR_LIGHT_GRAY or gfx.COLOR_PEACH)
  elseif State.focus == id then
    gfx.rect(x - 1, y - 1, w + 2, h + 2, gfx.COLOR_YELLOW)
  end
end

local function scroll_ledger(delta, event_count, visible_count)
  State.ledger_offset = math.max(1, math.min(math.max(1, event_count - visible_count + 1), State.ledger_offset + delta))
end

local function move_focus(dx, dy)
  local current
  for _, b in ipairs(State.buttons or {}) do if b.id == State.focus then current = b end end
  if not current then State.focus = State.buttons and State.buttons[1] and State.buttons[1].id or 1; return end
  local cx, cy = current.x + current.w / 2, current.y + current.h / 2
  local best, distance
  for _, b in ipairs(State.buttons or {}) do
    local vx, vy = b.x + b.w / 2 - cx, b.y + b.h / 2 - cy
    local along, across = vx * dx + vy * dy, math.abs(vx * dy - vy * dx)
    local score = along + across * 3
    if b.enabled and along > 1 and (not distance or score < distance) then best, distance = b, score end
  end
  if best then State.focus = best.id end
end

function _update(dt)
  State.time = State.time + dt
  if input.pressed(input.LEFT) then move_focus(-1, 0) end
  if input.pressed(input.RIGHT) then move_focus(1, 0) end
  if input.pressed(input.UP) then move_focus(0, -1) end
  if input.pressed(input.DOWN) then move_focus(0, 1) end
  local mx, my = input.mouse()
  local click = input.mouse_pressed(input.MOUSE_LEFT)
  for _, b in ipairs(State.buttons or {}) do
    local hit = click and mx >= b.x and mx < b.x + b.w and my >= b.y and my < b.y + b.h
    if b.enabled and (hit or (b.id == State.focus and input.pressed(input.BTN1))) then
      State.focus = b.id
      b.callback()
      break
    end
  end
  if State.session then
    local view = State.session:view()
    if view.phase == "resolving" then
      State.event_timer = State.event_timer + dt
      if input.pressed(input.BTN3) then finish_scoring()
      elseif State.event_timer > (State.reduced_motion and 1.15 or 0.85) then
        State.event_timer = 0
        State.event_index = State.event_index + 1
        State.ledger_offset = math.max(1, State.event_index - 5)
        sound("score", 1 + math.min(State.event_index, 12) * 0.07)
        if State.event_index > #State.events then finish_scoring() end
      end
    elseif input.pressed(input.BTN2) and view.phase ~= "results" then act("undo") end
  end
end

local function draw_jokers()
  text("YAHTZ", 26, 27, gfx.COLOR_YELLOW)
  text("THE LITTLE DICE TABLE", 26, 41, gfx.COLOR_PEACH)
  for row = 0, 4 do
    for col = 0, 4 do
      local x, y = 27 + col * 35, 68 + row * 35
      gfx.rect_fill(x, y, 31, 31, gfx.COLOR_DARK_BLUE)
      if row == col or row + col == 4 then draw_die((row + col) % 6 + 1, x + 2, y + 2, 26, false) end
    end
  end
  text("FIVE TURNS. TEN LINES.", 26, 242, gfx.COLOR_PEACH)
  text("PICK YOUR JOKER", 222, 48, gfx.COLOR_YELLOW)
  for i, joker in ipairs(JOKERS) do
    local y = 70 + (i - 1) * 51
    button(i, 220, y, 242, 45, "", function() start(joker.id) end)
    text(joker.name, 229, y + 5, gfx.COLOR_YELLOW)
    text(joker.text, 229, y + 18)
    text(joker.hint, 229, y + 30, gfx.COLOR_PEACH)
  end
  text("Mouse / directions + " .. (input.mapping_for(input.BTN1) or "?"), 222, 233, gfx.COLOR_PEACH)
  button(4, 222, 245, 240, 11, "Motion: " .. (State.reduced_motion and "reduced" or "bouncy"), function() State.reduced_motion = not State.reduced_motion; save() end)
end

local function joker_name(id)
  for _, j in ipairs(JOKERS) do if j.id == id then return j.name end end
  return id
end

local function event_text(event)
  local amount = event.points
  local name = event.category or event.joker or event.kind
  local line = event.line or ""
  line = line:gsub("column", "C"):gsub("row", "R")
  return tostring(line) .. " " .. tostring(name):gsub("four_of_a_kind", "4 of a kind"):gsub("three_of_a_kind", "3 of a kind"):gsub("_", " "), amount
end

local function draw_ledger(events, x, y, count, active)
  if #events == 0 then text("No completed lines yet", x, y, gfx.COLOR_LIGHT_GRAY); return end
  local offset = math.min(State.ledger_offset, math.max(1, #events - count + 1))
  for i = offset, math.min(#events, offset + count - 1) do
    local name, amount = event_text(events[i])
    local color = i == active and gfx.COLOR_YELLOW or gfx.COLOR_PEACH
    text(name:sub(1, 28), x, y, color)
    text("+" .. amount, x + 185, y, color)
    y = y + 12
  end
end

local function draw_game()
  local view = State.session:view()
  local locked = view.phase == "resolving" or view.phase == "results"
  text("YAHTZ", 24, 20, gfx.COLOR_YELLOW)
  text("TURN " .. math.min(view.turn, 5) .. " / 5", 102, 20, gfx.COLOR_PEACH)
  text(tostring(view.score) .. " POINTS", 242, 20, gfx.COLOR_YELLOW)
  text(joker_name(view.joker), 354, 20, gfx.COLOR_PEACH)
  for cell = 1, 25 do
    local x, y = BOARD_X + ((cell - 1) % 5) * CELL, BOARD_Y + math.floor((cell - 1) / 5) * CELL
    gfx.rect_fill(x, y, 35, 35, gfx.COLOR_DARK_BLUE)
    local current
    for i = 1, 5 do if view.placements[i] == cell then current = i end end
    local face = view.board[cell]
    if current then face = view.dice[current] end
    if face and face > 0 then draw_die(face, x + 3, y + 3, 28, current == State.selected, not current) end
    button(cell, x, y, 35, 35, nil, function()
      if current then State.selected = current; act("unplace", current)
      else
        if act("place", State.selected, cell) then
          local fresh = State.session:view()
          for i = 1, 5 do if fresh.placements[i] == 0 then State.selected = i; break end end
        end
      end
    end, view.phase == "placing" and (current ~= nil or not face or face == 0))
  end
  text(view.phase == "rolling" and "CLICK DICE TO HOLD" or "SELECT DIE, THEN CELL", 242, 43, gfx.COLOR_PEACH)
  local bounce = not State.reduced_motion and State.bounce and math.max(0, 1 - (State.time - State.bounce) * 5) * 3 or 0
  for i = 1, 5 do
    local x, y = 242 + (i - 1) * 44, 61 - math.floor(bounce)
    draw_die(view.dice[i], x, y, 32, State.selected == i, view.placements[i] ~= 0)
    button(25 + i, x, y, 32, 32, nil, function()
      State.selected = i
      if view.phase == "rolling" then act("toggle_hold", i) end
    end, not locked)
    if view.held[i] then text("HELD", x + 3, 97, gfx.COLOR_YELLOW)
    elseif view.placements[i] ~= 0 then text("SET", x + 5, 97, gfx.COLOR_LIGHT_GRAY) end
  end
  if locked then
    text((input.mapping_for(input.BTN1) or "?") .. ": select  " .. (input.mapping_for(input.BTN3) or "?") .. ": skip / Esc: menu", 24, 243, gfx.COLOR_PEACH)
    text(view.phase == "results" and "BOARD COMPLETE!" or "COUNTING THE TABLE", 242, 118, gfx.COLOR_YELLOW)
    draw_ledger(view.phase == "results" and State.ledger or State.events, 242, 138, 6, view.phase == "resolving" and State.event_index or nil)
    button(31, 242, 214, 102, 19, "Earlier", function() scroll_ledger(-1, #(view.phase == "results" and State.ledger or State.events), 6) end)
    button(32, 350, 214, 110, 19, "Later", function() scroll_ledger(1, #(view.phase == "results" and State.ledger or State.events), 6) end)
    button(33, 242, 237, 218, 18, view.phase == "results" and "Play again" or "Speed through", function()
      if view.phase == "results" then State.session = nil; State.screen = "jokers"; State.focus = 1; save()
      else finish_scoring() end
    end)
    return
  end
  button(31, 242, 112, 105, 20, "Roll (" .. (3 - view.rolls_used) .. " left)", function() act("roll") end, view.phase == "rolling" and view.rolls_used < 3)
  button(32, 353, 112, 107, 20, "Place dice", function() act("begin_placement") end, view.phase == "rolling")
  text("ADJUSTMENTS: " .. view.adjustments, 242, 139, gfx.COLOR_PEACH)
  local can_adjust = view.phase == "placing" and view.placements[State.selected] == 0 and view.adjustments > 0
  button(33, 242, 151, 46, 18, "-1", function() act("adjust", State.selected, -1) end, can_adjust and view.dice[State.selected] > 1)
  button(34, 293, 151, 46, 18, "+1", function() act("adjust", State.selected, 1) end, can_adjust and view.dice[State.selected] < 6)
  button(35, 345, 151, 115, 18, "Undo", function() act("undo") end)
  local preview = State.session:preview()
  text("PREVIEW", 242, 178, gfx.COLOR_YELLOW)
  button(38, 350, 175, 50, 11, "Prev", function() scroll_ledger(-1, #preview.events, 3) end)
  button(39, 405, 175, 55, 11, "Next", function() scroll_ledger(1, #preview.events, 3) end)
  if preview then
    draw_ledger(preview.events, 242, 191, 3)
    text("Result: " .. tostring(preview.total), 242, 228, gfx.COLOR_PEACH)
  end
  local all_placed = true
  for i = 1, 5 do if view.placements[i] == 0 then all_placed = false end end
  button(36, 353, 224, 107, 18, "Confirm turn", function()
    local events, err = State.session:confirm()
    if events then
      State.events, State.event_index, State.event_timer, State.ledger_offset = events, 1, 0, 1
      for _, event in ipairs(events) do State.ledger[#State.ledger + 1] = event end
      save(); sound("score")
    else State.message = err end
  end, view.phase == "placing" and all_placed)
  button(37, 242, 245, 218, 11, "Motion: " .. (State.reduced_motion and "reduced" or "bouncy"), function() State.reduced_motion = not State.reduced_motion; save() end)
  text(State.message and tostring(State.message):sub(1, 33) or ((input.mapping_for(input.BTN1) or "?") .. ": select  " .. (input.mapping_for(input.BTN2) or "?") .. ": undo  Esc: menu"), 24, 243, gfx.COLOR_PEACH)
end

function _draw()
  State.buttons = {}
  gfx.clear(gfx.COLOR_DARK_BLUE)
  gfx.rect_fill(8, 8, 464, 254, gfx.COLOR_BROWN)
  gfx.rect_fill(12, 12, 456, 246, gfx.COLOR_DARK_GREEN)
  if State.screen == "jokers" then draw_jokers() else draw_game() end
end
