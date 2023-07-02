local hotkey = require("hs.hotkey")
local grid = require("hs.grid")
local window = require("hs.window")
local alert = require("hs.alert")

local cmdAltCtrl = {"cmd", "alt", "ctrl"}

grid.setGrid('4x4')
grid.setMargins({0, 0})

hotkey.bind(cmdAltCtrl, "M", grid.maximizeWindow)

local function tileTo(cell)
    return function() grid.set(window.focusedWindow(), cell) end
end
local cells = {
    left = {x=0,y=0,w=2,h=4},
    right = {x=2,y=0,w=2,h=4},
    top = {x=0,y=0,w=4,h=2},
    bottom = {x=0,y=2,w=4,h=2},
    topLeft = {x=0,y=0,w=2,h=2},
    topRight = {x=2,y=0,w=2,h=2},
    bottomLeft = {x=0,y=2,w=2,h=2},
    bottomRight = {x=2,y=2,w=2,h=2}
}
hotkey.bind(cmdAltCtrl, ";", tileTo(cells.left))
hotkey.bind(cmdAltCtrl, "'", tileTo(cells.right))
hotkey.bind(cmdAltCtrl, "P", tileTo(cells.top))
hotkey.bind(cmdAltCtrl, "/", tileTo(cells.bottom))
hotkey.bind(cmdAltCtrl, "Y", tileTo(cells.topLeft))
hotkey.bind(cmdAltCtrl, "U", tileTo(cells.topRight))
hotkey.bind(cmdAltCtrl, "B", tileTo(cells.bottomLeft))
hotkey.bind(cmdAltCtrl, "N", tileTo(cells.bottomRight))

hotkey.bind(cmdAltCtrl, ".", grid.resizeWindowWider)
hotkey.bind(cmdAltCtrl, ",", grid.resizeWindowThinner)
hotkey.bind(cmdAltCtrl, "O", grid.resizeWindowTaller)
hotkey.bind(cmdAltCtrl, "I", grid.resizeWindowShorter)

hotkey.bind(cmdAltCtrl, "J", grid.pushWindowDown)
hotkey.bind(cmdAltCtrl, "K", grid.pushWindowUp)
hotkey.bind(cmdAltCtrl, "H", grid.pushWindowLeft)
hotkey.bind(cmdAltCtrl, "L", grid.pushWindowRight)

hotkey.bind(cmdAltCtrl, "]", grid.pushWindowNextScreen)
hotkey.bind(cmdAltCtrl, "[", grid.pushWindowPrevScreen)

hotkey.bind(cmdAltCtrl, "R", hs.reload)

alert.show("Hammerspoon config loaded")
