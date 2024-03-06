local Component = require "engine.composition.component"

local bulletFilter = function(item, other)
    if other:getComponent("BulletComponent") then
        return nil
    end
    return "cross"
end

---@class BulletComponent: Component
---
---@overload fun(dir, damage): BulletComponent
local BulletComponent = Component:extend("BulletComponent")

function BulletComponent:new(direction, damage)
    self.direction = direction
    self.damage = damage
    self.speed = 500

    self._destroyCounter = 3
end

function BulletComponent:update(dt)
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]

    body.collisionFilter = bulletFilter
    body:move(self.direction * self.speed * dt)

    self._destroyCounter = self._destroyCounter - dt

    if self._destroyCounter <= 0 then
        CompositionManager.removeEntity(self.entity)
    end
end

function BulletComponent:onBodyCollision(col, moveOffset)
    local otherDamageable = col.other:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    if otherDamageable then
        otherDamageable:takeDamage(self.damage)
    end

    self._destroyCounter = 0
end

return BulletComponent