local Game = {}

local Bump    = require "libs.bump"
local Vector2 = require "engine.math.vector2"
local Camera  = require "engine.misc.camera"
local Easing  = require "engine.math.easing"
local Utils   = require "engine.misc.utils"
local Lume    = require "engine.3rdparty.lume"

local HDR = require("engine.postProcessing.hdr")(SCREENSIZE, 1)
local Bloom = require("engine.postProcessing.bloom")(SCREENSIZE, 3, 1)
local ChromaticAberration = require("engine.postProcessing.chromaticAberration")(SCREENSIZE, 1)

CompositionManager = require "engine.composition.compositionManager"
EntityBuilder = require "composition.entityBuilder"

local screenCanvas = love.graphics.newCanvas(WIDTH, HEIGHT, {format = "rgba16f"})
local world = Bump.newWorld(32)
local camera = Camera(Vector2(WIDTH/2, 0), 1)
local player = nil ---@type Entity

---@class GameData
local gameData = {
    maxHeight = 0,
    enemySpawn = -500,

    timeSpeed = 1,
    targetTimeSpeed = 1,

    gameStarted = false
}

function Game:enter()
    CompositionManager.clear()

    gameData.maxHeight = 0
    gameData.enemySpawn = -500

    camera.actualPosition.y = 0
    camera:setInterpolation(Easing.cubic, 30)

    player = EntityBuilder.player(world, Vector2(WIDTH / 2, HEIGHT - 300), camera)
    player:getComponent("BodyComponent").velocity.y = -700

    CompositionManager.addEntity(player)
end

function Game:draw()
    love.graphics.setCanvas(screenCanvas)
        lg.clear(.5, .5, 1)
        camera:attach()

        CompositionManager.broadcastToAllComponents("draw")

        camera:detach()
    love.graphics.setCanvas()

    -- Post processing
    -- Bloom.bloomAmount = 0.01
    local result = screenCanvas
    result = Bloom:onPostRender(nil, result)
    result = HDR:onPostRender(nil, screenCanvas)
    result = ChromaticAberration:onPostRender(nil, result)

    love.graphics.draw(result)

    Utils.setFont(15)
    love.graphics.print(("Height: %d"):format(-gameData.maxHeight), 0, 40)
    love.graphics.print(gameData.timeSpeed, 0, 80)


end

function Game:update(dt)
    dt = love.timer.getAverageDelta()

    CompositionManager.broadcastToAllComponents("update", dt * gameData.timeSpeed)
    camera:update(math.min(dt, 1))

    local bounds = camera:getBounds()
    local playerTransform = player:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local playerDamageable = player:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    gameData.maxHeight = math.min(gameData.maxHeight, playerTransform.position.y + HEIGHT/4)
    camera.position.y = gameData.maxHeight

    if playerDamageable.health <= 0 then
        Game:enter()
    end


    -- Spawn enemies
    if gameData.maxHeight < gameData.enemySpawn then
        local enemyPos = Vector2(math.random(0, WIDTH-32), bounds.topLeft.y - 32)
        CompositionManager.addEntity(EntityBuilder.enemy(world, enemyPos, player, camera))

        gameData.enemySpawn = gameData.enemySpawn - 500
    end

    -- Time slow
    gameData.targetTimeSpeed = love.keyboard.isDown("lctrl") and 0.2 or 1
    gameData.timeSpeed = Lume.lerp(gameData.timeSpeed, gameData.targetTimeSpeed, Easing.quadratic(dt*10))
    ChromaticAberration:setOffset((1 - gameData.timeSpeed) * 3)
end

function Game:keypressed(key)
    CompositionManager.broadcastToAllComponents("keypressed", key)
end

function Game:mousepressed(x, y, button)
    CompositionManager.broadcastToAllComponents("mousepressed", x, y, button)
end

function Game:wheelmoved(x, y)
    CompositionManager.broadcastToAllComponents("wheelmoved", x, y)
end

return Game