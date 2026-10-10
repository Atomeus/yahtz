local Themes = require("ui.themes")
local Drawing = require("ui.drawing")
local Controls = require("ui.controls")
local text = Drawing.text
local MainMenu = {}

local function cancel_new_board(state)
  state.confirm_new_board, state.focus = false, 1
end

function MainMenu.update(state)
  if state.confirm_new_board and input.pressed(input.BTN2) then cancel_new_board(state) end
end

function MainMenu.draw(state, navigate, offer_high_score, toggle_motion)
  local colors = Themes.colors()
  local function button(...) return Controls.button(state, ...) end
  if state.confirm_new_board then
    gfx.rect_fill(76, 75, 328, 128, colors.panel)
    gfx.rect(76, 75, 328, 128, colors.border)
    text("Start a new board?", 108, 89, colors.accent)
    text("Your unfinished board will be replaced.", 96, 113, colors.text)
    text("Continue keeps your current board.", 96, 132, colors.secondary)
    button(10, 96, 158, 144, 26, "Start new board", function()
      state.confirm_new_board = false
      navigate("jokers", 1)
    end)
    button(11, 248, 158, 136, 26, "Back", function() cancel_new_board(state) end)
    return
  end
  local title_width = usagi.measure_text("YAHTZ")
  gfx.text_ex("YAHTZ", (480 - title_width * 3) / 2, 18, 3, 0, colors.accent, 1)
  button(1, 168, 69, 144, 26, "Play now", function()
    if state.session and state.session:view().phase ~= "results" then
      state.confirm_new_board, state.focus = true, 11
    else navigate("jokers", 1) end
  end)
  if state.session then
    local completed = state.session:view().phase == "results"
    button(2, 168, 100, 144, 20, completed and "View results" or "Continue", function()
      navigate("game", state.game_menu_focus or 26)
      if completed then offer_high_score() end
    end)
  end
  button(3, 322, 69, 130, 26, "Colors", function()
    navigate("themes", 1)
  end)
  button(4, 322, 100, 130, 20,
    "Motion: " .. (state.reduced_motion and "reduced" or "bouncy"), toggle_motion)
  local heading_width = usagi.measure_text("HIGH SCORES")
  text("HIGH SCORES", (480 - heading_width) / 2, 126, colors.secondary)
  text("RANK", 96, 144, colors.muted)
  text("NAME", 144, 144, colors.muted)
  text("POINTS", 342, 144, colors.muted)
  local scores = state.high_scores or {}
  for rank = 1, 5 do
    local entry = scores[rank]
    local y = 162 + (rank - 1) * 16
    text(tostring(rank) .. ".", 96, y, colors.accent)
    text(entry and entry.name or "---", 144, y, colors.secondary)
    text(entry and tostring(entry.score) or "---", 342, y, colors.text)
  end
  button(5, 360, 238, 92, 20, "Credits", function()
    navigate("credits", 1)
  end)
  text("Mouse / directions + " .. (input.mapping_for(input.BTN1) or "?"), 96, 243, colors.secondary)
end

return MainMenu
