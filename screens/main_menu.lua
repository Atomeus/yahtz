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
  gfx.text_ex("YAHTZ", (480 - title_width * 2) / 2, 12, 2, 0, colors.accent, 1)
  button(1, 24, 48, 432, 30, "Play now", function()
    if state.session and state.session:view().phase ~= "results" then
      state.confirm_new_board, state.focus = true, 11
    else navigate("jokers", 1) end
  end)
  local completed = state.session and state.session:view().phase == "results"
  local function secondary(id, x, label, status, action, enabled)
    button(id, x, 84, 136, 34, "", action, enabled)
    local color = enabled == false and colors.muted or colors.secondary
    text(label, x + 28, 85, color)
    text(status, x + 8, 101, color)
    return color
  end
  local continue_color = secondary(2, 24, completed and "View results" or "Continue",
    state.session and (completed and "Board complete" or "Resume your board") or "No board yet", function()
      navigate("game", state.game_menu_focus or 26)
      if completed then offer_high_score() end
    end, state.session ~= nil)
  for offset = 0, 5 do
    gfx.rect_fill(36 + offset, 88 + offset, 1, 11 - offset * 2, continue_color)
  end
  secondary(3, 172, "Colors", "Choose a theme", function()
    navigate("themes", 1)
  end)
  for index, color in ipairs({colors.accent, colors.secondary, colors.die}) do
    gfx.rect_fill(184 + (index - 1) % 2 * 5, 88 + math.floor((index - 1) / 2) * 5, 4, 4, color)
  end
  secondary(4, 320, "Motion", state.reduced_motion and "Reduced" or "Bouncy", toggle_motion)
  if state.reduced_motion then
    gfx.rect_fill(332, 88, 3, 11, colors.secondary)
    gfx.rect_fill(338, 88, 3, 11, colors.secondary)
  else
    for offset = 0, 8 do
      gfx.rect_fill(332 + offset, 88 + math.abs(4 - offset), 1, 3, colors.secondary)
    end
  end
  local heading_width = usagi.measure_text("HIGH SCORES")
  text("HIGH SCORES", (480 - heading_width) / 2, 124, colors.secondary)
  text("RANK", 96, 142, colors.muted)
  text("NAME", 144, 142, colors.muted)
  text("POINTS", 342, 142, colors.muted)
  local scores = state.high_scores or {}
  for rank = 1, 5 do
    local entry = scores[rank]
    local y = 158 + (rank - 1) * 16
    text(tostring(rank) .. ".", 96, y, colors.accent)
    text(entry and entry.name or "---", 144, y, colors.secondary)
    text(entry and tostring(entry.score) or "---", 342, y, colors.text)
  end
  button(5, 194, 240, 92, 18, "Credits", function()
    navigate("credits", 1)
  end)
  text("Mouse / " .. (input.mapping_for(input.BTN1) or "?"), 24, 242, colors.secondary)
end

return MainMenu
