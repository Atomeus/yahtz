local Drawing = require("ui.drawing")
local Controls = require("ui.controls")
local text = Drawing.text
local MainMenu = {}

function MainMenu.draw(state, navigate, offer_high_score)
  local function button(...) return Controls.button(state, ...) end
  local title_width = usagi.measure_text("YAHTZ")
  gfx.text_ex("YAHTZ", (480 - title_width * 3) / 2, 18, 3, 0, gfx.COLOR_YELLOW, 1)
  button(1, 168, 69, 144, 26, "Play now", function()
    navigate("jokers", 1)
  end)
  if state.session then
    local completed = state.session:view().phase == "results"
    button(2, 168, 100, 144, 20, completed and "View results" or "Continue", function()
      navigate("game", 26)
      if completed then offer_high_score() end
    end)
  end
  local heading_width = usagi.measure_text("HIGH SCORES")
  text("HIGH SCORES", (480 - heading_width) / 2, 126, gfx.COLOR_PEACH)
  text("RANK", 96, 144, gfx.COLOR_LIGHT_GRAY)
  text("NAME", 144, 144, gfx.COLOR_LIGHT_GRAY)
  text("POINTS", 342, 144, gfx.COLOR_LIGHT_GRAY)
  local scores = state.high_scores or {}
  for rank = 1, 5 do
    local entry = scores[rank]
    local y = 162 + (rank - 1) * 16
    text(tostring(rank) .. ".", 96, y, gfx.COLOR_YELLOW)
    text(entry and entry.name or "---", 144, y, gfx.COLOR_PEACH)
    text(entry and tostring(entry.score) or "---", 342, y, gfx.COLOR_WHITE)
  end
  text("Mouse / directions + " .. (input.mapping_for(input.BTN1) or "?"), 96, 243, gfx.COLOR_PEACH)
end

return MainMenu
