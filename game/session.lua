local Session = {}
Session.__index = Session
local function copy(value)
  if type(value) ~= "table" then return value end
  local out = {}
  for key, item in pairs(value) do out[key] = copy(item) end
  return out
end
local function roll_face(state)
  state.rng = (state.rng * 16807) % 2147483647
  return state.rng % 6 + 1
end
local function initial_roll(state)
  state.dice, state.held, state.placements = {}, {}, {}
  for i = 1, 5 do
    state.dice[i], state.held[i], state.placements[i] = roll_face(state), false, 0
  end
  state.rolls_used, state.phase = 1, "rolling"
end
function Session.new(joker, seed)
  assert(joker == "pair_pay" or joker == "short_run" or joker == "thrifty", "unknown joker")
  local state = {joker = joker, rng = ((math.floor(seed or 1) - 1) % 2147483646) + 1,
    board = {}, scored_lines = {}, score = 0, turn = 1, adjustments = 2, turn_bonus_total = 0}
  for i = 1, 25 do state.board[i] = 0 end
  initial_roll(state)
  return Session.resume(state)
end
function Session.resume(snapshot)
  return setmetatable({state = copy(snapshot), boundary = copy(snapshot), history = {}}, Session)
end
function Session:view() return copy(self.state) end
function Session:snapshot() return copy(self.boundary) end
function Session:toggle_hold(i)
  local s = self.state
  if s.phase ~= "rolling" or not s.dice[i] then return nil, "Cannot hold this die" end
  s.held[i] = not s.held[i]
  return true
end
function Session:roll()
  local s = self.state
  if s.phase ~= "rolling" or s.rolls_used >= 3 then return nil, "No rolls available" end
  for i = 1, 5 do if not s.held[i] then s.dice[i] = roll_face(s) end end
  s.rolls_used = s.rolls_used + 1
  if s.rolls_used == 3 then s.phase = "placing" end
  return true
end
function Session:begin_placement()
  if self.state.phase ~= "rolling" then return nil, "Already placing" end
  self.state.phase = "placing"
  return true
end
function Session:place(i, cell)
  local s = self.state
  if s.phase ~= "placing" or not s.dice[i] or type(cell) ~= "number"
    or cell % 1 ~= 0 or not s.board[cell] or s.board[cell] ~= 0 then
    return nil, "Choose an empty cell"
  end
  for die = 1, 5 do
    if die ~= i and s.placements[die] == cell then return nil, "Cell occupied" end
  end
  self.history[#self.history + 1] = copy(s)
  s.placements[i] = cell
  return true
end
function Session:unplace(i)
  local s = self.state
  if s.phase ~= "placing" or not s.placements[i] or s.placements[i] == 0 then
    return nil, "Die is not placed"
  end
  self.history[#self.history + 1] = copy(s)
  s.placements[i] = 0
  return true
end
function Session:adjust(i, delta)
  local s = self.state
  if s.phase ~= "placing" or not s.dice[i] or s.placements[i] ~= 0
    or s.adjustments == 0 or (delta ~= -1 and delta ~= 1)
    or s.dice[i] + delta < 1 or s.dice[i] + delta > 6 then
    return nil, "Adjustment unavailable"
  end
  self.history[#self.history + 1] = copy(s)
  s.dice[i], s.adjustments = s.dice[i] + delta, s.adjustments - 1
  return true
end
function Session:undo()
  if self.state.phase ~= "placing" or #self.history == 0 then return nil, "Nothing to undo" end
  self.state = table.remove(self.history)
  return true
end

local Scoring = require("scoring")
function Session:preview(die, cell)
  local s = self.state
  local board = copy(s.board)
  for i = 1, 5 do
    if s.placements[i] ~= 0 then board[s.placements[i]] = s.dice[i] end
  end
  -- A hypothetical die uses the same eligibility as placement, without history or RNG.
  if die ~= nil or cell ~= nil then
    if s.phase ~= "placing" or not s.dice[die] or s.placements[die] ~= 0
      or type(cell) ~= "number" or cell % 1 ~= 0 or board[cell] ~= 0 then
      return nil, "Choose an unplaced die and empty cell"
    end
    board[cell] = s.dice[die]
  end
  local result = {lines = {}, events = {}, turn_bonus = 0, total = s.score, points = 0}
  if s.phase ~= "placing" then return result end
  for direction = 1, 2 do
    for line = 1, 5 do
      local id = (direction == 1 and "row" or "column") .. line
      local faces, complete = {}, true
      for offset = 1, 5 do
        local cell = direction == 1 and (line - 1) * 5 + offset or (offset - 1) * 5 + line
        faces[offset] = board[cell]
        if faces[offset] == 0 then complete = false end
      end
      if complete and not s.scored_lines[id] then
        local scored = Scoring.evaluate(faces, s.joker)
        scored.id, scored.faces = id, faces
        result.lines[#result.lines + 1] = scored
        result.events[#result.events + 1] = {kind = "line", line = id, category = scored.category, points = scored.base_score}
        if scored.joker_bonus > 0 then
          result.events[#result.events + 1] = {kind = "joker", line = id, joker = s.joker, points = scored.joker_bonus}
        end
        result.points = result.points + scored.total
      end
    end
  end
  if s.joker == "thrifty" then
    result.turn_bonus = (3 - s.rolls_used) * 5
    if result.turn_bonus > 0 then
      result.events[#result.events + 1] = {kind = "joker", joker = s.joker, points = result.turn_bonus}
    end
  end
  result.points = result.points + result.turn_bonus
  result.total = s.score + result.points
  return result
end
function Session:confirm()
  local s = self.state
  if s.phase ~= "placing" then return nil, "Place all five dice first" end
  for i = 1, 5 do if s.placements[i] == 0 then return nil, "Place all five dice first" end end
  local preview = self:preview()
  for i = 1, 5 do s.board[s.placements[i]] = s.dice[i] end
  for _, line in ipairs(preview.lines) do s.scored_lines[line.id] = true end
  s.score = preview.total
  if s.turn_bonus_total ~= nil then s.turn_bonus_total = s.turn_bonus_total + preview.turn_bonus end
  local boundary = copy(s)
  if s.turn == 5 then
    boundary.phase = "results"
  else
    boundary.turn = s.turn + 1
    initial_roll(boundary)
  end
  -- Establish the committed save before presentation starts resolving events.
  self.boundary, self.history = boundary, {}
  s.phase = "resolving"
  return copy(preview.events)
end
function Session:finish_scoring()
  if self.state.phase ~= "resolving" then return nil, "No scoring to finish" end
  self.state = copy(self.boundary)
  return true
end
return Session
