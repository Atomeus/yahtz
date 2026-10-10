-- Preserve row1..row5 and column1..column5; Crossroads adds diagonal1 and diagonal2.
local Lines = {}

function Lines.decode(id)
  if type(id) ~= "string" then return nil end
  local diagonal = id:match("^diagonal([12])$")
  if diagonal then return "diagonal", tonumber(diagonal) end
  local direction, index = id:match("^(%a+)([1-5])$")
  if direction ~= "row" and direction ~= "column" then return nil end
  return direction, tonumber(index)
end

function Lines.contains(id, cell)
  local direction, index = Lines.decode(id)
  if not direction then return false end
  if direction == "row" then return math.floor((cell - 1) / 5) + 1 == index end
  if direction == "diagonal" then
    local row, col = math.floor((cell - 1) / 5) + 1, (cell - 1) % 5 + 1
    return index == 1 and row == col or index == 2 and row + col == 6
  end
  return (cell - 1) % 5 + 1 == index
end

function Lines.ids(joker)
  local ids = {}
  for _, direction in ipairs({"row", "column"}) do
    for index = 1, 5 do ids[#ids + 1] = direction .. index end
  end
  if joker == "crossroads" then ids[#ids + 1], ids[#ids + 2] = "diagonal1", "diagonal2" end
  return ids
end

function Lines.faces(board, id)
  local faces = {}
  for cell = 1, 25 do
    if Lines.contains(id, cell) then faces[#faces + 1] = board[cell] end
  end
  return faces
end

function Lines.label(id)
  local direction, index = Lines.decode(id)
  if not direction then return id end
  local names = {row = "Row ", column = "Col ", diagonal = "Diag "}
  return names[direction] .. index
end

return Lines
