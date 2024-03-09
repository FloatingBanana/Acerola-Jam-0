local BaseGun = require "guns.baseGun"


---@class Shotgun: BaseGun
---
---@overload fun(): Shotgun
local Shotgun = BaseGun:extend("Shotgun")

function Shotgun:new()
    BaseGun.new(self, 10, 450, math.rad(8), .5, .9)
end

function Shotgun:shoot(world, pos, dir, ignoreComponent)
    BaseGun.shoot(self, world, pos, dir, ignoreComponent)

    CompositionManager.addEntity(EntityBuilder.bullet(world, pos:clone(), self:applySpread(dir:clone()), self.damage, ignoreComponent))
    CompositionManager.addEntity(EntityBuilder.bullet(world, pos:clone(), self:applySpread(dir:clone()):rotateBy(math.rad(-10)), self.damage, ignoreComponent))
    CompositionManager.addEntity(EntityBuilder.bullet(world, pos:clone(), self:applySpread(dir:clone()):rotateBy(math.rad(10)), self.damage, ignoreComponent))
end

return Shotgun