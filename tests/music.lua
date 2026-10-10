local calls = {}
music = {
  play_ex = function(...) calls.start = {...} end,
  mutate = function(...) calls.volume = {...} end,
}
local Music = require("ui.music")
Music.start()
assert(calls.start[1] == "vaporware" and calls.start[2] == 0.16)
assert(calls.start[3] == 1 and calls.start[4] == 0 and calls.start[5] == true)
Music.update(0.1, true)
assert(calls.volume[1] > 0.08 and calls.volume[1] < 0.16, "Duck smoothly during payouts")
Music.update(1, true)
assert(math.abs(calls.volume[1] - 0.08) < 0.000001)
Music.update(1, false)
assert(math.abs(calls.volume[1] - 0.16) < 0.000001, "Restore quiet baseline after payouts")
