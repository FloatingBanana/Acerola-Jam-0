local Component = require "engine.composition.component"
local Vector2   = require "engine.math.vector2"
local Sprite    = require "engine.2D.sprite"

local bulletSprite = Sprite(love.graphics.newImage("assets/images/bullet.png"), nil, nil, 0, Vector2(.9, .5))

local bulletShader = love.graphics.newShader [[
vec4 effect(vec4 color, sampler2D tex, vec2 texcoords, vec2 screencoords) {
    return Texel(tex, texcoords) * 3.0; //+ vec4(1,1,1,0);
}
]]


local ignoreComponent = nil
local bulletFilter = function(item, other)
    if other:getComponent("BulletComponent") or (ignoreComponent and other:getComponent(ignoreComponent)) then
        return nil
    end
    return "cross"
end

---@class BulletComponent: Component
---
---@field public direction Vector2
---@field public damage number
---@field public speed number
---@field public ignoreComponent string
---
---@field private _destroyCounter number
---
---@overload fun(dir: Vector2, damage: number, ignoreComponent: string): BulletComponent
local BulletComponent = Component:extend("BulletComponent")

function BulletComponent:new(direction, damage, ignoreComponent)
    self.direction = direction
    self.damage = damage
    self.speed = 1000
    self.ignoreComponent = ignoreComponent

    self._destroyCounter = 3
end

function BulletComponent:draw()
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]

    bulletSprite.rotation = self.direction.angle
    bulletSprite:draw(transform.position, bulletShader)
end

function BulletComponent:update(dt)
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]

    ignoreComponent = self.ignoreComponent
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