local Object = require "engine.3rdparty.classic.classic"
local Timer = require "engine.misc.timer"


---@class BaseGun: Object
---
---@field public damage number
---@field public impulse number
---@field public maxCooldown number
---@field public spread number
---@field public cooldown number
---
---@overload fun(damage: number, impulse: number, spread: number, maxCooldown: number): BaseGun
local BaseGun = Object:extend("BaseGun")

function BaseGun:new(damage, impulse, spread, maxCooldown)
    self.damage = damage
    self.impulse = impulse
    self.spread = spread

    self.maxCooldown = maxCooldown
    self.cooldown = 0
end

function BaseGun:update(dt)
    self.cooldown = math.max(self.cooldown - dt, 0)
end

function BaseGun:applySpread(dir)
    return dir:rotateBy(math.random() * self.spread*2 - self.spread)
end

function BaseGun:shoot(world, pos, dir)
    self.cooldown = self.maxCooldown
end

return BaseGun