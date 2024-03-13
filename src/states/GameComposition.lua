local Game = {}

-- Engine stuff
local Bump       = require "libs.bump"
local Camera     = require "engine.misc.camera"
local Timer      = require "engine.misc.timer"
local Utils      = require "engine.misc.utils"
local Vector2    = require "engine.math.vector2"
local Easing     = require "engine.math.easing"
local Rect       = require "engine.math.rect"
local AudioGroup = require "engine.audio.audioGroup"
local Sprite     = require "engine.2D.sprite"
local Lume       = require "engine.3rdparty.lume"


-- Posprocessing effects
local HDR = require("engine.postProcessing.hdr")(SCREENSIZE, 1)
local Bloom = require("engine.postProcessing.bloom")(SCREENSIZE, 3, 1)
local ChromaticAberration = require("engine.postProcessing.chromaticAberration")(SCREENSIZE, 1)


-- Global stuff
MainAudioGroup = AudioGroup()
CompositionManager = require "engine.composition.compositionManager"
EntityBuilder = require "composition.entityBuilder"

---@class GameData
GameData = {
    maxHeight = 0,
    enemySpawn = -500,

    timeSpeed = 1,
    targetTimeSpeed = 1,

    starting = false,
    started = false,

    trueDeltaTime = 0
}


-- Misc
local screenCanvas = love.graphics.newCanvas(WIDTH, HEIGHT, {format = "rgba16f"})
local world = Bump.newWorld(32)
local camera = Camera(Vector2(WIDTH/2, 0), 1)
local player = nil ---@type Entity
local menuFadeOut = 0


-- Sprites
local WallSprite = Sprite(love.graphics.newImage("assets/images/walls.png"), nil, nil, nil, nil, Rect(Vector2(), SCREENSIZE))
WallSprite.texture:setWrap("repeat")

local Background1Sprite = Sprite(love.graphics.newImage("assets/images/back_1.png"), nil, nil, nil, Vector2(0, 1))
local MenuNameSprite = Sprite(love.graphics.newImage("assets/images/menu_name.png"))

local skyGradient = Utils.newGradient({.5, .5, 1}, {.5, .5, 1}, {.3, .3, .8})
skyGradient:setFilter("linear", "linear")


local startTimer = Timer(0, 2, false)
startTimer.onEndedEvent:addCallback(function()
    GameData.started = true
    GameData.starting = false

    player = EntityBuilder.player(world, Vector2(WIDTH / 2, HEIGHT - 300), camera)
    CompositionManager.addEntity(player)

    ;(player:getComponent("BodyComponent") --[[@as BodyComponent]]).velocity.y = -700
end)


function Game:enter()
    CompositionManager.clear()

    GameData.maxHeight = 0
    GameData.enemySpawn = -500
    GameData.timeSpeed = 1
    GameData.targetTimeSpeed = 1
    GameData.started = false
    GameData.starting = false

    menuFadeOut = 0

    camera.actualPosition.y = 0
    camera:setInterpolation(Easing.cubic, 30)

    startTimer:restart()
end

function Game:draw()
    love.graphics.setCanvas(screenCanvas)
        lg.clear(.5, .5, 1)

        love.graphics.draw(skyGradient, 0, 0, 0, WIDTH, HEIGHT/3)

        Background1Sprite:draw(Vector2(0, HEIGHT - GameData.maxHeight*0.1))

        WallSprite.renderArea.topLeft.y = GameData.maxHeight
        WallSprite:draw(Vector2())

        camera:attach()

        CompositionManager.broadcastToAllComponents("draw")

        camera:detach()

        MenuNameSprite.color[4] = 1 - menuFadeOut
        MenuNameSprite:draw(Vector2())
    love.graphics.setCanvas()


    -- Post processing
    local result = screenCanvas
    result = Bloom:onPostRender(nil, result)
    result = HDR:onPostRender(nil, screenCanvas)
    result = ChromaticAberration:onPostRender(nil, result)

    love.graphics.draw(result)

    CompositionManager.broadcastToAllComponents("uiDraw")

    Utils.setFont(15)
    love.graphics.print(("Height: %d"):format(-GameData.maxHeight), 0, 40)
    love.graphics.print(GameData.timeSpeed, 0, 80)
end

function Game:update(dt)
    dt = math.min(love.timer.getAverageDelta(), 1)
    GameData.trueDeltaTime = dt


    -- Update stuff
    CompositionManager.broadcastToAllComponents("update", dt * GameData.timeSpeed)
    camera:update(math.min(dt, 1))
    startTimer:update(dt)

    menuFadeOut = math.min(menuFadeOut + (GameData.starting and dt or 0), 1)



    if GameData.started then
        local bounds = camera:getBounds()
        local playerTransform = player:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
        local playerDamageable = player:getComponent("DamageableComponent") --[[@as DamageableComponent]]

        GameData.maxHeight = math.min(GameData.maxHeight, playerTransform.position.y + HEIGHT/4)
        camera.position.y = GameData.maxHeight

        if playerDamageable.health <= 0 then
            Game:enter()
        end


        -- Spawn enemies
        if GameData.maxHeight < GameData.enemySpawn then
            for i=1, math.random(1, 3) do
                local enemyPos = Vector2(math.random(0, WIDTH-32), bounds.topLeft.y - 32)

                if math.random() <= 0.5 then
                    CompositionManager.addEntity(EntityBuilder.parachuteEnemy(world, enemyPos, player, camera))
                else
                    CompositionManager.addEntity(EntityBuilder.jetpackEnemy(world, enemyPos, player, camera))
                end
            end

            GameData.enemySpawn = GameData.enemySpawn - 1000
        end
    end


    -- Time slow
    GameData.timeSpeed = Lume.lerp(GameData.timeSpeed, GameData.targetTimeSpeed, Easing.quadratic(dt*10))
    ChromaticAberration:setOffset((1 - GameData.timeSpeed) * 3)
    MainAudioGroup.pitch = GameData.timeSpeed

    -- Reset time speed
    GameData.targetTimeSpeed = 1
end

function Game:keypressed(key)
    CompositionManager.broadcastToAllComponents("keypressed", key)

    if not GameData.started then
        startTimer:play()
        GameData.starting = true
    end
end

function Game:mousepressed(x, y, button)
    CompositionManager.broadcastToAllComponents("mousepressed", x, y, button)

    if not GameData.started then
        startTimer:play()
        GameData.starting = true
    end
end

function Game:wheelmoved(x, y)
    CompositionManager.broadcastToAllComponents("wheelmoved", x, y)
end

return Game