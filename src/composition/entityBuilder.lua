local Vector2 = require "engine.math.vector2"
local Entity = require "engine.composition.entity"
local Transform2d = require "composition.components.transform2dComponent"
local ShapeDraw = require "composition.components.shapeDrawComponent"
local Body = require "composition.components.bodyComponent"
local PlayerController = require "composition.components.playerControllerComponent"
local Bullet = require "composition.components.bulletComponent"

local Builder = {}


function Builder.player(world, pos)
    local player = Entity()

    player:attachComponents(Transform2d(pos, Vector2(32, 32)))
    player:attachComponents(ShapeDraw("rectangle", false, {1,1,1}, 2))
    player:attachComponents(PlayerController())
    player:attachComponents(Body(world, 3, Vector2(2, 0)))

    return player
end

function Builder.wall(world, pos, size)
    local wall = Entity()
    wall:attachComponents(Transform2d(pos, size))
    wall:attachComponents(ShapeDraw("rectangle", true, {1,0,1}, 1))
    wall:attachComponents(Body(world, 0, Vector2(4)))

    return wall
end

function Builder.bullet(world, pos, dir, damage)
    local bullet = Entity()
    bullet:attachComponents(Transform2d(pos, Vector2(8,8)))
    bullet:attachComponents(ShapeDraw("circle", true, {1,0,.2}, 1))
    bullet:attachComponents(Body(world, 0, Vector2(), Vector2()))
    bullet:attachComponents(Bullet(dir, damage))

    return bullet
end

return Builder