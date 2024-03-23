local Component = require "engine.composition.component"
local Vector2   = require "engine.math.vector2"
local Utils     = require "engine.misc.utils"

local bloodParticleImage = Utils.newColorImage(Vector2(1), {1,1,1,1})

local function collisionFilter(item, other)
    if other:getComponent("BulletComponent") then
        return "cross"
    end

    return "cross"
end

---@class CharacterBehaviorComponent: Component
---
---@field public camera Camera
---
---@overload fun(camera: Camera): CharacterBehaviorComponent
local CharacterBehaviorComponent = Component:extend("CharacterBehaviorComponent")

function CharacterBehaviorComponent:new(camera)
    self.camera = camera

    self.bloodParticles = love.graphics.newParticleSystem(bloodParticleImage)
    self.bloodParticles:setColors(1,0,0,1)
    self.bloodParticles:setParticleLifetime(0.3, 0.6)
    self.bloodParticles:setSpeed(300, 600)
    self.bloodParticles:setSpread(math.rad(50))
    self.bloodParticles:setSizes(5, 3, 0)
end


function CharacterBehaviorComponent:draw()
    love.graphics.draw(self.bloodParticles)
end


function CharacterBehaviorComponent:update(dt)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    local bounds = self.camera:getBounds()
    if transform.position.y > bounds.bottomRight.y + 100 then
        damageable:takeDamage(self.entity, math.huge, true)
    end

    if transform.rect.topLeft.x < bounds.topLeft.x then
        transform.position.x = bounds.topLeft.x
        body.velocity.x = 300
    end
    if transform.rect.bottomRight.x > bounds.bottomRight.x then
        transform.position.x = bounds.bottomRight.x - transform.size.x
        body.velocity.x = -300
    end

    self.bloodParticles:update(dt)


    body.collisionFilter = collisionFilter
end

function CharacterBehaviorComponent:onBodyCollision(col, other, moveOffset)
    
end


function CharacterBehaviorComponent:onDamageTaken(entity, damage, justDied)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    local bullet = entity:getComponent("BulletComponent") --[[@as BulletComponent]]
    local bulletTransform = entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]

    if bullet then
        local impulse = bullet.direction * bullet.speed * 0.2
        local touch = bulletTransform.position:clone():clamp(transform.rect.topLeft, transform.rect.bottomRight)

        body.velocity:add(impulse)

        self.bloodParticles:setPosition(touch.x, touch.y)
        self.bloodParticles:setDirection(bullet.direction.angle)
        self.bloodParticles:emit(40)
    end
end

return CharacterBehaviorComponent