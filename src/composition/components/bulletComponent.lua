local Component = require "engine.composition.component"

local bulletFilter = function(item, other)
    if other:getComponent("BulletComponent") then
        return nil
    end
    return "touch"
end

---@class BulletComponent: Component
---
---@overload fun(dir, damage): BulletComponent
local BulletComponent = Component:extend("BulletComponent")

function BulletComponent:new(direction, damage)
    self.direction = direction
    self.damage = damage
    self.speed = 500
end

function BulletComponent:update(dt)
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]

    body.collisionFilter = bulletFilter
    body:move(self.direction * self.speed * dt)

    if #body.collisions > 0 then
        CompositionManager.removeEntity(self.entity)
    end
end

function BulletComponent:onBodyCollision(col, moveOffset)
    
end

return BulletComponent