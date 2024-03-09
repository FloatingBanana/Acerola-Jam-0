local Game = {}

local Bump = require "libs.bump"
local Vector2 = require "engine.math.vector2"
local Camera = require "engine.misc.camera"
local Easing = require "engine.math.easing"
local Utils = require "engine.misc.utils"

CompositionManager = require "engine.composition.compositionManager"
EntityBuilder = require "composition.entityBuilder"

local world = Bump.newWorld(32)
local camera = Camera(Vector2(WIDTH/2, 0), 1)
local player = nil ---@type Entity
local maxHeight = 0

local enemySpawn = -500

function Game:enter()
    CompositionManager.clear()

    maxHeight = 0
    enemySpawn = -500
    camera.actualPosition.y = 0
    camera:setInterpolation(Easing.cubic, 30)
    player = EntityBuilder.player(world, Vector2(WIDTH / 2, HEIGHT - 300), camera)

    player:getComponent("BodyComponent").velocity.y = -700

    CompositionManager.addEntity(player)
end

function Game:draw()
    lg.clear(.5, .5, 1)
    camera:attach()

    CompositionManager.broadcastToAllComponents("draw")

    camera:detach()

    Utils.setFont(15)
    love.graphics.print(("Height: %d"):format(-maxHeight), 0, 40)
end

function Game:update(dt)
    CompositionManager.broadcastToAllComponents("update", dt)
    camera:update(dt)

    local bounds = camera:getBounds()


    local playerTransform = player:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local playerDamageable = player:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    maxHeight = math.min(maxHeight, playerTransform.position.y + HEIGHT/4)
    camera.position.y = maxHeight

    if playerDamageable.health <= 0 then
        Game:enter()
    end


    if maxHeight < enemySpawn then
        local enemyPos = Vector2(math.random(0, WIDTH-32), bounds.topLeft.y - 32)
        CompositionManager.addEntity(EntityBuilder.enemy(world, enemyPos, player, camera))

        enemySpawn = enemySpawn - 500
    end
end

function Game:keypressed(key)
    CompositionManager.broadcastToAllComponents("keypressed", key)
end

function Game:mousepressed(x, y, button)
    CompositionManager.broadcastToAllComponents("mousepressed", x, y, button)
end

return Game