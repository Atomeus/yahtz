-- Run with: usagi run test.lua
local suites = {"application", "color_unlocks", "jokers", "results_summary", "high_scores", "music", "scoring", "scoring_feedback", "session", "themes"}
local engine_gfx = gfx
local results = {}

function _config()
  return {name = "Yahtz tests", game_width = 480, game_height = 270}
end

function _init()
  local baseline, loaded = {}, {}
  for key, value in pairs(_G) do baseline[key] = value end
  for key, value in pairs(package.loaded) do loaded[key] = value end
  for _, name in ipairs(suites) do
    local ok, err = pcall(require, "tests." .. name)
    results[#results + 1] = {name = name, ok = ok, error = err}
    print((ok and "PASS " or "FAIL ") .. "tests/" .. name .. ".lua")
    if not ok then print(tostring(err)) end
    -- Each suite gets fresh game modules and the real engine adapters.
    for key in pairs(package.loaded) do
      if loaded[key] == nil then package.loaded[key] = nil end
    end
    for key in pairs(_G) do
      if baseline[key] == nil then _G[key] = nil end
    end
    for key, value in pairs(baseline) do _G[key] = value end
  end
end

function _update(dt)
  for _, result in ipairs(results) do if not result.ok then return end end
  usagi.quit()
end

function _draw()
  engine_gfx.clear(engine_gfx.COLOR_BLACK)
  engine_gfx.text("YAHTZ TESTS", 16, 16, engine_gfx.COLOR_WHITE)
  for i, result in ipairs(results) do
    engine_gfx.text((result.ok and "PASS " or "FAIL ") .. result.name, 16, 28 + i * 22,
      result.ok and engine_gfx.COLOR_GREEN or engine_gfx.COLOR_RED)
  end
  engine_gfx.text("Failure details are printed in the console.", 16, 220, engine_gfx.COLOR_WHITE)
end
