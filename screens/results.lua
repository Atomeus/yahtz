local Summary = require("game.results_summary")
local HighScores = require("game.high_scores")
local Lines = require("game.lines")
local Jokers = require("game.jokers")
local Drawing = require("ui.drawing")
local Controls = require("ui.controls")
local Themes = require("ui.themes")
local Results = {}

function Results.pending(state)
  return not state.high_score_handled and HighScores.qualifies(state.high_scores, state.session:view().score)
end

function Results.open(state, navigate)
  state.results_destination, state.results_details = nil, false
  state.results_colors = nil
  navigate("results", 1)
end

function Results.draw(state, navigate, save, enter_name)
  local colors, view = Themes.colors(), state.session:view()
  local summary = Summary.calculate(view)
  local text = Drawing.text
  local function button(...) return Controls.button(state, ...) end
  text("BOARD COMPLETE!", 24, 20, colors.accent)
  for index = 1, 5 do
    text("C" .. index, 52 + (index - 1) * 36, 35, colors.secondary)
    text("R" .. index, 20, 63 + (index - 1) * 36, colors.secondary)
  end
  for cell = 1, 25 do
    local x, y = 42 + (cell - 1) % 5 * 36, 53 + math.floor((cell - 1) / 5) * 36
    Drawing.die(view.board[cell], x + 3, y + 3, 28, false, true)
    if Lines.contains(summary.strongest.id, cell) then gfx.rect(x, y, 35, 35, colors.accent) end
  end
  local function leave(destination)
    if Results.pending(state) then state.results_destination, state.focus = destination, 10
    else navigate(destination, 1) end
  end
  if state.results_colors then
    text("NEW COLORS UNLOCKED", 242, 43, colors.accent)
    for index, id in ipairs(state.results_colors) do
      text(Themes.get(id).name, 242, 65 + (index - 1) * 18, colors.secondary)
    end
    button(14, 242, 237, 218, 20, "Back to summary", function()
      state.results_colors, state.focus = nil, 1
    end)
    return
  end
  if #state.pending_colors > 0 and not state.results_details then
    button(13, 24, 237, 198, 20, "New colors: " .. #state.pending_colors, function()
      state.results_colors, state.pending_colors, state.focus = state.pending_colors, {}, 14
      save()
    end)
  end
  if state.results_destination then
    text("Save this score?", 242, 55, colors.accent)
    button(10, 242, 85, 218, 24, "Save score", function()
      state.results_destination = nil
      enter_name()
    end)
    button(11, 242, 119, 218, 24, "Skip and continue", function()
      local destination = state.results_destination
      state.high_score_handled, state.results_destination = true, nil
      save()
      navigate(destination, 1)
    end)
    button(12, 242, 153, 218, 24, "Back", function()
      state.results_destination, state.focus = nil, 1
    end)
    return
  end
  if state.results_details then
    text("SCORE DETAILS", 242, 43, colors.accent)
    local offset = state.results_offset or 1
    for i = offset, math.min(#state.ledger, offset + 9) do
      local event = state.ledger[i]
      local label = (event.line and Lines.label(event.line) or (event.scope == "board" and "Board" or "Turn")) .. " " .. (event.category or event.joker or event.kind)
      text("T" .. (event.turn or "?") .. " " .. label:gsub("_", " "):sub(1, 24), 242, 65 + (i - offset) * 14, colors.secondary)
      text("+" .. event.points, 425, 65 + (i - offset) * 14, colors.text)
    end
    button(7, 242, 210, 105, 20, "Earlier", function() state.results_offset = math.max(1, offset - 1) end)
    button(8, 353, 210, 107, 20, "Later", function() state.results_offset = math.min(math.max(1, #state.ledger - 9), offset + 1) end)
    button(9, 242, 237, 218, 20, "Back to summary", function() state.results_details, state.focus = false, 1 end)
    return
  end
  text(tostring(summary.score) .. " POINTS", 242, 43, colors.accent)
  local comparison = Summary.comparison(summary.score, state.results_previous_best)
  if comparison then text(comparison, 242, 62, colors.secondary) end
  text(summary.joint and "Joint strongest" or "Strongest line", 242, 87, colors.accent)
  local line = summary.strongest
  text(Lines.label(line.id) .. "  " .. table.concat(line.faces, " "), 242, 103, colors.text)
  text(line.category:gsub("four_of_a_kind", "4 of a kind"):gsub("three_of_a_kind", "3 of a kind"):gsub("_", " ") .. "  +" .. line.total, 242, 119, colors.secondary)
  if summary.contribution ~= nil then
    text(Jokers.get(view.joker).name .. ": +" .. summary.contribution, 242, 145, colors.secondary)
  end
  local pending = Results.pending(state)
  local function details()
    state.pending_colors = {}
    save()
    state.results_details, state.focus = true, 9
  end
  button(1, 242, 171, 218, 22, pending and "Save score" or "Play again", function()
    if pending then enter_name() else leave("jokers") end
  end)
  button(2, 242, 199, 105, 20, "Main menu", function() leave("menu") end)
  button(3, 353, 199, 107, 20, pending and "Play again" or "Score details", function()
    if pending then leave("jokers") else details() end
  end)
  if pending then
    button(4, 242, 227, 218, 20, "Score details", details)
  end
end

return Results
