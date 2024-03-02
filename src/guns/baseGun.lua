local Object = require "engine.3rdparty.classic.classic"
local Timer = require "engine.misc.timer"


---@class BaseGun: Object
---
---@field public damage number
---@field public impulse number
---@field public maxCooldown number
---@field public cooldown number
---
---@overload fun(damage: number, impulse: number, maxCooldown: number): BaseGun
local BaseGun = Object:extend("BaseGun")

function BaseGun:new(damage, impulse, maxCooldown)
    self.damage = damage
    self.impulse = impulse

    self.maxCooldown = maxCooldown
    self.cooldown = 0
end

function BaseGun:update(dt)
    self.cooldown = math.max(self.cooldown - dt, 0)
end

function BaseGun:shoot(world, pos, dir)
    self.cooldown = self.maxCooldown
end

return BaseGun