local Themes = require("ui.themes")
local Controls = require("ui.controls")
local Drawing = require("ui.drawing")
local Credits = {}

function Credits.update(navigate)
  if input.pressed(input.BTN2) then navigate("menu", 5) end
end

function Credits.draw(state, navigate)
  local colors = Themes.colors()
  Drawing.text("CREDITS", 32, 28, colors.accent)
  Drawing.text("MUSIC", 32, 66, colors.secondary)
  Drawing.text("Vaporware (Calm Piano 1)", 32, 86, colors.text)
  Drawing.text("The Cynic Project", 32, 104, colors.text)
  Drawing.text("cynicmusic.com / pixelsphere.org", 32, 122, colors.secondary)
  Drawing.text("CC0 1.0 Universal - public domain dedication", 32, 146, colors.secondary)
  Drawing.text("Available on OpenGameArt.org", 32, 164, colors.muted)
  Drawing.text("ENGINE", 32, 192, colors.secondary)
  Drawing.text("Made with Usagi", 32, 210, colors.text)
  Controls.button(state, 1, 32, 238, 144, 20, "Main menu", function()
    navigate("menu", 5)
  end)
end

return Credits
