local Themes = require("ui.themes")
local Controls = {}
local text = require("ui.drawing").text

function Controls.button(state, id, x, y, w, h, label, callback, enabled)
  local colors = Themes.colors()
  state.buttons[#state.buttons + 1] = { id = id, x = x, y = y, w = w, h = h, callback = callback, enabled = enabled ~= false }
  if label then
    gfx.rect_fill(x, y, w, h, enabled == false and colors.disabled or colors.panel)
    gfx.rect(x, y, w, h, state.focus == id and colors.accent or colors.border)
    local text_width, text_height = usagi.measure_text(label)
    text(label, x + math.floor((w - text_width) / 2),
      y + math.floor((h - text_height) / 2),
      enabled == false and colors.muted or colors.secondary)
  elseif state.focus == id then
    gfx.rect(x - 1, y - 1, w + 2, h + 2, colors.accent)
  end
end

local function move_focus(state, dx, dy)
  local current
  for _, b in ipairs(state.buttons or {}) do if b.id == state.focus then current = b end end
  if not current then state.focus = state.buttons and state.buttons[1] and state.buttons[1].id or 1; return end
  local cx, cy = current.x + current.w / 2, current.y + current.h / 2
  local best, distance
  for _, b in ipairs(state.buttons or {}) do
    local vx, vy = b.x + b.w / 2 - cx, b.y + b.h / 2 - cy
    local along, across = vx * dx + vy * dy, math.abs(vx * dy - vy * dx)
    local score = along + across * 3
    if b.enabled and along > 1 and (not distance or score < distance) then best, distance = b, score end
  end
  if best then state.focus = best.id end
end

function Controls.update(state)
  if input.pressed(input.LEFT) then move_focus(state, -1, 0) end
  if input.pressed(input.RIGHT) then move_focus(state, 1, 0) end
  if input.pressed(input.UP) then move_focus(state, 0, -1) end
  if input.pressed(input.DOWN) then move_focus(state, 0, 1) end
  local mx, my = input.mouse()
  if mx ~= state.pointer_x or my ~= state.pointer_y then state.pointer_mode = true end
  state.pointer_x, state.pointer_y = mx, my
  if input.pressed(input.LEFT) or input.pressed(input.RIGHT) or input.pressed(input.UP)
    or input.pressed(input.DOWN) or input.pressed(input.BTN1) then state.pointer_mode = false end
  state.hover = nil
  if state.pointer_mode then
    for _, b in ipairs(state.buttons or {}) do
      if b.enabled and mx >= b.x and mx < b.x + b.w and my >= b.y and my < b.y + b.h then
        state.hover = b.id
        break
      end
    end
  end
  local click = input.mouse_pressed(input.MOUSE_LEFT)
  for _, b in ipairs(state.buttons or {}) do
    local hit = click and mx >= b.x and mx < b.x + b.w and my >= b.y and my < b.y + b.h
    if b.enabled and (hit or (b.id == state.focus and input.pressed(input.BTN1))) then
      state.focus = b.id
      b.callback()
      break
    end
  end
end

return Controls
