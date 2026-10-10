local Music = {}
local volume = 0.16

function Music.start()
  volume = 0.16
  music.play_ex("vaporware", volume, 1, 0, true)
end

function Music.update(dt, scoring)
  local target = scoring and 0.08 or 0.16
  volume = volume + (target - volume) * math.min(1, dt * 5)
  music.mutate(volume, 1, 0)
end

return Music
