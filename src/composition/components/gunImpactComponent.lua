local Component = require "engine.composition.component"
local Sprite = require "engine.2D.sprite"
local Vector2 = require "engine.math.vector2"
local Rect = require "engine.math.rect"

local impactSprite = Sprite(love.graphics.newImage("assets/images/shootimpact.png"), nil, Vector2(3,1), nil, Vector2(0,0.5), Rect(Vector2(0,0), Vector2(32,32)))


---@class GunImpactComponent: Component
---
---@overload fun(): GunImpactComponent
local GunImpactComponent = Component:extend("GunImpactComponent")

function GunImpactComponent:new()
    self.animTimer = 0
end

function GunImpactComponent:draw()
    local transform = self.entity:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]

    impactSprite.color[4] = 1.2 - self.animTimer / 7
    impactSprite.rotation = transform.direction
    impactSprite.renderArea.position.x = math.floor(self.animTimer) * 32

    impactSprite:draw(transform.position)
end

function GunImpactComponent:update(dt)
    self.animTimer = self.animTimer + 40 * dt

    if self.animTimer >= 7 then
        CompositionManager.removeEntity(self.entity)
    end
end

return GunImpactComponent