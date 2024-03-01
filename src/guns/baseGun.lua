local Object = require "engine.3rdparty.classic.classic"
local Timer = require "engine.misc.timer"


---@class BaseGun: Object
---
---@overload fun(): BaseGun
local BaseGun = Object:extend("BaseGun")

function BaseGun:new(damage, impulse, maxCooldown)
    self.damage = damage
    self.impulse = impulse

    self.cooldownTimer = Timer(0, maxCooldown, false)
end

function BaseGun:update(dt)
    self.cooldownTimer:update(dt)
end

function BaseGun:shoot(pos, dir)
    error("Not implemented")
end

return BaseGun