local Scoring = require("scoring")
local Lines = require("game.lines")
local Summary = {}

function Summary.comparison(score, previous)
  if previous == nil then return nil end
  if previous == false then return "First recorded board" end
  if score > previous then return "New Table best!" end
  if score == previous then return "Matched Table best" end
  return tostring(previous - score) .. " short of Table best"
end

function Summary.calculate(view)
  local result = {score = view.score, contribution = 0,
    event_contribution = view.objectives and view.objectives.contribution}
  for _, id in ipairs(Lines.ids(view.joker)) do
    local faces = Lines.faces(view.board, id)
    local scored = Scoring.evaluate(faces, view.joker)
    local line = {id = id, faces = faces, category = scored.category, total = scored.total
      + (view.objectives and view.objectives.line_bonuses[id] or 0)}
    local diagonal = Lines.decode(id) == "diagonal"
    if not diagonal then
      if not result.strongest or line.total > result.strongest.total then
        result.strongest, result.joint = line, false
      elseif line.total == result.strongest.total then result.joint = true end
    end
    if diagonal then
      result.contribution = result.contribution + scored.total
    else
      result.contribution = result.contribution + scored.total - Scoring.evaluate(faces).total
    end
  end
  result.contribution = result.contribution + Scoring.board_bonus(view.board, view.joker)
  if view.joker == "thrifty" then result.contribution = view.turn_bonus_total end
  return result
end

return Summary
