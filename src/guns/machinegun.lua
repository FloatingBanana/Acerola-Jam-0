local BaseGun = require "guns.baseGun"


---@class Machinegun: BaseGun
---
---@overload fun(): Machinegun
local Machinegun = BaseGun:extend("Machinegun")

function Machinegun:new()
    BaseGun.new(self, 2, 100, math.rad(5), .2, .1)
end

function Machinegun:shoot(world, pos, dir, ignoreComponent)
    BaseGun.shoot(self, world, pos, dir, ignoreComponent)

    CompositionManager.addEntity(EntityBuilder.bullet(world, pos, self:applySpread(dir), self.damage, ignoreComponent))
end

return Machinegun