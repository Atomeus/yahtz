local Lines = require("game.lines")
local Objectives = {}
Objectives.options = {
  {id = "three_rows20", name = "Three Rows", short = "rows =20", target = 3, points = 50,
    details = {"Finish at least three rows with exactly 20 pips each.", "All five dice in each row must be placed.", "Columns and diagonals do not count."}},
  {id = "four_corners", name = "Four Corners", short = "corners", target = 5, points = 50,
    details = {"Match all four corners and the center to one face.", "Any face from one through six counts.", "Other cells can contain anything."}},
  {id = "crossroads", name = "Crossroads", short = "cross", target = 2, points = 75,
    details = {"Make large straights in the middle row and column.", "Each must contain 1-5 or 2-6, in any order.", "The two lines share the center die."}},
  {id = "mirror", name = "Mirror, Mirror", short = "mirror", target = 8, points = 75,
    details = {"Match at least eight pairs across the vertical center.", "In each row, match columns 1 with 5 and 2 with 4.", "The middle column does not count."}},
  {id = "twin_diagonals", name = "Twin Diagonals", short = "diags", target = 2, points = 75,
    details = {"Put five different faces on each long diagonal.", "They do not need to be consecutive or ordered.", "Both diagonals share the center die."}},
  {id = "full_collection", name = "Full Collection", short = "collect", target = 4, points = 100,
    details = {"Make a three of a kind, full house, large straight,", "and Yahtzee in four different rows or columns.", "Three of a kind means at least three equal dice.", "Ordinary rules apply; joker changes do not count."}},
  {id = "checkerboard", name = "Checkerboard", short = "checks", target = 22, points = 100,
    details = {"Match at least 22 cells to an odd/even checkerboard.", "Neighbors alternate odd and even faces.", "Either orientation counts; three mistakes are allowed."}},
}
function Objectives.definition(id)
  for _, item in ipairs(Objectives.options) do if item.id == id then return item end end
  return Objectives.options[1] -- Saves predating randomized objectives retain Three Rows.
end
local function facts(faces)
  local counts, distinct, maximum, complete = {}, 0, 0, true
  for _, face in ipairs(faces) do
    if face == 0 then complete = false
    else
      counts[face] = (counts[face] or 0) + 1
      if counts[face] == 1 then distinct = distinct + 1 end
      maximum = math.max(maximum, counts[face])
    end
  end
  local straight = complete and distinct == 5 and not (counts[1] and counts[6])
  return complete, distinct, maximum, straight
end
function Objectives.progress(board, id)
  id = Objectives.definition(id).id
  local count = 0
  if id == "three_rows20" then
    for row = 1, 5 do
      local faces, sum = Lines.faces(board, "row" .. row), 0
      for _, face in ipairs(faces) do sum = sum + face end
      if facts(faces) and sum == 20 then count = count + 1 end
    end
  elseif id == "four_corners" then
    local counts = {}
    for _, cell in ipairs({1, 5, 13, 21, 25}) do
      local face = board[cell]
      if face > 0 then counts[face] = (counts[face] or 0) + 1; count = math.max(count, counts[face]) end
    end
  elseif id == "crossroads" or id == "twin_diagonals" then
    local ids = id == "crossroads" and {"row3", "column3"} or {"diagonal1", "diagonal2"}
    for _, line in ipairs(ids) do
      local complete, distinct, _, straight = facts(Lines.faces(board, line))
      if complete and (id == "crossroads" and straight or id == "twin_diagonals" and distinct == 5) then count = count + 1 end
    end
  elseif id == "mirror" then
    for row = 0, 4 do
      for col = 1, 2 do
        local a, b = board[row * 5 + col], board[row * 5 + 6 - col]
        if a > 0 and a == b then count = count + 1 end
      end
    end
  elseif id == "checkerboard" then
    local matches, occupied = 0, 0
    for cell = 1, 25 do
      if board[cell] > 0 then
        occupied = occupied + 1
        if board[cell] % 2 == cell % 2 then matches = matches + 1 end
      end
    end
    count = math.max(matches, occupied - matches)
  else
    -- Match requirements to distinct lines, including overlapping eligibility.
    local eligible = {}
    for _, line in ipairs(Lines.ids()) do
      local complete, distinct, maximum, straight = facts(Lines.faces(board, line))
      if complete then eligible[#eligible + 1] = {maximum >= 3, maximum == 3 and distinct == 2, straight, maximum == 5} end
    end
    local function match(requirement, used)
      if requirement == 5 then return 0 end
      local best = match(requirement + 1, used)
      for index, qualifies in ipairs(eligible) do
        if qualifies[requirement] and not used[index] then
          used[index] = true
          best = math.max(best, 1 + match(requirement + 1, used))
          used[index] = nil
        end
      end
      return best
    end
    count = match(1, {})
  end
  return count
end
function Objectives.label(board, id)
  local item = Objectives.definition(id)
  return "Board: " .. item.short .. " " .. Objectives.progress(board, id) .. "/" .. item.target .. " +" .. item.points .. " ?"
end
return Objectives
