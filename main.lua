local HighScores = require("game.high_scores")
local Session = require("game.session")
local Controls = require("ui.controls")
local MainMenu = require("screens.main_menu")
local NameEntry = require("screens.name_entry")
local JokerSelection = require("screens.joker_selection")
local GameScreen = require("screens.game")

function _config()
  return { name = "Yahtz - The little dice table", game_id = "com.ethan.yahtz", game_width = 480, game_height = 270, pixel_perfect = true }
end

local function save()
  usagi.save({ session = State.session and State.session:snapshot(), reduced_motion = State.reduced_motion, ledger = State.ledger, high_scores = State.high_scores or {}, high_score_handled = State.high_score_handled or false })
end

function _init()
  local saved = usagi.load() or {}
  State = { screen = "menu", focus = 1, time = 0, reduced_motion = saved.reduced_motion or false, selected = 1, buttons = {}, events = {}, event_index = 1, event_timer = 0, ledger_offset = 1, ledger = saved.ledger or {}, high_scores = saved.high_scores or {}, high_score_handled = saved.high_score_handled or false }
  if saved.session then
    local ok, session = pcall(function() return Session.resume(saved.session) end)
    if ok and session then State.session = session end
  end
end

local function navigate(screen, focus)
  State.screen, State.focus = screen, focus
end

local function start(joker)
  State.session = Session.new(joker, math.floor(usagi.elapsed * 1000000) + os.time())
  State.screen, State.focus, State.selected = "game", 26, 1
  State.events, State.ledger = {}, {}
  State.high_score_handled = false
  save()
end

local function offer_high_score()
  if State.session:view().phase ~= "results" or State.high_score_handled then return false end
  if HighScores.qualifies(State.high_scores or {}, State.session:view().score) then
    State.screen, State.entry_name, State.focus = "name_entry", "", 100
    return true
  end
  State.high_score_handled = true
  save()
  return false
end

local function toggle_motion()
  State.reduced_motion = not State.reduced_motion
  save()
end

function _update(dt)
  State.time = State.time + dt
  Controls.update(State)
  if State.session and State.screen == "game" then
    GameScreen.update(State, dt, save, offer_high_score)
  end
end

function _draw()
  State.buttons = {}
  gfx.clear(gfx.COLOR_DARK_BLUE)
  gfx.rect_fill(8, 8, 464, 254, gfx.COLOR_BROWN)
  gfx.rect_fill(12, 12, 456, 246, gfx.COLOR_DARK_GREEN)
  if State.screen == "menu" then MainMenu.draw(State, navigate, offer_high_score)
  elseif State.screen == "name_entry" then NameEntry.draw(State, navigate, save)
  elseif State.screen == "jokers" then JokerSelection.draw(State, navigate, start, toggle_motion)
  else GameScreen.draw(State, navigate, save, offer_high_score, toggle_motion) end
end
