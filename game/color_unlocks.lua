local Unlocks = {VERSION = 2}
Unlocks.milestones = {
  {id = "midnight", score = 200},
  {id = "plum", score = 300},
  {id = "golden", score = 400},
  {id = "forest", score = 450},
  {id = "cyberpunk", score = 475},
  {id = "candyland", score = 500},
  {id = "ocean", score = 525},
  {id = "paper", score = 550},
  {id = "dark", score = 575},
}

function Unlocks.required(id)
  for _, milestone in ipairs(Unlocks.milestones) do
    if milestone.id == id then return milestone.score end
  end
end

function Unlocks.award(owned, score)
  local result, earned = {classic = true}, {}
  for _, milestone in ipairs(Unlocks.milestones) do
    local already = type(owned) == "table" and owned[milestone.id] == true
    local reached = type(score) == "number" and score < math.huge and score >= milestone.score
    if already or reached then result[milestone.id] = true end
    if reached and not already then earned[#earned + 1] = milestone.id end
  end
  return result, earned
end

function Unlocks.restore(saved)
  local owned = Unlocks.award(saved.owned_colors)
  local pending = {}
  if (saved.color_progression_version or 0) < Unlocks.VERSION then
    for _, entry in ipairs(saved.high_scores or {}) do owned = Unlocks.award(owned, entry.score) end
    if saved.session and saved.session.phase == "results" then
      owned = Unlocks.award(owned, saved.session.score)
    end
    if saved.color_progression_version == nil and Unlocks.required(saved.theme) then owned[saved.theme] = true end
  end
  if saved.color_progression_version ~= nil then
    local seen = {}
    for _, id in ipairs(saved.pending_colors or {}) do
      if Unlocks.required(id) and owned[id] and not seen[id] then
        pending[#pending + 1], seen[id] = id, true
      end
    end
  end
  local selected = owned[saved.theme] and saved.theme or "classic"
  return owned, selected, pending
end

return Unlocks
