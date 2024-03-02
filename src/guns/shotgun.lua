local BaseGun = require "guns.baseGun"


---@class Shotgun: BaseGun
---
---@overload fun(): Shotgun
local Shotgun = BaseGun:extend("Shotgun")

function Shotgun:new()
    BaseGun.new(self, 10, 400, math.rad(8), .7)
end

function Shotgun:shoot(world, pos, dir)
    BaseGun.shoot(self, world, pos, dir)

    CompositionManager.addEntity(EntityBuilder.bullet(world, pos:clone(), self:applySpread(dir:clone()), self.damage))
    CompositionManager.addEntity(EntityBuilder.bullet(world, pos:clone(), self:applySpread(dir:clone()):rotateBy(math.rad(-10)), self.damage))
    CompositionManager.addEntity(EntityBuilder.bullet(world, pos:clone(), self:applySpread(dir:clone()):rotateBy(math.rad(10)), self.damage))
end

return Shotgun