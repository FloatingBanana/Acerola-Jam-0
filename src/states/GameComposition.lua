local Game = {}

local Bump = require "libs.bump"
local Vector2 = require "engine.math.vector2"
local Entity = require "engine.composition.entity"

CompositionManager = require "engine.composition.compositionManager"
EntityBuilder = require "composition.entityBuilder"

local world = Bump.newWorld(32)

function Game:enter()
    CompositionManager.clear()

    CompositionManager.addEntity(EntityBuilder.player(world, Vector2(100, 100)))
    CompositionManager.addEntity(EntityBuilder.enemy(world, Vector2(350, 200)))
    CompositionManager.addEntity(EntityBuilder.wall(world, Vector2(50, 200), Vector2(300, 32)))
    CompositionManager.addEntity(EntityBuilder.wall(world, Vector2(280, 400), Vector2(300, 32)))
end

function Game:draw()
    CompositionManager.broadcastToAllComponents("draw")
end

function Game:update(dt)
    CompositionManager.broadcastToAllComponents("update", dt)
end

function Game:keypressed(key)
    CompositionManager.broadcastToAllComponents("keypressed", key)
end

function Game:mousepressed(x, y, button)
    CompositionManager.broadcastToAllComponents("mousepressed", x, y, button)
end

return Game