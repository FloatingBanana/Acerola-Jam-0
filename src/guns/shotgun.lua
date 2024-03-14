local BaseGun = require "guns.baseGun"
local Audio = require "engine.audio.audio"

local shotgunShoot = Audio("assets/sounds/shotgun_shoot.wav", "static")
shotgunShoot.volume = 0.2
MainAudioGroup:add(shotgunShoot)

---@class Shotgun: BaseGun
---
---@overload fun(): Shotgun
local Shotgun = BaseGun:extend("Shotgun")

function Shotgun:new()
    BaseGun.new(self, 10, 450, math.rad(5), .5, .9, shotgunShoot)
end

function Shotgun:shoot(world, pos, dir, ignoreComponent)
    BaseGun.shoot(self, world, pos, dir, ignoreComponent)

    CompositionManager.addEntity(EntityBuilder.bullet(world, pos:clone(), self:applySpread(dir:clone()), self.damage, ignoreComponent))
    CompositionManager.addEntity(EntityBuilder.bullet(world, pos:clone(), self:applySpread(dir:clone()):rotateBy(math.rad(-10)), self.damage, ignoreComponent))
    CompositionManager.addEntity(EntityBuilder.bullet(world, pos:clone(), self:applySpread(dir:clone()):rotateBy(math.rad(10)), self.damage, ignoreComponent))
end

return Shotgun