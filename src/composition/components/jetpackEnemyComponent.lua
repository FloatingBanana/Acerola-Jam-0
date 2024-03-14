local Component = require "engine.composition.component"
local Lume = require "engine.3rdparty.lume"
local Vector2   = require "engine.math.vector2"

local Pistol = require "guns.pistol"
local Shotgun = require "guns.shotgun"
local Machinegun = require "guns.machinegun"

---@class JetpackEnemyComponent: Component
---
---@field public gun BaseGun
---@field private _player Entity
---
---@overload fun(player: Entity): JetpackEnemyComponent
local JetpackEnemyComponent = Component:extend("JetpackEnemyComponent")

function JetpackEnemyComponent:new(player)
    self._player = player
    self.offset = Vector2(100, 0)
    self.speed = 500

    self:_randomizeOffset()
end


function JetpackEnemyComponent:_randomizeOffset()
    self.offset.x = (200 + math.random(0, 300)) * (math.random() <= 0.5 and 1 or -1)
    self.offset.y = math.random(-100, 100)
end


function JetpackEnemyComponent:update(dt)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]


    if damageable.health <= 0 then
        return
    end

    local playerTransform = self._player:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local target = playerTransform.rect.center + self.offset
    local dir = target - transform.rect.center
    local dist = dir.length

    body.velocity = dir:normalize() * math.min(self.speed, dist)
end

function JetpackEnemyComponent:onBodyCollision(col, moveOffset)
    if math.random() <= 1/3 and (col.item:getComponent("BulletComponent") or col.other:getComponent("BulletComponent")) then
        self:_randomizeOffset()
    end
end

return JetpackEnemyComponent