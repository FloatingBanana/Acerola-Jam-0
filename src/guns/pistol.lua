local BaseGun = require "guns.baseGun"
local Audio = require "engine.audio.audio"

local pistolSound = Audio("assets/sounds/pistol_shoot.wav", "static")
pistolSound.volume = 0.2
MainAudioGroup:add(pistolSound)

---@class Pistol: BaseGun
---
---@overload fun(): Pistol
local Pistol = BaseGun:extend("Pistol")

function Pistol:new()
    BaseGun.new(self, 6, 250, math.rad(0), .2, .4, pistolSound)
end

function Pistol:shoot(world, pos, dir, ignoreComponent)
    BaseGun.shoot(self, world, pos, dir, ignoreComponent)

    CompositionManager.addEntity(EntityBuilder.bullet(world, pos, self:applySpread(dir), self.damage, ignoreComponent))
end

return Pistol