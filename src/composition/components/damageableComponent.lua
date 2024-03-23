local Component = require "engine.composition.component"
local Vector2   = require "engine.math.vector2"
local Utils     = require "engine.misc.utils"

---@class DamageableComponent: Component
---
---@field public health number
---@field public maxHealth number
---@field public maxCooldown number
---@field public cooldown number
---
---@overload fun(health: number, maxHealth: number, cooldown: number): DamageableComponent
local DamageableComponent = Component:extend("DamageableComponent")

function DamageableComponent:new(health, maxHealth, cooldown)
    self.health = health
    self.maxHealth = maxHealth
    self.maxCooldown = cooldown
    self.cooldown = 0
end

function DamageableComponent:update(dt)
    self.cooldown = math.max(self.cooldown - dt, 0)
end


---@param damage number
---@param ignoreCooldown boolean?
---@return boolean
function DamageableComponent:takeDamage(entity, damage, ignoreCooldown)
    if self.health > 0 and (self.cooldown <= 0 or ignoreCooldown) then
        local justDied = (self.health <= damage)

        self.health = math.max(self.health - damage, 0)
        self.cooldown = self.maxCooldown
        self.entity:broadcastToComponents("onDamageTaken", entity, damage, justDied)

        return true
    end
    return false
end


---@param amount number
function DamageableComponent:heal(amount)
    self.health = math.min(self.health + amount, self.maxHealth)
end

return DamageableComponent