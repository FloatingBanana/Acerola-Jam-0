local Vector2 = require "engine.math.vector2"
local Component = require "engine.composition.component"

local abs = math.abs

---@alias BumpCollisionSolver
---| "slide"
---| "touch"
---| "bounce"
---| "cross"

---@alias BumpCollisionDescription {item: any, other: any, type: BumpCollisionDescription, overlaps: boolean, ti: number, move: Vector2, normal: Vector2, touch: Vector2, itemRect: table, otherRect: table}
---@alias BumpCollisionFilter fun(item: any, other: any): BumpCollisionSolver

---@class BodyComponent: Component
---
---@field public world table
---@field public mass number
---@field public velocity Vector2
---@field public friction Vector2
---@field public elasticity Vector2
---@field public terminalVelocity Vector2
---@field public pushable boolean
---@field public collisions BumpCollisionDescription[]
---@field public collisionFilter BumpCollisionFilter
---@field private _totalFric Vector2
---
---@overload fun(world: table, mass: number, friction: Vector2?, elasticity: Vector2?, collisionFilter: BumpCollisionFilter?): BodyComponent
local Body = Component:extend("BodyComponent")
Body.Gravity = Vector2(0, 200)

function Body:new(world, mass, friction, elasticity, collisionFilter)
    self.world = world
    self.mass = mass
    self.velocity = Vector2()
    self.friction = friction or Vector2()
    self.elasticity = elasticity or Vector2()
    self.terminalVelocity = Vector2(1500)

    self.pushable = true
    self.collisions = {}
    self.collisionFilter = collisionFilter

    self._totalFric = Vector2()
end


function Body:update(dt)
    if self.mass > 0 then
        self.velocity:add(Body.Gravity * (self.mass * dt))
        self:move(self.velocity * dt)

        self.velocity:subtract(self.velocity * self._totalFric * dt)
        self._totalFric:new(0,0)
    end

    self.velocity = Vector2.Min(self.velocity, self.terminalVelocity) -- TODO: Deaccelerate smoothly to terminal velocity
end


function Body:move(offset)
    local transform = self.entity:getComponent("Transform2dComponent")

    local target = transform.position + offset
    local goalx, goaly, cols, len = self.world:move(self.entity, target.x, target.y, self.collisionFilter)

    transform.position = Vector2(goalx, goaly)
    self.collisions = cols

    for i, col in ipairs(cols) do
        col.normal = Vector2(col.normal.x, col.normal.y)
        col.move = Vector2(col.move.x, col.move.y)
        col.touch = Vector2(col.touch.x, col.touch.y)

        self.entity:broadcastToComponents("onBodyCollision", col, offset)
        cols[i].other:broadcastToComponents("onBodyCollision", col, offset)
    end
end


function Body:onBodyCollision(col, moveOffset)
    local otherBody = col.other:getComponent("BodyComponent") --[[@as BodyComponent]]
    local absNormal = Vector2(abs(col.normal.y), abs(col.normal.x))

    if col.item == self.entity then
        -- Calculate friction
        local fric = (self.friction * otherBody.friction):multiply(absNormal)
        self._totalFric = Vector2.Max(fric, self._totalFric)

        -- Handle collisions against moving objects
        if col.normal.x ~= 0 and abs(otherBody.velocity.x) < abs(self.velocity.x) then
            self.velocity.x = otherBody.velocity.x
        end
        if col.normal.y ~= 0 and abs(otherBody.velocity.y) < abs(self.velocity.y) then
            self.velocity.y = otherBody.velocity.y
        end

        -- Elasticity calculation
        self.velocity = self.velocity + otherBody.elasticity * col.normal

        -- Push objects
        if otherBody.pushable and otherBody.mass > 0 then
            local push = moveOffset * (1 - col.ti) * math.min(self.mass / otherBody.mass, 1) * absNormal
            otherBody:move(push)
        end
    end
end


function Body:onAttach(entity)
    self:_addToWorld(entity)
end
function Body:onEntityAdded(entity)
    self:_addToWorld(entity)
end
function Body:onDetach(entity)
    self:_removeFromWorld(entity)
end
function Body:onEntityRemoved(entity)
    self:_removeFromWorld(entity)
end


---@private
function Body:_addToWorld(entity)
    local transform = entity:getComponent("Transform2dComponent")
    local pos = transform.position
    local size = transform.size

    if not self.world:hasItem(entity) then
        self.world:add(entity, pos.x, pos.y, size.x, size.y)
    end
end

---@private
function Body:_removeFromWorld(entity)
    if self.world:hasItem(entity) then
        self.world:remove(entity)
    end
end

return Body