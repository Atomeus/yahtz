local Music = require("ui.music")
local Themes = require("ui.themes")
local ThemeSelection = require("screens.theme_selection")
local HighScores = require("game.high_scores")
local Session = require("game.session")
local Controls = require("ui.controls")
local MainMenu = require("screens.main_menu")
local Credits = require("screens.credits")
local NameEntry = require("screens.name_entry")
local JokerSelection = require("screens.joker_selection")
local GameScreen = require("screens.game")

function _config()
  return { name = "Yahtz - The little dice table", game_id = "com.ethan.yahtz", game_width = 480, game_height = 270, pixel_perfect = true }
end

local function save()
  usagi.save({ theme = State.theme, session = State.session and State.session:snapshot(), reduced_motion = State.reduced_motion, ledger = State.ledger, high_scores = State.high_scores or {}, high_score_handled = State.high_score_handled or false })
end

function _init()
  Music.start()
  local saved = usagi.load() or {}
  State = { theme = Themes.get(saved.theme).id, screen = "menu", focus = 1, time = 0, reduced_motion = saved.reduced_motion or false, selected = 1, buttons = {}, events = {}, event_index = 1, event_timer = 0, ledger_offset = 1, ledger = saved.ledger or {}, high_scores = saved.high_scores or {}, high_score_handled = saved.high_score_handled or false }
  if saved.session then
    local ok, session = pcall(function() return Session.resume(saved.session) end)
    if ok and session then State.session = session end
  end
end

local function navigate(screen, focus)
  if screen == "themes" then
    State.theme_return = { screen = State.screen, focus = State.focus }
  end
  State.screen, State.focus = screen, focus
end

local function return_from_themes()
  local destination = State.theme_return or { screen = "menu", focus = 1 }
  State.theme_return = nil
  navigate(destination.screen, destination.focus)
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

local function select_theme(id)
  State.theme = Themes.get(id).id
  save()
end

function _update(dt)
  State.time = State.time + dt
  Music.update(dt, State.screen == "game" and State.session ~= nil and State.session:view().phase == "resolving")
  Controls.update(State)
  if State.session and State.screen == "game" then
    GameScreen.update(State, dt, save, offer_high_score)
  elseif State.screen == "credits" then
    Credits.update(navigate)
  end
end

function _draw()
  State.buttons = {}
  Themes.use(State.theme)
  local colors = Themes.colors()
  gfx.clear(colors.panel)
  gfx.rect_fill(8, 8, 464, 254, colors.frame)
  gfx.rect_fill(12, 12, 456, 246, colors.table)
  if State.screen == "menu" then MainMenu.draw(State, navigate, offer_high_score, toggle_motion)
  elseif State.screen == "credits" then Credits.draw(State, navigate)
  elseif State.screen == "themes" then ThemeSelection.draw(State, return_from_themes, select_theme)
  elseif State.screen == "name_entry" then NameEntry.draw(State, navigate, save)
  elseif State.screen == "jokers" then JokerSelection.draw(State, navigate, start)
  else GameScreen.draw(State, navigate, save, offer_high_score) end
end
