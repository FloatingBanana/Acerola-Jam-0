local Component = require "engine.composition.component"
local Vector2   = require "engine.math.vector2"
local Utils     = require "engine.misc.utils"
local Lume      = require "engine.3rdparty.lume"

local fireParticleImage = Utils.newColorImage(Vector2(1), {1,1,1,1})

local glowShader = love.graphics.newShader [[
vec4 effect(vec4 color, sampler2D tex, vec2 texcoords, vec2 screencoords) {
    return Texel(tex, texcoords) * color * 3.0;
}
]]

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


    self.fireParticles = love.graphics.newParticleSystem(fireParticleImage)
    self.fireParticles:setColors(1,.5,0,1,    1,.8,0,1)
    self.fireParticles:setParticleLifetime(0.2, 0.3)
    self.fireParticles:setSpeed(300, 400)
    self.fireParticles:setSpread(math.rad(20))
    self.fireParticles:setSizes(3, 0)
    self.fireParticles:setEmissionArea("uniform", 6, 2)
    self.fireParticles:setEmissionRate(70)
    self.fireParticles:setDirection(math.pi/2)
    self.fireParticles:start()


    self:_randomizeOffset()
end


function JetpackEnemyComponent:_randomizeOffset()
    self.offset.x = (200 + math.random(0, 300)) * (math.random() <= 0.5 and 1 or -1)
    self.offset.y = math.random(-100, 100)
end


function JetpackEnemyComponent:draw()
    love.graphics.setShader(glowShader)
    love.graphics.draw(self.fireParticles)
    love.graphics.setShader()
end


function JetpackEnemyComponent:update(dt)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]


    -- Jetpack particles
    local side = math.cos(transform.direction) > 0 and 1 or -1
    self.fireParticles:setPosition(transform.rect.center.x - (18 * side), transform.rect.center.y + 13)
    self.fireParticles:update(dt)


    if damageable.health <= 0 then
        self.fireParticles:stop()
        return
    end

    local playerTransform = self._player:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local target = playerTransform.rect.center + self.offset
    local dir = target - transform.rect.center
    local dist = dir.length

    body.velocity = dir:normalize() * math.min(self.speed, dist)
end

function JetpackEnemyComponent:onBodyCollision(col, other, moveOffset)
    if math.random() <= 1/3 and other:getComponent("BulletComponent") then
        self:_randomizeOffset()
    end
end

return JetpackEnemyComponent