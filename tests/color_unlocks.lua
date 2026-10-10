local Unlocks = require("game.color_unlocks")
for _, score in ipairs({0,199,200,201,299,300,301,399,400,401,449,450,451,474,475,476,499,500,501,524,525,526,549,550,551,574,575,576,600}) do
  local owned, earned = Unlocks.award({}, score)
  assert(owned.classic)
  local count = 0
  for _, milestone in ipairs(Unlocks.milestones) do
    assert((owned[milestone.id] == true) == (score >= milestone.score))
    if score >= milestone.score then count = count + 1 end
  end
  assert(#earned == count)
  local repeated, again = Unlocks.award(owned, score)
  assert(#again == 0)
  local lower = Unlocks.award(repeated, 0)
  for id in pairs(owned) do assert(lower[id]) end
end
local owned, theme, pending = Unlocks.restore({theme = "golden"})
assert(theme == "golden" and owned.golden and not owned.midnight and #pending == 0)
owned, theme = Unlocks.restore({theme = "unknown", high_scores = {{score = 200}, {score = 400}}})
assert(theme == "classic" and owned.golden and owned.midnight and owned.plum)
owned = Unlocks.restore({session = {phase = "rolling", score = 600}})
assert(not owned.midnight)
owned, theme, pending = Unlocks.restore({session = {phase = "results", score = 300}})
assert(owned.midnight and owned.plum and not owned.golden and #pending == 0)
owned, theme, pending = Unlocks.restore({color_progression_version = 2, theme = "golden",
  owned_colors = {midnight = true, unknown = true}, pending_colors = {"midnight", "midnight", "unknown", "golden"}})
assert(theme == "classic" and owned.midnight and not owned.unknown and not owned.golden)
assert(#pending == 1 and pending[1] == "midnight")
local input = {classic = true}
local migrated, chosen, queued = Unlocks.restore({color_progression_version = 2,
  theme = "candyland", owned_colors = {candyland = true},
  pending_colors = {"candyland"}, high_scores = {{score = 425}}})
assert(migrated.candyland and migrated.blueprint and chosen == "candyland")
assert(#queued == 1 and queued[1] == "candyland")
assert(not Unlocks.award({}, 424).blueprint and Unlocks.award({}, 425).blueprint)
local upgraded, selected, notices = Unlocks.restore({color_progression_version = 1,
  owned_colors = {midnight = true}, theme = "midnight", high_scores = {{score = 575}}})
assert(upgraded.dark and upgraded.paper and upgraded.forest and selected == "midnight" and #notices == 0)
Unlocks.award(input, 400)
assert(not input.midnight, "Awarding must not mutate prior ownership")
for _, invalid in ipairs({-1, math.huge, "400"}) do
  assert(not Unlocks.award({}, invalid).midnight)
end
print("unlock boundaries, permanent ownership, migration, pending notices and safe fallback passed")
