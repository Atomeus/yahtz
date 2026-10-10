-- Temporary objectives are independent of dice RNG and ordinary combination rules.
local Events = {}
local Scoring = require("scoring")
local definitions = {
  {id = "sum7", operation = "sum", target = 7},
  {id = "sum9", operation = "sum", target = 9},
  {id = "product6", operation = "product", target = 6},
  {id = "product12", operation = "product", target = 12},
  {id = "line15", operation = "line", target = 15},
  {id = "line20", operation = "line", target = 20},
}
local function random(state, count)
  state.rng = state.rng * 16807 % 2147483647
  return state.rng % count + 1
end
function Events.new(seed)
  return {rng = ((math.floor(seed or 1) - 1) % 2147483646) + 1,
    remaining = {1, 2, 3, 4, 5, 6}, contribution = 0, line_bonuses = {}}
end
function Events.deal(state, scored_lines)
  local definition = definitions[table.remove(state.remaining, random(state, #state.remaining))]
  local event = {id = definition.id, operation = definition.operation, target = definition.target}
  if event.operation == "line" then
    local candidates = {}
    for _, direction in ipairs({"row", "column"}) do
      for i = 1, 5 do
        local id = direction .. i
        if not scored_lines[id] then candidates[#candidates + 1] = id end
      end
    end
    event.line = candidates[random(state, #candidates)]
  end
  state.active = event
end
function Events.label(event)
  if event.operation == "line" then
    local line = event.line:gsub("column", "C"):gsub("row", "R")
    return line .. " sum " .. event.target .. ": x2 base"
  end
  return "Adjacent " .. (event.operation == "sum" and "sum " or "product ") .. event.target .. ": +10"
end
function Events.board_progress(board)
  local count = 0
  for row = 1, 5 do
    local sum, complete = 0, true
    for col = 1, 5 do
      local value = board[(row - 1) * 5 + col]
      sum = sum + value
      if value == 0 then complete = false end
    end
    if complete and sum == 20 then count = count + 1 end
  end
  return count
end
function Events.evaluate(state, board, fresh, lines)
  local payouts = {}
  if not state then return payouts end -- Legacy boards keep their original rules.
  local event = state.active
  local function award(points, line)
    payouts[#payouts + 1] = {kind = "event", objective = event.id,
      label = Events.label(event), points = points, line = line}
  end
  if event.operation == "line" then
    for _, line in ipairs(lines) do
      if line.id == event.line then
        local sum = 0
        for _, face in ipairs(line.faces) do sum = sum + face end
        if sum == event.target then award(Scoring.evaluate(line.faces).base_score, line.id) end
      end
    end
  else
    local qualified = false
    for cell = 1, 25 do
      local neighbors = {}
      if cell % 5 ~= 0 then neighbors[#neighbors + 1] = cell + 1 end
      if cell <= 20 then neighbors[#neighbors + 1] = cell + 5 end
      for _, neighbor in ipairs(neighbors) do
        local a, b = board[cell], board[neighbor]
        local value = event.operation == "sum" and a + b or a * b
        if a > 0 and b > 0 and (fresh[cell] or fresh[neighbor]) and value == event.target then
          qualified = true
        end
      end
    end
    if qualified then award(10) end
  end
  local complete = true
  for cell = 1, 25 do if board[cell] == 0 then complete = false end end
  if complete and Events.board_progress(board) >= 3 then
    payouts[#payouts + 1] = {kind = "event", objective = "three_rows20",
      label = "Board: 3 rows sum 20", points = 50}
  end
  return payouts
end
return Events
