local Scoring = require("scoring")
local Summary = {}

function Summary.comparison(score, previous)
  if previous == nil then return nil end
  if previous == false then return "First recorded board" end
  if score > previous then return "New Table best!" end
  if score == previous then return "Matched Table best" end
  return tostring(previous - score) .. " short of Table best"
end

function Summary.calculate(view)
  local result = {score = view.score, contribution = 0}
  for direction = 1, 2 do
    for index = 1, 5 do
      local faces = {}
      for offset = 1, 5 do
        faces[offset] = view.board[direction == 1 and (index - 1) * 5 + offset or (offset - 1) * 5 + index]
      end
      local scored = Scoring.evaluate(faces, view.joker)
      local line = {id = (direction == 1 and "row" or "column") .. index,
        faces = faces, category = scored.category, total = scored.total}
      if not result.strongest or line.total > result.strongest.total then
        result.strongest, result.joint = line, false
      elseif line.total == result.strongest.total then result.joint = true end
      if view.joker == "pair_pay" then
        result.contribution = result.contribution + scored.joker_bonus
      elseif view.joker == "short_run" then
        result.contribution = result.contribution + scored.total - Scoring.evaluate(faces).total
      end
    end
  end
  if view.joker == "thrifty" then result.contribution = view.turn_bonus_total end
  return result
end

return Summary
