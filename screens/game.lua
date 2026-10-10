local Drawing = require("ui.drawing")
local Controls = require("ui.controls")
local text, sound = Drawing.text, Drawing.sound
local JOKERS = require("game.jokers")
local draw_die = Drawing.die
local BOARD_X, BOARD_Y, CELL = 42, 53, 36
local GameScreen = {}

local function act(state, method, ...)
  local ok, err = state.session[method](state.session, ...)
  state.message = err
  if ok then sound("clack"); state.bounce = state.time end
  return ok
end

local function finish_scoring(state, save, offer_high_score)
  state.session:finish_scoring()
  state.event_index = #state.events + 1
  state.focus = 26
  save()
  offer_high_score()
end

local function scroll_ledger(state, delta, event_count, visible_count)
  state.ledger_offset = math.max(1, math.min(math.max(1, event_count - visible_count + 1), state.ledger_offset + delta))
end

function GameScreen.update(state, dt, save, offer_high_score)
  local view = state.session:view()
  if view.phase == "resolving" then
    state.event_timer = state.event_timer + dt
    if input.pressed(input.BTN3) then finish_scoring(state, save, offer_high_score)
    elseif state.event_timer > (state.reduced_motion and 1.15 or 0.85) then
      state.event_timer = 0
      state.event_index = state.event_index + 1
      state.ledger_offset = math.max(1, state.event_index - 5)
      sound("score", 1 + math.min(state.event_index, 12) * 0.07)
      if state.event_index > #state.events then finish_scoring(state, save, offer_high_score) end
    end
  elseif input.pressed(input.BTN2) and view.phase ~= "results" then act(state, "undo") end
end

local function joker_name(id)
  for _, j in ipairs(JOKERS) do if j.id == id then return j.name end end
  return id
end

local function event_text(event, turn)
  local name = event.category or event.joker or event.kind
  name = name:gsub("four_of_a_kind", "4 of a kind"):gsub("three_of_a_kind", "3 of a kind"):gsub("_", " ")
  if event.kind == "joker" then name = name .. " bonus" end
  local line = event.line and event.line:gsub("column", "Col "):gsub("row", "Row ")
  local prefix = (event.turn or turn) and ("T" .. (event.turn or turn) .. " ") or ""
  return prefix .. (line and (line .. ": ") or "Turn: ") .. name, event.points
end

local function draw_ledger(state, events, x, y, count, active, turn)
  if #events == 0 then text("No completed lines yet", x, y, gfx.COLOR_LIGHT_GRAY); return end
  local offset = math.min(state.ledger_offset, math.max(1, #events - count + 1))
  for i = offset, math.min(#events, offset + count - 1) do
    local name, amount = event_text(events[i], turn)
    local color = i == active and gfx.COLOR_YELLOW or gfx.COLOR_PEACH
    text(name:sub(1, 30), x, y, color)
    text("+" .. amount, x + 185, y, color)
    y = y + 12
  end
end

function GameScreen.draw(state, navigate, save, offer_high_score, toggle_motion)
  local function button(...) return Controls.button(state, ...) end
  local view = state.session:view()
  local locked = view.phase == "resolving" or view.phase == "results"
  text("YAHTZ", 24, 20, gfx.COLOR_YELLOW)
  text("TURN " .. math.min(view.turn, 5) .. " / 5", 102, 20, gfx.COLOR_PEACH)
  local shown_score = view.score
  if view.phase == "resolving" then
    -- The saved score is already committed; only its presentation counts up.
    for i = state.event_index, #state.events do shown_score = shown_score - state.events[i].points end
    local event = state.events[state.event_index]
    if event and not state.reduced_motion then
      shown_score = shown_score + math.floor(event.points * math.min(1, state.event_timer / 0.65))
    end
  end
  text(tostring(shown_score) .. " POINTS", 242, 20, gfx.COLOR_YELLOW)
  text(joker_name(view.joker), 354, 20, gfx.COLOR_PEACH)
  local active_event = view.phase == "resolving" and state.events[state.event_index]
  for line = 1, 5 do
    local row_active = active_event and active_event.line == "row" .. line
    local col_active = active_event and active_event.line == "column" .. line
    text("C" .. line, BOARD_X + (line - 1) * CELL + 10, BOARD_Y - 18,
      col_active and gfx.COLOR_YELLOW or gfx.COLOR_PEACH)
    text("R" .. line, BOARD_X - 22, BOARD_Y + (line - 1) * CELL + 10,
      row_active and gfx.COLOR_YELLOW or gfx.COLOR_PEACH)
  end
  for cell = 1, 25 do
    local x, y = BOARD_X + ((cell - 1) % 5) * CELL, BOARD_Y + math.floor((cell - 1) / 5) * CELL
    gfx.rect_fill(x, y, 35, 35, gfx.COLOR_DARK_BLUE)
    local current
    for i = 1, 5 do if view.placements[i] == cell then current = i end end
    local face = view.board[cell]
    if current then face = view.dice[current] end
    if face and face > 0 then draw_die(face, x + 3, y + 3, 28, current == state.selected, not current) end
    button(cell, x, y, 35, 35, nil, function()
      if current then state.selected = current; act(state, "unplace", current)
      else
        if act(state, "place", state.selected, cell) then
          local fresh = state.session:view()
          for i = 1, 5 do if fresh.placements[i] == 0 then state.selected = i; break end end
        end
      end
    end, view.phase == "placing" and (current ~= nil or not face or face == 0))
  end
  text(view.phase == "rolling" and "CLICK DICE TO HOLD" or "SELECT DIE, THEN CELL", 242, 43, gfx.COLOR_PEACH)
  local bounce = not state.reduced_motion and state.bounce and math.max(0, 1 - (state.time - state.bounce) * 5) * 3 or 0
  for i = 1, 5 do
    local x, y = 242 + (i - 1) * 44, 61 - math.floor(bounce)
    local placed = view.placements[i] ~= 0
    draw_die(view.dice[i], x, y, 32, state.selected == i, false, placed)
    button(25 + i, x, y, 32, 32, nil, function()
      state.selected = i
      if view.phase == "rolling" then act(state, "toggle_hold", i) end
    end, not locked)
    if placed then text("PLACED", x - 2, 97, gfx.COLOR_LIGHT_GRAY)
    elseif view.phase == "rolling" and view.held[i] then text("HELD", x + 3, 97, gfx.COLOR_YELLOW)
    elseif view.phase == "placing" then text("READY", x + 1, 97, gfx.COLOR_PEACH) end
  end
  if locked then
    text((input.mapping_for(input.BTN1) or "?") .. ": select  " .. (input.mapping_for(input.BTN3) or "?") .. ": skip / Esc: menu", 24, 243, gfx.COLOR_PEACH)
    text(view.phase == "results" and "BOARD COMPLETE!" or "COUNTING THE TABLE", 242, 118, gfx.COLOR_YELLOW)
    draw_ledger(state, view.phase == "results" and state.ledger or state.events, 242, 138, 6, view.phase == "resolving" and state.event_index or nil, view.phase == "resolving" and view.turn or nil)
    button(31, 242, 214, 102, 19, "Earlier", function() scroll_ledger(state, -1, #(view.phase == "results" and state.ledger or state.events), 6) end)
    button(32, 350, 214, 110, 19, "Later", function() scroll_ledger(state, 1, #(view.phase == "results" and state.ledger or state.events), 6) end)
    button(33, 242, 237, 218, 18, view.phase == "results" and "Main menu" or "Speed through", function()
      if view.phase == "results" then navigate("menu", 1); save()
      else finish_scoring(state, save, offer_high_score) end
    end)
    return
  end
  button(31, 242, 112, 105, 20, "Roll (" .. (3 - view.rolls_used) .. " left)", function() act(state, "roll") end, view.phase == "rolling" and view.rolls_used < 3)
  button(32, 353, 112, 107, 20, "Place dice", function() act(state, "begin_placement") end, view.phase == "rolling")
  text("ADJUSTMENTS: " .. view.adjustments, 242, 139, gfx.COLOR_PEACH)
  local can_adjust = view.phase == "placing" and view.placements[state.selected] == 0 and view.adjustments > 0
  button(33, 242, 151, 46, 18, "-1", function() act(state, "adjust", state.selected, -1) end, can_adjust and view.dice[state.selected] > 1)
  button(34, 293, 151, 46, 18, "+1", function() act(state, "adjust", state.selected, 1) end, can_adjust and view.dice[state.selected] < 6)
  button(35, 345, 151, 115, 18, "Undo", function() act(state, "undo") end)
  local preview = state.session:preview()
  text("PREVIEW", 242, 178, gfx.COLOR_YELLOW)
  button(38, 350, 175, 50, 11, "Prev", function() scroll_ledger(state, -1, #preview.events, 3) end)
  button(39, 405, 175, 55, 11, "Next", function() scroll_ledger(state, 1, #preview.events, 3) end)
  if preview then
    draw_ledger(state, preview.events, 242, 191, 3, nil, view.turn)
    text("Result: " .. tostring(preview.total), 242, 228, gfx.COLOR_PEACH)
  end
  local all_placed = true
  for i = 1, 5 do if view.placements[i] == 0 then all_placed = false end end
  button(36, 353, 224, 107, 18, "Confirm turn", function()
    local events, err = state.session:confirm()
    if events then
      state.events, state.event_index, state.event_timer, state.ledger_offset = events, 1, 0, 1
      for _, event in ipairs(events) do
        event.turn = view.turn
        state.ledger[#state.ledger + 1] = event
      end
      save(); sound("score")
    else state.message = err end
  end, view.phase == "placing" and all_placed)
  button(37, 242, 245, 218, 11, "Motion: " .. (state.reduced_motion and "reduced" or "bouncy"), toggle_motion)
  text(state.message and tostring(state.message):sub(1, 33) or ((input.mapping_for(input.BTN1) or "?") .. ": select  " .. (input.mapping_for(input.BTN2) or "?") .. ": undo  Esc: menu"), 24, 243, gfx.COLOR_PEACH)
end

return GameScreen
