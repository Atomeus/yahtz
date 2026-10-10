local Music = require("ui.music")
local Themes = require("ui.themes")
local ThemeSelection = require("screens.theme_selection")
local Session = require("game.session")
local Controls = require("ui.controls")
local MainMenu = require("screens.main_menu")
local Credits = require("screens.credits")
local NameEntry = require("screens.name_entry")
local JokerSelection = require("screens.joker_selection")
local GameScreen = require("screens.game")
local Results = require("screens.results")
local ColorUnlocks = require("game.color_unlocks")
local Jokers = require("game.jokers")

local function new_seed()
  return ((math.floor((usagi.elapsed or 0) * 1000000) + os.time() - 1) % 2147483646) + 1
end

local function deal_jokers()
  -- Dev reload preserves State without rerunning _init from the new version.
  State.draft_seed = ((State.draft_seed or new_seed()) * 16807) % 2147483647
  State.joker_choices = Jokers.deal(State.draft_seed)
end

function _config()
  return { name = "Yahtz - The little dice table", game_id = "com.ethan.yahtz", game_width = 480, game_height = 270, pixel_perfect = true }
end

local function save()
  local boundary = State.session and State.session:snapshot()
  if boundary and boundary.phase == "results" then
    local owned, earned = ColorUnlocks.award(State.owned_colors, boundary.score)
    State.owned_colors = owned
    for _, id in ipairs(earned) do State.pending_colors[#State.pending_colors + 1] = id end
  end
  if boundary and boundary.phase == "results" and State.results_previous_best == nil
    and State.results_record_known then
    State.results_previous_best = State.high_scores[1] and State.high_scores[1].score or false
  end
  usagi.save({ theme = State.theme, session = boundary, reduced_motion = State.reduced_motion, ledger = State.ledger, high_scores = State.high_scores or {}, high_score_handled = State.high_score_handled or false, results_previous_best = State.results_previous_best, results_record_known = State.results_record_known, color_progression_version = ColorUnlocks.VERSION, owned_colors = State.owned_colors, pending_colors = State.pending_colors })
end

function _init()
  Music.start()
  local saved = usagi.load() or {}
  State = { theme = Themes.get(saved.theme).id, screen = "menu", focus = 1, time = 0, reduced_motion = saved.reduced_motion or false, selected = 1, buttons = {}, events = {}, event_index = 1, event_timer = 0, ledger_offset = 1, ledger = saved.ledger or {}, high_scores = saved.high_scores or {}, high_score_handled = saved.high_score_handled or false }
  State.results_previous_best, State.results_record_known = saved.results_previous_best, saved.results_record_known
  State.owned_colors, State.theme, State.pending_colors = ColorUnlocks.restore(saved)
  State.draft_seed = new_seed()
  if saved.session then
    local ok, session = pcall(function() return Session.resume(saved.session) end)
    if ok and session then State.session = session end
  end
  if (saved.color_progression_version or 0) < ColorUnlocks.VERSION then save() end
end

local function navigate(screen, focus)
  if screen == "jokers" and State.screen ~= "jokers" then
    deal_jokers()
  end
  if State.screen == "results" and screen ~= "results" then
    State.pending_colors = {}
    save()
  end
  if screen == "themes" then
    State.colors_preview = State.theme
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
  local offered = false
  for _, id in ipairs(State.joker_choices or {}) do if id == joker then offered = true end end
  if not offered then return end
  State.session = Session.new(joker, new_seed())
  State.screen, State.focus, State.selected = "game", 26, 1
  State.events, State.ledger = {}, {}
  State.pending_colors = {}
  State.game_menu_focus = nil
  State.high_score_handled = false
  State.results_previous_best, State.results_record_known = nil, true
  save()
end

local function offer_high_score()
  if State.session:view().phase ~= "results" then return false end
  Results.open(State, navigate)
  return true
end

local function enter_name()
  if Results.pending(State) then State.entry_name = ""; navigate("name_entry", 100) end
end

local function toggle_motion()
  State.reduced_motion = not State.reduced_motion
  save()
end

local function select_theme(id)
  if not State.owned_colors[id] then return end
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
  elseif State.screen == "menu" then
    MainMenu.update(State)
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
  elseif State.screen == "results" then Results.draw(State, navigate, save, enter_name)
  elseif State.screen == "jokers" then
    if not State.joker_choices then deal_jokers() end
    JokerSelection.draw(State, navigate, start)
  else GameScreen.draw(State, navigate, save, offer_high_score) end
end
