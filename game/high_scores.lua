local HighScores = { NAME_LIMIT = 12 }

-- Ties keep the earlier entry; a full table requires beating its fifth score.
function HighScores.qualifies(entries, score)
  return #entries < 5 or score > entries[5].score
end

function HighScores.record(entries, name, score)
  local result = {}
  for _, entry in ipairs(entries) do
    result[#result + 1] = {name = entry.name, score = entry.score}
  end
  if not HighScores.qualifies(entries, score) then return result end
  name = tostring(name):upper():gsub("[^A-Z0-9 ]", ""):sub(1, HighScores.NAME_LIMIT):match("^%s*(.-)%s*$")
  if name == "" then name = "PLAYER" end
  local position = #result + 1
  for i, entry in ipairs(result) do
    if score > entry.score then position = i; break end
  end
  table.insert(result, position, {name = name, score = score})
  if #result > 5 then table.remove(result) end
  return result
end

return HighScores
