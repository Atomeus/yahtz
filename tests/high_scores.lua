local HighScores = require("game.high_scores")
local entries = {}
for i, score in ipairs({100,300,200,500,400}) do
  assert(HighScores.qualifies(entries, score))
  entries = HighScores.record(entries, "PLAYER " .. i, score)
end
assert(#entries == 5 and entries[1].score == 500 and entries[5].score == 100)
assert(not HighScores.qualifies(entries, 100))
assert(not HighScores.qualifies(entries, 99))
local updated = HighScores.record(entries, "NEW", 300)
assert(#updated == 5 and updated[3].name == "PLAYER 2" and updated[4].name == "NEW")
assert(entries[5].score == 100 and updated[5].score == 200)
local blank = HighScores.record({}, "  ", 0)
assert(blank[1].name == "PLAYER" and blank[1].score == 0)
local named = HighScores.record({}, "abcdefghijklmnop!", 42)
assert(named[1].name == "ABCDEFGHIJKL")
print("high score ranking, ties, capacity, and names passed")
