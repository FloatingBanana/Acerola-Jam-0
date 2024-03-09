local BaseGun = require "guns.baseGun"


---@class Pistol: BaseGun
---
---@overload fun(): Pistol
local Pistol = BaseGun:extend("Pistol")

function Pistol:new()
    BaseGun.new(self, 6, 250, math.rad(0), .2, .4)
end

function Pistol:shoot(world, pos, dir, ignoreComponent)
    BaseGun.shoot(self, world, pos, dir, ignoreComponent)

    CompositionManager.addEntity(EntityBuilder.bullet(world, pos, self:applySpread(dir), self.damage, ignoreComponent))
end

return Pistol