local Themes = require("ui.themes")
local ScoreDisplay = {}
local Feedback = require("ui.scoring_feedback")

function ScoreDisplay.draw(state, view)
  local colors = Themes.colors()
  local score, rotation, scale = view.score, 0, 1
  if view.phase == "resolving" then
    -- The session total is committed already; animate only its presentation.
    for i = state.event_index, #state.events do
      score = score - state.events[i].points
    end
    local event = state.events[state.event_index]
    if event and state.reduced_motion then score = score + event.points end
    if event and not state.reduced_motion then
      local progress = math.min(1, math.max(0, state.event_timer - Feedback.count_start) / Feedback.count_duration)
      local eased = 1 - (1 - progress) ^ 3
      score = score + math.floor(event.points * eased)
      if event.points > 0 then
        -- Stable variation per payout: never consume the gameplay RNG or
        -- choose a new random angle every frame.
        local variation = math.sin(event.points * 12.9898 + view.turn * 78.233
          + state.event_index * 37.719) * 43758.5453
        local amplitude = 2 + (variation - math.floor(variation)) * 3
        local direction = state.event_index % 2 == 0 and -1 or 1
        local envelope = math.sin(progress * math.pi)
        rotation = math.rad(amplitude) * direction
          * math.sin(progress * math.pi * 3) * envelope
        scale = 1 + 0.18 * envelope
      end
    end
  end

  local label = tostring(score) .. " POINTS"
  local width, height = usagi.measure_text(label)
  local x, y = 242 - width * (scale - 1) / 2, 20 - height * (scale - 1) / 2
  if scale > 1 then
    gfx.text_ex(label, x + 1, y + 1, scale, rotation, colors.panel, 1)
  end
  gfx.text_ex(label, x, y, scale, rotation, colors.accent, 1)
end

return ScoreDisplay
