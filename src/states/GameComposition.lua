local Game = {}

local Bump = require "libs.bump"
local Vector2 = require "engine.math.vector2"
local Camera = require "engine.misc.camera"
local Easing = require "engine.math.easing"

CompositionManager = require "engine.composition.compositionManager"
EntityBuilder = require "composition.entityBuilder"

local world = Bump.newWorld(32)
local camera = Camera(Vector2(WIDTH/2, 0), 1)
local player = nil ---@type Entity

local maxHeight = 0

function Game:enter()
    CompositionManager.clear()

    camera:setInterpolation(Easing.cubic, 30)
    player = EntityBuilder.player(world, Vector2(100, 100), camera)

    CompositionManager.addEntity(player)
    CompositionManager.addEntity(EntityBuilder.enemy(world, Vector2(350, 200)))
    CompositionManager.addEntity(EntityBuilder.wall(world, Vector2(50, 200), Vector2(300, 32)))
    CompositionManager.addEntity(EntityBuilder.wall(world, Vector2(280, 400), Vector2(300, 32)))
end

function Game:draw()
    lg.clear(.5, .5, 1)
    camera:attach()

    CompositionManager.broadcastToAllComponents("draw")

    camera:detach()
end

function Game:update(dt)
    CompositionManager.broadcastToAllComponents("update", dt)
    camera:update(dt)

    maxHeight = math.min(maxHeight, (player:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]).position.y)
    camera.position.y = maxHeight

    if player:getComponent("DamageableComponent").health <= 0 then
        Game:enter()
    end
end

function Game:keypressed(key)
    CompositionManager.broadcastToAllComponents("keypressed", key)
end

function Game:mousepressed(x, y, button)
    CompositionManager.broadcastToAllComponents("mousepressed", x, y, button)
end

return Game