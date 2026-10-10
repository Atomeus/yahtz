-- Pure scoring of completed lines and board-level joker bonuses.
local Scoring = {}
local Lines = require("game.lines")

function Scoring.evaluate(faces, joker)
  assert(type(faces) == "table" and #faces == 5, "a completed line requires five faces")
  for index = 1, 5 do
    local face = faces[index]
    assert(type(face) == "number" and face % 1 == 0 and face >= 1 and face <= 6,
      "die faces must be integers from one through six")
  end
  local sum, counts, distinct, maximum = 0, {}, 0, 0
  for _, face in ipairs(faces) do
    sum = sum + face
    counts[face] = (counts[face] or 0) + 1
    if counts[face] == 1 then distinct = distinct + 1 end
    maximum = math.max(maximum, counts[face])
  end
  local run, longest = 0, 0
  for face = 1, 6 do
    run = counts[face] and run + 1 or 0
    longest = math.max(longest, run)
  end
  -- Ordered by display priority; strict improvement preserves ties.
  local candidates = {
    {"yahtzee", maximum == 5, 50},
    {"large_straight", longest == 5, 40},
    {"small_straight", longest >= 4 or (joker == "short_run" and distinct >= 4), 30},
    {"full_house", maximum == 3 and distinct == 2, 25},
    {"four_of_a_kind", maximum >= 4, sum},
    {"three_of_a_kind", maximum >= 3, sum},
    {"chance", true, sum},
  }
  local category, base_score = "chance", -1
  for _, candidate in ipairs(candidates) do
    if candidate[2] and candidate[3] > base_score then
      category, base_score = candidate[1], candidate[3]
    end
  end
  local joker_bonus = 0
  if joker == "pair_pay" then
    for _, count in pairs(counts) do
      if count >= 2 then joker_bonus = joker_bonus + 10 end
    end
  elseif joker == "little_ones" then
    joker_bonus = (counts[1] or 0) * 5
  elseif joker == "bookends" then
    joker_bonus = faces[1] == faces[5] and 10 or 0
  elseif joker == "rainbow" then
    joker_bonus = distinct == 5 and 15 or 0
  elseif joker == "odd_todd" or joker == "even_steven" then
    local parity = joker == "odd_todd" and 1 or 0
    local qualifies = true
    for _, face in ipairs(faces) do if face % 2 ~= parity then qualifies = false end end
    joker_bonus = qualifies and 15 or 0
  elseif joker == "step_up" or joker == "opposites" or joker == "alternator" then
    for i = 1, 4 do
      if (joker == "step_up" and math.abs(faces[i] - faces[i + 1]) == 1)
        or (joker == "opposites" and faces[i] + faces[i + 1] == 7)
        or (joker == "alternator" and faces[i] % 2 ~= faces[i + 1] % 2) then
        joker_bonus = joker_bonus + 5
      end
    end
  end
  return {category = category, base_score = base_score, joker_bonus = joker_bonus, total = base_score + joker_bonus}
end

function Scoring.board_bonus(board, joker)
  if joker ~= "star" and joker ~= "variety_show" then return 0 end
  for cell = 1, 25 do if not board[cell] or board[cell] == 0 then return 0 end end
  if joker == "variety_show" then
    local categories, total = {}, 0
    for _, id in ipairs(Lines.ids()) do
      local category = Scoring.evaluate(Lines.faces(board, id)).category
      if not categories[category] then categories[category], total = true, total + 10 end
    end
    return total
  end
  local bonus = 0
  for _, cell in ipairs({8, 12, 14, 18}) do
    if board[cell] == board[13] then bonus = bonus + 5 end
  end
  return bonus
end

function Scoring.turn_bonus(lines, joker, rolls_used)
  if joker == "thrifty" then return (3 - rolls_used) * 5 end
  if joker == "double_feature" then
    local row, column = false, false
    for _, line in ipairs(lines) do
      local direction = Lines.decode(line.id)
      row, column = row or direction == "row", column or direction == "column"
    end
    return row and column and 20 or 0
  end
  return 0
end

return Scoring
