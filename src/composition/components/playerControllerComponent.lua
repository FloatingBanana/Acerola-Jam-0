local InputHelper = require "engine.misc.inputHelper"
local Component = require "engine.composition.component"
local Vector2   = require "engine.math.vector2"

local shotgun = {impulse = 400, maxCooldown = 0.4, cooldown = 0}
local handgun = {impulse = 400, maxCooldown = 0.1, cooldown = 0}

---@class PlayerControllerComponent: Component
---
---@overload fun(speed: number): PlayerControllerComponent
local PlayerController = Component:extend("PlayerControllerComponent")

function PlayerController:new()
    self.main = handgun
    self.secondary = shotgun
end


function PlayerController:update(dt)
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]

    self.main.cooldown = self.main.cooldown - dt
    self.secondary.cooldown = self.secondary.cooldown - dt
end

function PlayerController:onBodyCollision(col, moveOffset)
    
end

function PlayerController:mousepressed(x, y, button)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]

    local direction = (Vector2(x, y) - transform.position):normalize()
    local gun = nil

    if button == 1 then
        gun = self.main
        direction:negate()
    elseif button == 2 then
        gun = self.secondary
    end

    if gun and gun.cooldown <= 0 then
        gun.cooldown = gun.maxCooldown
        body.velocity = body.velocity * 0.5 + direction * gun.impulse
    end
end

return PlayerController