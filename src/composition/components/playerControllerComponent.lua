local Sprite    = require "engine.2D.sprite"
local Component = require "engine.composition.component"
local Vector2   = require "engine.math.vector2"
local Rect      = require "engine.math.rect"
local Audio     = require "engine.audio.audio"
local Utils     = require "engine.misc.utils"

local Pistol = require "guns.pistol"
local Shotgun = require "guns.shotgun"
local Machinegun = require "guns.machinegun"


local swapWeaponAudio = Audio("assets/sounds/swap.wav", "static")
swapWeaponAudio.volume = 0.3
MainAudioGroup:add(swapWeaponAudio)


local hitAudio = Audio("assets/sounds/player_damage.wav", "static")
hitAudio.volume = 0.5
MainAudioGroup:add(hitAudio)


local bodySprite      = Sprite(love.graphics.newImage("assets/images/body.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5))
local faceSprite      = Sprite(love.graphics.newImage("assets/images/face.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5))
local tentaclesSprite = Sprite(love.graphics.newImage("assets/images/tentacles.png"), {1,1,1,1}, Vector2(.9), 0, Vector2(0.5), Rect(Vector2(), Vector2(160)))
local uiSprite        = Sprite(love.graphics.newImage("assets/images/game_ui.png"))
local panelSprite     = Sprite(love.graphics.newImage("assets/images/score_panel.png"), nil, nil, nil, Vector2(1, 0))

local gunSprites = {
    [Pistol.ClassName]  = Sprite(love.graphics.newImage("assets/images/player_pistol.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5)),
    [Shotgun.ClassName] = Sprite(love.graphics.newImage("assets/images/player_shotgun.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5)),
}

---@class PlayerControllerComponent: Component
---
---@field public camera Camera
---@field public main BaseGun
---@field public secondary BaseGun
---@field public dead boolean
---@field public timeSlow number
---@field public maxTimeSlow number
---@field private _tentacleAnim number
---@field private _swapCooldow number
---@field private _uiFade number
---
---@overload fun(camera: Camera): PlayerControllerComponent
local PlayerController = Component:extend("PlayerControllerComponent")

function PlayerController:new(camera)
    self.camera = camera
    self.main = Pistol()
    self.secondary = Shotgun()

    self.dead = false
    self.maxTimeSlow = 6
    self.timeSlow = 6
    self.timeSlowBlock = false

    self._tentacleAnim = 0
    self._swapCooldow = 0
    self._uiFade = 0
end


function PlayerController:_swapGun()
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]

    if self._swapCooldow <= 0 then
        self.main, self.secondary = self.secondary, self.main
        transform.direction =  transform.direction + math.pi
        self._swapCooldow = 0.5

        swapWeaponAudio:play()
    end
end


function PlayerController:draw()
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    local velocityOffset = body.velocity / body.terminalVelocity
    local tentacles = 10


    local flash = damageable.cooldown > 0 and math.cos(damageable.cooldown * 25) or 1
    tentaclesSprite.color[4] = flash
    gunSprites.Pistol.color[4] = flash
    gunSprites.Shotgun.color[4] = flash
    bodySprite.color[4] = flash
    faceSprite.color[4] = flash

    for i = 1, tentacles do
        local angle = math.pi*2 * (i / tentacles)
        local frame = math.floor(self._tentacleAnim + i) % 6

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


function PlayerController:uiDraw()
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    lg.setColor(.8,.2,.2, self._uiFade)
    love.graphics.rectangle("fill", 19, 19, 200 * (damageable.health / damageable.maxHealth), 11)

    if self.timeSlowBlock then
        lg.setColor(.2,.8,.8, self._uiFade)
    else
        lg.setColor(.2,.8,.2, self._uiFade)
    end
    love.graphics.rectangle("fill", 19, 42, 200 * (self.timeSlow / self.maxTimeSlow), 6)


    uiSprite.color[4] = self._uiFade
    uiSprite:draw(Vector2())

    panelSprite.color[4] = self._uiFade
    panelSprite:draw(Vector2(WIDTH, 0))

    Utils.setFont("assets/fonts/melted_monster.ttf", 20)
    love.graphics.setColor(0.552, 0.552, 0.674)
    love.graphics.print(("Height: %d m"):format(-GameData.height), WIDTH - 280, 40)
    love.graphics.print(("Record: %d m"):format(-GameData.maxHeight), WIDTH - 280, 90)

    lg.setColor(1,1,1)
end


function PlayerController:update(dt)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    if damageable.health <= 0 then
        return
    end

    self.main:update(dt)
    self.secondary:update(dt)

    self._tentacleAnim = (self._tentacleAnim + 15 * dt) % 6
    self._swapCooldow = self._swapCooldow - dt
    self._uiFade = self._uiFade + dt


    -- Time slow
    if love.keyboard.isDown("lctrl") and not self.timeSlowBlock then
        self.timeSlow = math.max(self.timeSlow - GameData.trueDeltaTime, 0)
        self.timeSlowBlock = (self.timeSlow == 0)

        GameData.targetTimeSpeed = 0.35
    else
        self.timeSlow = math.min(self.timeSlow + 0.6 * GameData.trueDeltaTime, self.maxTimeSlow)

        if self.timeSlow > self.maxTimeSlow/2 then
            self.timeSlowBlock = false
        end
    end


    local target = self.camera:toWorld(Vector2(love.mouse.getPosition()))
    local mouseDir = (target - transform.rect.center):normalize()
    local direction = Vector2.Lerp(Vector2.CreateAngled(transform.direction, 1), mouseDir, 15*dt)
    local gun = nil

    transform.direction = direction.angle

    -- Fire gun
    if (love.mouse.isDown(1) or love.keyboard.isDown("z")) and self.main.cooldown <= 0 then
        gun = self.main
        direction:negate()
    elseif (love.mouse.isDown(2) or love.keyboard.isDown("x")) and self.secondary.cooldown <= 0 then
        gun = self.secondary
    end

    if gun and self._swapCooldow <= 0 then
        local bulletDir = -direction
        local pos = transform.rect.center + bulletDir * 32

        gun:shoot(body.world, pos, bulletDir, "PlayerControllerComponent")
        body.velocity = gun:applyRecoil(body.velocity, direction)
    end
end


function PlayerController:onDamageTaken(damage, health)
    if not self.dead then
        self.camera:shake(.5, 5, .1)
        hitAudio:play()

        self.dead = (health <= 0)
    end
end


function PlayerController:keypressed(k)
    if k == "a" then
        self:_swapGun()
    end
end

function PlayerController:wheelmoved(x, y)
    self:_swapGun()
end

return PlayerController