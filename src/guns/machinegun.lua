local BaseGun = require "guns.baseGun"
local Audio = require "engine.audio.audio"

local machinegunSound = Audio("assets/sounds/pistol_shoot.wav", "static")
machinegunSound.volume = 0.2
MainAudioGroup:add(machinegunSound)

---@class Machinegun: BaseGun
---
---@overload fun(): Machinegun
local Machinegun = BaseGun:extend("Machinegun")

function Machinegun:new()
    BaseGun.new(self, 2, 100, math.rad(5), .2, .1, machinegunSound)
end

function Machinegun:shoot(world, pos, dir, ignoreComponent)
    BaseGun.shoot(self, world, pos, dir, ignoreComponent)

    CompositionManager.addEntity(EntityBuilder.bullet(world, pos, self:applySpread(dir), self.damage, ignoreComponent))
end

return Machinegun