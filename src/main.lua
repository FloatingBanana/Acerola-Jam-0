-- VS Code debugger
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
end

-- Misc
local GS = require "libs.gamestate"
local Utils = require "engine.misc.utils"
local InputHelper = require "engine.misc.inputHelper"
local TransitionManager = require "engine.transitions.transitionManager"

local Game = require "states.GameComposition"
local Splash = require "states.Splash2"

function love.load(args)
    love.mouse.setGrabbed(true)

    InputHelper.registerAxis("horizontal", {"a", "left"}, {"d", "right"})
    InputHelper.registerAxis("vertical", {"w", "up"}, {"s", "down"})

    GS.registerEvents({"update"})
    GS.switch(Game)
end


function love.draw() ---@diagnostic disable-line: duplicate-set-field
    GS.draw()

    TransitionManager.draw()

    Utils.setFont(13)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print("FPS: " .. love.timer.getFPS())
end

function love.update(dt)
    TransitionManager.update(dt)
end



function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end

    GS.keypressed(key)
end

function love.keyreleased(key, ...)
    GS.keyreleased(key, ...)
end

function love.textinput(t)
    GS.textinput(t)
end

function love.mousemoved(x, y, ...)
    GS.mousemoved(x, y, ...)
end

function love.mousepressed(x, y, button, ...)
    GS.mousepressed(x, y, button, ...)
end

function love.mousereleased(x, y, button, ...)
    GS.mousereleased(x, y, button, ...)
end

function love.wheelmoved(x, y)
    GS.wheelmoved(x, y)
end