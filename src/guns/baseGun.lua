local Object = require "engine.3rdparty.classic.classic"
local Timer = require "engine.misc.timer"
local Vector2 = require "engine.math.vector2"


---@class BaseGun: Object
---
---@field public damage number
---@field public impulse number
---@field public spread number
---@field public velocityCancel number
---@field public maxCooldown number
---@field public cooldown number
---@field public sound Audio
---
---@overload fun(damage: number, impulse: number, spread: number, velocityCancel: number, maxCooldown: number, sound: Audio): BaseGun
local BaseGun = Object:extend("BaseGun")

function BaseGun:new(damage, impulse, spread, velocityCancel, maxCooldown, sound)
    self.damage = damage
    self.impulse = impulse
    self.spread = spread
    self.velocityCancel = velocityCancel
    self.sound = sound

    self.maxCooldown = maxCooldown
    self.cooldown = 0
end

function BaseGun:update(dt)
    self.cooldown = math.max(self.cooldown - dt, 0)
end

function BaseGun:applySpread(dir)
    return dir:rotateBy(math.random() * self.spread*2 - self.spread)
end

function BaseGun:applyRecoil(currVelocity, dir)
    return currVelocity * (dir * (1-self.velocityCancel)):abs() + dir * self.impulse
end

function BaseGun:shoot(world, pos, dir, ignoreComponent)
    self.cooldown = self.maxCooldown
    self.sound:play()

    CompositionManager.addEntity(EntityBuilder.gunImpact(pos, dir.angle))
end

return BaseGun