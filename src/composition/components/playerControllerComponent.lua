local InputHelper = require "engine.misc.inputHelper"
local Component = require "engine.composition.component"
local Vector2   = require "engine.math.vector2"

local Pistol = require "guns.pistol"
local Shotgun = require "guns.shotgun"
local Machinegun = require "guns.machinegun"

---@class PlayerControllerComponent: Component
---
---@field public camera Camera
---@field public main BaseGun
---@field public secondary BaseGun
---
---@overload fun(camera: Camera): PlayerControllerComponent
local PlayerController = Component:extend("PlayerControllerComponent")

function PlayerController:new(camera)
    self.camera = camera
    self.main = Pistol()
    self.secondary = Shotgun()
end


function PlayerController:update(dt)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]

    self.main:update(dt)
    self.secondary:update(dt)


    -- Fire gun
    local target = self.camera:toWorld(Vector2(love.mouse.getPosition()))
    local direction = (target - transform.rect.center):normalize()
    local gun = nil

    if love.mouse.isDown(1) and self.main.cooldown <= 0 then
        gun = self.main
        direction:negate()
    elseif love.mouse.isDown(2) and self.secondary.cooldown <= 0 then
        gun = self.secondary
    end

    if gun then
        local bulletDir = -direction
        local pos = transform.rect.center + bulletDir * 32

        gun:shoot(body.world, pos, bulletDir)
        body.velocity = body.velocity * 0.7 + direction * gun.impulse
    end
end

function PlayerController:keypressed(k)
    if k == "a" then
        self.main, self.secondary = self.secondary, self.main
    end
end

return PlayerController