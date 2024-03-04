local BaseGun = require "guns.baseGun"


---@class Machinegun: BaseGun
---
---@overload fun(): Machinegun
local Machinegun = BaseGun:extend("Machinegun")

function Machinegun:new()
    BaseGun.new(self, 2, 100, math.rad(5), .1)
end

function Machinegun:shoot(world, pos, dir)
    BaseGun.shoot(self, world, pos, dir)

    CompositionManager.addEntity(EntityBuilder.bullet(world, pos, self:applySpread(dir), self.damage))
end

return Machinegun