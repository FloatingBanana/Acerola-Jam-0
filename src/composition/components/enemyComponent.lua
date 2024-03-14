local Component = require "engine.composition.component"
local Timer     = require "engine.misc.timer"
local Vector2   = require "engine.math.vector2"
local Sprite    = require "engine.2D.sprite"
local Audio     = require "engine.audio.audio"
local Utils     = require "engine.misc.utils"


local BARSIZE = 3


local Pistol = require "guns.pistol"
local Shotgun = require "guns.shotgun"
local Machinegun = require "guns.machinegun"

local hitAudio = Audio("assets/sounds/soldier_damage.wav", "static")
hitAudio.volume = 0.3
MainAudioGroup:add(hitAudio)

local deathAudio = Audio("assets/sounds/soldier_death.wav", "static")
MainAudioGroup:add(deathAudio)


local jetpackSprite = Sprite(love.graphics.newImage("assets/images/soldier_jetpack.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5))
local parachuteSprite = Sprite(love.graphics.newImage("assets/images/soldier_parachute.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5))
local shotgunSprite = Sprite(love.graphics.newImage("assets/images/soldier_shotgun.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5))
local pistolSprite = Sprite(love.graphics.newImage("assets/images/soldier_pistol.png"), {1,1,1,1}, Vector2(1), 0, Vector2(0.5))


---@class EnemyComponent: Component
---
---@field public gun BaseGun
---@field public dead boolean
---@field private _player Entity
---@field private _camera Camera
---
---@overload fun(player: Entity, camera: Camera): EnemyComponent
local EnemyComponent = Component:extend("EnemyComponent")

function EnemyComponent:new(player, camera)
    if math.random() <= 1/4 then
        self.gun = Shotgun()
    else
        self.gun = Pistol()
    end

    self.dead = false

    local waitTime = math.random(2, 5)
    self.waitTimer = Timer(math.random() * waitTime, waitTime, true):play()
    self.shootTimer = Timer(0, 0.3 + math.random() * 0.5, false)

    self._player = player
    self._camera = camera
end


function EnemyComponent:draw()
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    local left = (math.cos(transform.direction) > 0)
    local dir = (left and 1 or -1)
    local bodySprite = (self.entity:getComponent("JetpackEnemyComponent") and jetpackSprite or parachuteSprite)


    local color = damageable.health > 0 and {1,1,1,1} or {.2,.2,.2,1}
    bodySprite.color = color
    shotgunSprite.color = color
    pistolSprite.color = color

    bodySprite.size.x = dir
    bodySprite:draw(transform.rect.center)


    if self.gun.ClassName == "Pistol" then
        pistolSprite.rotation = transform.direction
        pistolSprite.size.y = dir

        pistolSprite:draw(transform.rect.center)
    elseif self.gun.ClassName == "Shotgun" then
        shotgunSprite.rotation = transform.direction
        shotgunSprite.size.y = dir

        shotgunSprite:draw(transform.rect.center)
    end


    local pos = Vector2(transform.rect.center.x - damageable.maxHealth * BARSIZE / 2, transform.rect.bottomRight.y + 30)

    love.graphics.setLineWidth(2)

    love.graphics.setColor(1,.5,.5)
    love.graphics.rectangle("fill", pos.x, pos.y, damageable.health * BARSIZE, 5)

    love.graphics.setColor(1,1,1)
    love.graphics.rectangle("line", pos.x, pos.y, damageable.maxHealth * BARSIZE, 5)

    love.graphics.setLineWidth(1)
    Utils.setFont(10)
    love.graphics.print(damageable.health .. "/" .. damageable.maxHealth, pos.x, pos.y - 15)
end


function EnemyComponent:update(dt)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    local playerTransform = self._player:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local playerDamageable = self._player:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    if damageable.health <= 0 then
        body.velocity.y = 500
        body.terminalVelocity = Vector2(20, 500)
        return
    end

    if transform.rect.topLeft.y > self._camera:getBounds().bottomRight.y+64 then
        CompositionManager.removeEntity(self.entity)
    end

    if self.waitTimer:update(dt).justEnded then
        self.shootTimer:play()
    end

    local bounds = self._camera:getBounds()
    local inBounds = (transform.rect.topLeft > bounds.topLeft and transform.rect.bottomRight < bounds.bottomRight)

    local dir = (playerTransform.rect.center - transform.rect.center):normalize()
    transform.direction = dir.angle

    if self.shootTimer:update(dt).running and playerDamageable.health > 0 and inBounds and self.gun.cooldown <= 0 then
        self.gun:shoot(body.world, transform.rect.center + dir * 32, dir, "EnemyComponent")
        body.velocity = body.velocity * 0.75 + self.gun:applyRecoil(body.velocity, -dir) * 0.25
    end

    self.gun:update(dt)
end

function EnemyComponent:onDamageTaken(damage, health)
    if not self.dead then
        hitAudio:play()

        if health <= 0 then
            deathAudio:play()
            self.dead = true
        end
    end
end

return EnemyComponent