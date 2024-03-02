local BaseGun = require "guns.baseGun"


---@class Pistol: BaseGun
---
---@overload fun(): Pistol
local Pistol = BaseGun:extend("Pistol")

function Pistol:new()
    BaseGun.new(self, 10, 250, math.rad(0), .4)
end

function Pistol:shoot(world, pos, dir)
    BaseGun.shoot(self, world, pos, dir)

    CompositionManager.addEntity(EntityBuilder.bullet(world, pos, self:applySpread(dir), self.damage))
end

return Pistol