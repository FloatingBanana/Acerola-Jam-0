local Component = require "engine.composition.component"
local Timer = require "engine.misc.timer"
local Vector2   = require "engine.math.vector2"

local Pistol = require "guns.pistol"
local Shotgun = require "guns.shotgun"
local Machinegun = require "guns.machinegun"

---@class EnemyComponent: Component
---
---@field public gun BaseGun
---@field private _player Entity
---@field private _camera Camera
---
---@overload fun(player: Entity, camera: Camera): EnemyComponent
local EnemyComponent = Component:extend("EnemyComponent")

function EnemyComponent:new(player, camera)
    self.gun = Pistol()

    self.waitTimer = Timer(0, 3, true):play()
    self.shootTimer = Timer(0, 0.5, false)

    self._player = player
    self._camera = camera
end


function EnemyComponent:update(dt)
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local body = self.entity:getComponent("BodyComponent") --[[@as BodyComponent]]
    local damageable = self.entity:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    local playerTransform = self._player:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
    local playerDamageable = self._player:getComponent("DamageableComponent") --[[@as DamageableComponent]]

    if damageable.health <= 0 then
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

return EnemyComponent