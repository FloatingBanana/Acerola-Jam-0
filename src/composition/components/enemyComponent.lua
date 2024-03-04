local InputHelper = require "engine.misc.inputHelper"
local Component = require "engine.composition.component"
local Vector2   = require "engine.math.vector2"

local Pistol = require "guns.pistol"
local Shotgun = require "guns.shotgun"
local Machinegun = require "guns.machinegun"

---@class EnemyComponent: Component
---
---@overload fun(): EnemyComponent
local EnemyComponent = Component:extend("EnemyComponent")

function EnemyComponent:new()
    self.main = Pistol()
    self.secondary = Shotgun()
end


function EnemyComponent:update(dt)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    if damageable.health <= 0 then
        CompositionManager.removeEntity(self.entity)
    end

    self.main:update(dt)
    self.secondary:update(dt)
end

return EnemyComponent