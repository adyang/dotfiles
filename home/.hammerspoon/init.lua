local hotkey = require("hs.hotkey")
local grid = require("hs.grid")
local window = require("hs.window")
local alert = require("hs.alert")

local cmdAltCtrl = {"cmd", "alt", "ctrl"}

grid.setGrid('4x4')
grid.setMargins({0, 0})

hotkey.bind(cmdAltCtrl, "M", grid.maximizeWindow)

hotkey.bind(cmdAltCtrl, ";", function()
    grid.set(window.focusedWindow(), {x=0,y=0,w=2,h=4})
end)
hotkey.bind(cmdAltCtrl, "'", function()
    grid.set(window.focusedWindow(), {x=2,y=0,w=2,h=4})
end)
hotkey.bind(cmdAltCtrl, "I", function()
    grid.set(window.focusedWindow(), {x=0,y=0,w=4,h=2})
end)
hotkey.bind(cmdAltCtrl, "M", function()
    grid.set(window.focusedWindow(), {x=0,y=2,w=4,h=2})
end)
hotkey.bind(cmdAltCtrl, "Y", function()
    grid.set(window.focusedWindow(), {x=0,y=0,w=2,h=2})
end)
hotkey.bind(cmdAltCtrl, "U", function()
    grid.set(window.focusedWindow(), {x=2,y=0,w=2,h=2})
end)
hotkey.bind(cmdAltCtrl, "B", function()
    grid.set(window.focusedWindow(), {x=0,y=2,w=2,h=2})
end)
hotkey.bind(cmdAltCtrl, "N", function()
    grid.set(window.focusedWindow(), {x=2,y=2,w=2,h=2})
end)

hotkey.bind(cmdAltCtrl, ".", grid.resizeWindowWider)
hotkey.bind(cmdAltCtrl, ",", grid.resizeWindowThinner)
hotkey.bind(cmdAltCtrl, "P", grid.resizeWindowTaller)
hotkey.bind(cmdAltCtrl, "O", grid.resizeWindowShorter)

hotkey.bind(cmdAltCtrl, "J", grid.pushWindowDown)
hotkey.bind(cmdAltCtrl, "K", grid.pushWindowUp)
hotkey.bind(cmdAltCtrl, "H", grid.pushWindowLeft)
hotkey.bind(cmdAltCtrl, "L", grid.pushWindowRight)

hotkey.bind(cmdAltCtrl, "]", grid.pushWindowNextScreen)
hotkey.bind(cmdAltCtrl, "[", grid.pushWindowPrevScreen)

hotkey.bind(cmdAltCtrl, "R", hs.reload)

alert.show("Hammerspoon config loaded")
