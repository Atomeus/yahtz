local scoring = require("scoring")
local result = scoring.evaluate({1, 2, 2, 4, 6})
assert(result.category == "chance")
assert(result.base_score == 15 and result.joker_bonus == 0 and result.total == 15)

-- Each example is a worked category selection, including overlapping categories.
local examples = {
  {{6,6,6,5,5}, "three_of_a_kind", 28},
  {{2,2,2,3,3}, "full_house", 25},
  {{6,6,6,6,5}, "four_of_a_kind", 29},
  {{1,1,1,1,1}, "yahtzee", 50},
  {{6,2,3,4,5}, "large_straight", 40},
  {{4,1,2,2,3}, "small_straight", 30},
  {{1,2,3,5,6}, "chance", 17},
}
for _, example in ipairs(examples) do
  local actual = scoring.evaluate(example[1])
  assert(actual.category == example[2], actual.category .. " instead of " .. example[2])
  assert(actual.base_score == example[3] and actual.total == example[3])
end

local pair_examples = {
  {{2,2,3,3,6}, 16, 20},
  {{6,6,6,6,6}, 50, 10},
  {{1,2,3,4,5}, 40, 0},
}
for _, example in ipairs(pair_examples) do
  local actual = scoring.evaluate(example[1], "pair_pay")
  assert(actual.base_score == example[2])
  assert(actual.joker_bonus == example[3])
  assert(actual.total == example[2] + example[3])
end

local short = scoring.evaluate({1,2,4,6,6}, "short_run")
assert(short.category == "small_straight" and short.base_score == 30 and short.total == 30)
local large = scoring.evaluate({5,3,1,4,2}, "short_run")
assert(large.category == "large_straight" and large.total == 40)
local duplicate = scoring.evaluate({1,1,2,2,6}, "short_run")
assert(duplicate.category == "chance" and duplicate.total == 12)
local thrifty = scoring.evaluate({1,2,2,4,6}, "thrifty")
assert(thrifty.joker_bonus == 0 and thrifty.total == 15)

for _, invalid in ipairs({{}, {1,2,3,4}, {1,2,3,4,5,6}, {0,2,3,4,5}, {7,2,3,4,5}, {1.5,2,3,4,5}}) do
  assert(not pcall(scoring.evaluate, invalid), "invalid completed line was accepted")
end
local faces = {6,2,3,4,5}
scoring.evaluate(faces, "pair_pay")
assert(table.concat(faces, ",") == "6,2,3,4,5", "scoring changed the line")
