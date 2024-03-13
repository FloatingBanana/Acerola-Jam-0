local Vector2 = require "engine.math.vector2"
local Entity = require "engine.composition.entity"
local Transform2d = require "composition.components.transform2dComponent"
local ShapeDraw = require "composition.components.shapeDrawComponent"
local Body = require "composition.components.bodyComponent"
local PlayerController = require "composition.components.playerControllerComponent"
local Bullet = require "composition.components.bulletComponent"
local Damageable = require "composition.components.damageableComponent"
local Enemy = require "composition.components.enemyComponent"
local CharacterBehavior = require "composition.components.characterBehavior"
local JetpackEnemy = require "composition.components.jetpackEnemyComponent"

local Builder = {}


---@param world unknown
---@param pos Vector2
---@param camera Camera
---@return Entity
function Builder.player(world, pos, camera)
    local player = Entity()

    player:attachComponents(Transform2d(pos, Vector2(32, 32)))
    player:attachComponents(PlayerController(camera))
    player:attachComponents(Body(world, 2, Vector2(2, 0)))
    player:attachComponents(Damageable(50, 50, 2))
    player:attachComponents(CharacterBehavior(camera))

    player:getComponent("BodyComponent").pushable = false

    return player
end


---@param world unknown
---@param pos Vector2
---@param size Vector2
---@return Entity
function Builder.wall(world, pos, size)
    local wall = Entity()
    wall:attachComponents(Transform2d(pos, size))
    wall:attachComponents(ShapeDraw("rectangle", true, {1,0,1}, 1))
    wall:attachComponents(Body(world, 0, Vector2(4)))

    return wall
end


---@param world unknown
---@param pos Vector2
---@param dir Vector2
---@param damage number
---@param ignoreComponent string
---@return Entity
function Builder.bullet(world, pos, dir, damage, ignoreComponent)
    local bullet = Entity()
    bullet:attachComponents(Transform2d(pos, Vector2(8,8)))
    bullet:attachComponents(Body(world, 0))
    bullet:attachComponents(Bullet(dir, damage, ignoreComponent))

    return bullet
end


---@param world unknown
---@param pos Vector2
---@param player Entity
---@param camera Camera
---@return Entity
function Builder.parachuteEnemy(world, pos, player, camera)
    local enemy = Entity()
    local body = Body(world, 3, Vector2(4))

    enemy:attachComponents(Transform2d(pos, Vector2(32,32)))
    enemy:attachComponents(ShapeDraw("rectangle", true, {1,.4, 0}, 1))
    enemy:attachComponents(body)
    enemy:attachComponents(Damageable(30, 30, 0.5))
    enemy:attachComponents(Enemy(player, camera))
    enemy:attachComponents(CharacterBehavior(camera))

    body.pushable = false
    body.terminalVelocity = Vector2(80, 10)

    return enemy
end


---@param world unknown
---@param pos Vector2
---@param player Entity
---@param camera Camera
---@return Entity
function Builder.jetpackEnemy(world, pos, player, camera)
    local enemy = Entity()
    local body = Body(world, 3, Vector2(4))

    enemy:attachComponents(Transform2d(pos, Vector2(32,32)))
    enemy:attachComponents(ShapeDraw("rectangle", true, {1,.4, 0}, 1))
    enemy:attachComponents(body)
    enemy:attachComponents(Damageable(30, 30, 0.5))
    enemy:attachComponents(Enemy(player, camera))
    enemy:attachComponents(CharacterBehavior(camera))
    enemy:attachComponents(JetpackEnemy(player))

    body.pushable = false
    body.terminalVelocity = Vector2(80, 10)

    return enemy
end

return Builder