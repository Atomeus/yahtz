local Themes = require("ui.themes")
local Drawing = require("ui.drawing")
local Controls = require("ui.controls")
local text, sound = Drawing.text, Drawing.sound
local JOKERS = require("game.jokers")
local Lines = require("game.lines")
local draw_die = Drawing.die
local ScoreDisplay = require("ui.score_display")
local Feedback = require("ui.scoring_feedback")
local JokerDetails = require("screens.joker_details")
local EventDetails = require("screens.event_details")
local Objectives = require("game.events")
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

local function close_joker_details(state)
  state.joker_info = false
  state.focus = 41
end

local function close_event_details(state)
  state.focus = state.event_info == "board" and 43 or 44
  state.event_info = nil
end

function GameScreen.update(state, dt, save, offer_high_score)
  if state.event_info then
    if input.pressed(input.BTN2) then close_event_details(state) end
    return
  end
  if state.joker_info then
    if input.pressed(input.BTN2) then close_joker_details(state) end
    return
  end
  local view = state.session:view()
  if view.phase == "resolving" then
    state.event_timer = state.event_timer + dt
    if input.pressed(input.BTN3) then finish_scoring(state, save, offer_high_score)
    elseif state.event_timer > Feedback.duration then
      state.event_timer = 0
      state.event_index = state.event_index + 1
      state.ledger_offset = math.max(1, state.event_index - 5)
      sound("score", 1 + math.min(state.event_index, 12) * 0.07)
      if state.event_index > #state.events then finish_scoring(state, save, offer_high_score) end
    end
  elseif input.pressed(input.BTN2) and view.phase ~= "results" then act(state, "undo") end
end

local function joker_name(id)
  local joker = JOKERS.get(id)
  return joker and joker.name or id
end

local function event_text(event, turn)
  if event.kind == "event" then
    return "T" .. (event.turn or turn or "?") .. " " .. event.label, event.points
  end
  local name = event.category or event.joker or event.kind
  name = name:gsub("four_of_a_kind", "4 of a kind"):gsub("three_of_a_kind", "3 of a kind"):gsub("_", " ")
  if event.kind == "joker" then name = name .. " bonus" end
  local line = event.line and Lines.label(event.line)
  local prefix = (event.turn or turn) and ("T" .. (event.turn or turn) .. " ") or ""
  return prefix .. (line and (line .. ": ") or (event.scope == "board" and "Board: " or "Turn: ")) .. name, event.points
end

local function draw_ledger(state, events, x, y, count, active, turn)
  local colors = Themes.colors()
  if #events == 0 then text("No completed lines yet", x, y, colors.muted); return end
  local offset = math.min(state.ledger_offset, math.max(1, #events - count + 1))
  for i = offset, math.min(#events, offset + count - 1) do
    local name, amount = event_text(events[i], turn)
    local color = i == active and colors.accent or colors.secondary
    text(name:sub(1, 30), x, y, color)
    text("+" .. amount, x + 185, y, color)
    y = y + 12
  end
end

function GameScreen.draw(state, navigate, save, offer_high_score)
  local colors = Themes.colors()
  local function button(...) return Controls.button(state, ...) end
  local view = state.session:view()
  if state.event_info and view.objectives then
    EventDetails.draw(state, state.event_info, state.event_info == "board" and view.objectives.board or view.objectives.active, function() close_event_details(state) end)
    return
  end
  if state.joker_info then
    JokerDetails.draw(state, view.joker, function() close_joker_details(state) end)
    return
  end
  local locked = view.phase == "resolving" or view.phase == "results"
  button(46, 20, 14, 74, 22, nil, function()
    sound("click")
    state.game_menu_focus = 46
    navigate("menu", 2)
  end, true, false)
  local logo_focused = state.pointer_mode and state.hover == 46
    or not state.pointer_mode and state.focus == 46
  local logo_color = logo_focused and colors.text or colors.accent
  -- Draw the arrow with pixels so navigation does not depend on a font glyph.
  gfx.rect_fill(25, 24, 10, 2, logo_color)
  for offset = 0, 3 do
    gfx.rect_fill(25 + offset, 24 - offset, 2, 2, logo_color)
    gfx.rect_fill(25 + offset, 24 + offset, 2, 2, logo_color)
  end
  text("YAHTZ", 38, 17, logo_color)
  text("TURN " .. math.min(view.turn, 5) .. " / 5", 102, 20, colors.secondary)
  button(40, 242, 13, 56, 20, "Colors", function()
    navigate("themes", 1)
  end)
  ScoreDisplay.draw(state, view)
  button(41, 350, 18, 110, 20, joker_name(view.joker), function()
    state.joker_info, state.focus = true, 42
  end)
  local target
  if state.pointer_mode then target = state.hover else target = state.focus end
  local tentative
  if view.phase == "placing" and target and target >= 1 and target <= 25 then
    tentative = state.session:preview(state.selected, target)
  end
  local target_row = tentative and math.floor((target - 1) / 5) + 1
  local target_col = tentative and (target - 1) % 5 + 1
  local active_event = view.phase == "resolving" and state.events[state.event_index]
  if view.objectives then
    local objective_board = {}
    for cell = 1, 25 do objective_board[cell] = view.board[cell] end
    for die = 1, 5 do
      local cell = view.placements[die]
      if cell ~= 0 then objective_board[cell] = view.dice[die] end
    end
    if tentative then objective_board[target] = view.dice[state.selected] end
    local function event_color(id)
      local highlighted = state.pointer_mode and state.hover == id
        or not state.pointer_mode and state.focus == id
      return highlighted and colors.accent or colors.secondary
    end
    text(Objectives.board_label(objective_board, view.objectives.board), 24, 235, event_color(43))
    text("Turn: " .. Objectives.label(view.objectives.active) .. " ?", 24, 247, event_color(44))
    button(43, 24, 232, 198, 12, nil, function()
      sound("click")
      state.event_info, state.focus = "board", 45
    end, true, false)
    button(44, 24, 244, 198, 12, nil, function()
      sound("click")
      state.event_info, state.focus = "turn", 45
    end, true, false)
  end
  for line = 1, 5 do
    local marked = view.objectives and view.objectives.active.line
    local row_active = (active_event and active_event.line == "row" .. line) or marked == "row" .. line
    local col_active = (active_event and active_event.line == "column" .. line) or marked == "column" .. line
    text("C" .. line, BOARD_X + (line - 1) * CELL + 10, BOARD_Y - 18,
      (col_active or target_col == line) and colors.accent or colors.secondary)
    text("R" .. line, BOARD_X - 22, BOARD_Y + (line - 1) * CELL + 10,
      (row_active or target_row == line) and colors.accent or colors.secondary)
  end
  for cell = 1, 25 do
    local x, y = BOARD_X + ((cell - 1) % 5) * CELL, BOARD_Y + math.floor((cell - 1) / 5) * CELL
    gfx.rect_fill(x, y, 35, 35, colors.panel)
    local current
    for i = 1, 5 do if view.placements[i] == cell then current = i end end
    local face = view.board[cell]
    if current then face = view.dice[current] end
    if face and face > 0 then draw_die(face, x + 3, y + 3, 28, current == state.selected, not current) end
    Feedback.cell(state, active_event, cell, x, y, CELL,
      tentative and (math.floor((cell - 1) / 5) + 1 == target_row or (cell - 1) % 5 + 1 == target_col
        or (view.joker == "crossroads" and
          ((Lines.contains("diagonal1", target) and Lines.contains("diagonal1", cell))
            or (Lines.contains("diagonal2", target) and Lines.contains("diagonal2", cell))))))
    if tentative and cell == target then
      text("?" .. view.dice[state.selected], x + 10, y + 12, colors.accent)
    end
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
  text(view.phase == "rolling" and "CLICK DICE TO HOLD" or "SELECT DIE, THEN CELL", 242, 43, colors.secondary)
  local bounce = not state.reduced_motion and state.bounce and math.max(0, 1 - (state.time - state.bounce) * 5) * 3 or 0
  for i = 1, 5 do
    local x, y = 242 + (i - 1) * 44, 61 - math.floor(bounce)
    local placed = view.placements[i] ~= 0
    draw_die(view.dice[i], x, y, 32, state.selected == i, false, placed)
    button(25 + i, x, y, 32, 32, nil, function()
      state.selected = i
      if view.phase == "rolling" then act(state, "toggle_hold", i) end
    end, not locked)
    if placed then text("PLACED", x - 2, 97, colors.muted)
    elseif view.phase == "rolling" and view.held[i] then text("HELD", x + 3, 97, colors.accent)
    elseif view.phase == "placing" then text("READY", x + 1, 97, colors.secondary) end
  end
  if locked then
    if view.objectives then
      text((input.mapping_for(input.BTN3) or "?") .. ": speed through", 242, 245, colors.secondary)
    end
    if not view.objectives then text((input.mapping_for(input.BTN1) or "?") .. ": select  " .. (input.mapping_for(input.BTN3) or "?") .. ": skip / Esc: menu", 24, 243, colors.secondary) end
    local rows, columns = false, false
    for _, event in ipairs(state.events) do
      if event.line then
        local direction = Lines.decode(event.line)
        rows = rows or direction == "row"
        columns = columns or direction == "column"
      end
    end
    text(view.phase == "results" and "BOARD COMPLETE!"
      or (active_event and active_event.kind == "event" and "EVENT REWARD"
        or active_event and active_event.kind == "joker" and (active_event.joker == "thrifty" and "THRIFTY: UNUSED ROLLS" or "JOKER CONTRIBUTION")
        or (rows and columns and "ROW + COLUMN!" or "COUNTING THE TABLE")), 242, 118, colors.accent)
    draw_ledger(state, view.phase == "results" and state.ledger or state.events, 242, 138, 6, view.phase == "resolving" and state.event_index or nil, view.phase == "resolving" and view.turn or nil)
    button(31, 242, 214, 102, 19, "Earlier", function() scroll_ledger(state, -1, #(view.phase == "results" and state.ledger or state.events), 6) end)
    button(32, 350, 214, 110, 19, "Later", function() scroll_ledger(state, 1, #(view.phase == "results" and state.ledger or state.events), 6) end)
    button(33, 242, 237, 218, 18, view.phase == "results" and "Main menu" or "Speed through", function()
      if view.phase == "results" then navigate("menu", 1); save()
      else finish_scoring(state, save, offer_high_score) end
    end)
    Feedback.draw(state, active_event, BOARD_X, BOARD_Y, CELL)
    return
  end
  button(31, 242, 112, 105, 20, "Roll (" .. (3 - view.rolls_used) .. " left)", function() act(state, "roll") end, view.phase == "rolling" and view.rolls_used < 3)
  button(32, 353, 112, 107, 20, "Place dice", function() act(state, "begin_placement") end, view.phase == "rolling")
  text("ADJUSTMENTS: " .. view.adjustments, 242, 139, colors.secondary)
  local can_adjust = view.phase == "placing" and view.placements[state.selected] == 0 and view.adjustments > 0
  button(33, 242, 151, 46, 18, "-1", function() act(state, "adjust", state.selected, -1) end, can_adjust and view.dice[state.selected] > 1)
  button(34, 293, 151, 46, 18, "+1", function() act(state, "adjust", state.selected, 1) end, can_adjust and view.dice[state.selected] < 6)
  button(35, 345, 151, 115, 18, "Undo", function() act(state, "undo") end)
  local preview = tentative or state.session:preview()
  text(tentative and "IF PLACED" or "PREVIEW", 242, 178, colors.accent)
  button(38, 350, 175, 50, 11, "Prev", function() scroll_ledger(state, -1, #preview.events, 3) end)
  button(39, 405, 175, 55, 11, "Next", function() scroll_ledger(state, 1, #preview.events, 3) end)
  if preview then
    draw_ledger(state, preview.events, 242, 191, 3, nil, view.turn)
    text("Result: " .. tostring(preview.total), 242, 228, colors.secondary)
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
  if state.message then
    text(tostring(state.message):sub(1, 33), view.objectives and 242 or 24, view.objectives and 245 or 243, colors.accent)
  elseif not view.objectives then
    text((input.mapping_for(input.BTN1) or "?") .. ": select  " .. (input.mapping_for(input.BTN2) or "?") .. ": undo  Esc: menu", 24, 243, colors.secondary)
  else
    text((input.mapping_for(input.BTN1) or "?") .. ": select  " .. (input.mapping_for(input.BTN2) or "?") .. ": undo", 242, 245, colors.secondary)
  end
end

return GameScreen
