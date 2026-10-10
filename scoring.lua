-- Pure scoring of a completed line. Joker IDs: pair_pay, short_run, thrifty.
local Scoring = {}

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
  end
  return {category = category, base_score = base_score, joker_bonus = joker_bonus, total = base_score + joker_bonus}
end

return Scoring
