local Summary = require("game.results_summary")
local Session = require("game.session")
local function board(faces)
  local result = {}
  for row = 1, 5 do for col = 1, 5 do result[#result + 1] = faces[col] end end
  return result
end
local pair = Summary.calculate({board = board({2,2,5,5,5}), joker = "pair_pay", score = 0})
assert(pair.contribution == 150)
assert(pair.strongest.id == "column1" and pair.strongest.total == 60 and pair.joint)
local short = Summary.calculate({board = board({1,2,4,6,6}), joker = "short_run", score = 0})
assert(short.contribution == 55)
assert(Summary.calculate({board = board({1,2,3,4,5}), joker = "short_run"}).contribution == 0)
local thrifty = {board = board({1,1,1,1,1}), joker = "thrifty", turn_bonus_total = 50}
assert(Summary.calculate(thrifty).contribution == 50)
assert(Summary.calculate(thrifty).strongest.total == 50)
thrifty.turn_bonus_total = nil
assert(Summary.calculate(thrifty).contribution == nil)
assert(Summary.comparison(100, nil) == nil)
assert(Summary.comparison(100, false) == "First recorded board")
assert(Summary.comparison(100, 90) == "New Table best!")
assert(Summary.comparison(100, 100) == "Matched Table best")
assert(Summary.comparison(100, 110) == "10 short of Table best")
local session = Session.new("thrifty", 1)
for turn = 1, 5 do
  session:begin_placement()
  for die = 1, 5 do session:place(die, (turn - 1) * 5 + die) end
  session:confirm()
  assert(session:snapshot().turn_bonus_total == turn * 10)
  session = Session.resume(session:snapshot())
end
assert(Summary.calculate(session:view()).contribution == 50)
print("summary attribution, ties, comparisons, legacy omission and turn-boundary persistence passed")
