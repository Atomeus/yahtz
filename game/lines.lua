-- Persisted line IDs remain row1..row5 and column1..column5.
local Lines = {}

function Lines.decode(id)
  if type(id) ~= "string" then return nil end
  local direction, index = id:match("^(%a+)([1-5])$")
  if direction ~= "row" and direction ~= "column" then return nil end
  return direction, tonumber(index)
end

function Lines.contains(id, cell)
  local direction, index = Lines.decode(id)
  if not direction then return false end
  if direction == "row" then return math.floor((cell - 1) / 5) + 1 == index end
  return (cell - 1) % 5 + 1 == index
end

return Lines
