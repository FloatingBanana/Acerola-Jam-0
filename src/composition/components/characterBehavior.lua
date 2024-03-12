local Component = require "engine.composition.component"
local Vector2   = require "engine.math.vector2"

local function collisionFilter(item, other)
    if other:getComponent("BulletComponent") then
        return "cross"
    end

    return "slide"
end

---@class CharacterBehaviorComponent: Component
---
---@field public camera Camera
---
---@overload fun(camera: Camera): CharacterBehaviorComponent
local CharacterBehaviorComponent = Component:extend("CharacterBehaviorComponent")

function CharacterBehaviorComponent:new(camera)
    self.camera = camera
end


function CharacterBehaviorComponent:update(dt)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    local bounds = self.camera:getBounds()
    if transform.position.y > bounds.bottomRight.y + 100 then
        damageable:takeDamage(math.huge, true)
    end

    if transform.rect.topLeft.x < bounds.topLeft.x then
        body.velocity.x = 300
    end
    if transform.rect.bottomRight.x > bounds.bottomRight.x then
        body.velocity.x = -300
    end


    body.collisionFilter = collisionFilter
end

function CharacterBehaviorComponent:onBodyCollision(col, moveOffset)
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local bullet = (col.item:getComponent("BulletComponent") or col.other:getComponent("BulletComponent")) --[[@as BulletComponent]]

    if bullet then
        local impulse = bullet.direction * bullet.speed * 0.2
        body.velocity:add(impulse)
    end
end


return CharacterBehaviorComponent