local Themes = require("ui.themes")
local Lines = require("game.lines")
local text = require("ui.drawing").text
local Feedback = {duration = 0.85, sweep_duration = 0.25, flight_duration = 0.20, count_start = 0.45, count_duration = 0.30}

function Feedback.cell(state, event, cell, x, y, size, tentative)
  local colors = Themes.colors()
  if tentative then gfx.rect(x + 1, y + 1, size - 3, size - 3, colors.secondary) end
  if not event then return end
  local star = event.joker == "star" and (cell == 13 or cell == 8 or cell == 12 or cell == 14 or cell == 18)
  if not star and not Lines.contains(event.line, cell) then return end
  gfx.rect(x, y, size - 1, size - 1, colors.accent)
  if state.reduced_motion or event.kind ~= "line" then return end
  local progress = math.min(1, state.event_timer / Feedback.sweep_duration)
  local direction = Lines.decode(event.line)
  local vertical = direction == "column" or direction == "diagonal"
  local offset = vertical and math.floor((cell - 1) / 5) or (cell - 1) % 5
  local local_progress = math.max(0, math.min(1, progress * 5 - offset))
  if local_progress > 0 then
    if vertical then gfx.rect_fill(x, y, 2, (size - 1) * local_progress, colors.accent)
    else gfx.rect_fill(x, y, (size - 1) * local_progress, 2, colors.accent) end
  end
end

function Feedback.draw(state, event, board_x, board_y, cell_size)
  if not event then return end
  local colors = Themes.colors()
  local label = "+" .. event.points
  if event.kind == "joker" or event.joker == "crossroads" then
    gfx.rect(349, 17, 112, 22, colors.accent)
  end
  if not event.line or state.reduced_motion or state.event_timer < Feedback.sweep_duration then return end
  local direction, n = Lines.decode(event.line)
  if not direction then return end
  local row = direction == "row"
  local x = board_x + (row and 5 or n - 0.5) * cell_size + (row and 2 or 0)
  local y = row and board_y + (n - 0.5) * cell_size or board_y - 12
  if direction == "diagonal" then
    x = board_x + (n == 1 and 4.5 or 0.5) * cell_size
    y = board_y + 4.5 * cell_size
  end
  if not state.reduced_motion then
    if state.event_timer >= Feedback.count_start then return end
    local progress = math.max(0, math.min(1, (state.event_timer - Feedback.sweep_duration) / Feedback.flight_duration))
    x, y = x + (285 - x) * progress, y + (32 - y) * progress
  end
  local w, h = usagi.measure_text(label)
  gfx.rect_fill(x - 2, y - 2, w + 4, h + 4, colors.panel)
  text(label, x, y, colors.accent)
end
return Feedback
