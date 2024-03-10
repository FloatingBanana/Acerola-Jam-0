local Sprite    = require "engine.2D.sprite"
local Component = require "engine.composition.component"
local Vector2   = require "engine.math.vector2"
local Rect      = require "engine.math.rect"

local Pistol = require "guns.pistol"
local Shotgun = require "guns.shotgun"
local Machinegun = require "guns.machinegun"


local bodySprite      = Sprite(love.graphics.newImage("assets/images/body.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5))
local faceSprite      = Sprite(love.graphics.newImage("assets/images/face.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5))
local tentaclesSprite = Sprite(love.graphics.newImage("assets/images/tentacles.png"), {1,1,1,1}, Vector2(.9), 0, Vector2(0.5), Rect(Vector2(), Vector2(160)))

local gunSprites = {
    [Pistol.ClassName]  = Sprite(love.graphics.newImage("assets/images/player_pistol.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5)),
    [Shotgun.ClassName] = Sprite(love.graphics.newImage("assets/images/player_shotgun.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5)),
}


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


function PlayerController:draw()
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]

    local velocityOffset = body.velocity / body.terminalVelocity

    local tentacles = 10
    for i = 1, tentacles do
        local angle = math.pi*2 * (i / tentacles)
        local frame = math.floor(love.timer.getTime() * 15 + i) % 6

        tentaclesSprite.renderArea.position.x = frame * 160
        tentaclesSprite.rotation = angle

        tentaclesSprite:draw(transform.rect.center)
    end

    gunSprites[self.main.ClassName].rotation = transform.direction
    gunSprites[self.main.ClassName]:draw(transform.rect.center)

    gunSprites[self.secondary.ClassName].rotation = transform.direction + math.pi
    gunSprites[self.secondary.ClassName]:draw(transform.rect.center)

    bodySprite:draw(transform.rect.center)
    faceSprite:draw(transform.rect.center + velocityOffset * 10)
end


function PlayerController:update(dt)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    self.main:update(dt)
    self.secondary:update(dt)


    -- Fire gun
    local target = self.camera:toWorld(Vector2(love.mouse.getPosition()))
    local direction = (target - transform.rect.center):normalize()
    local gun = nil

    transform.direction = direction.angle

    if love.mouse.isDown(1) and self.main.cooldown <= 0 then
        gun = self.main
        direction:negate()
    elseif love.mouse.isDown(2) and self.secondary.cooldown <= 0 then
        gun = self.secondary
    end

    if gun then
        local bulletDir = -direction
        local pos = transform.rect.center + bulletDir * 32

        gun:shoot(body.world, pos, bulletDir, "PlayerControllerComponent")
        body.velocity = gun:applyRecoil(body.velocity, direction)
    end
end



function PlayerController:keypressed(k)
    if k == "a" then
        self.main, self.secondary = self.secondary, self.main
    end
end

return PlayerController