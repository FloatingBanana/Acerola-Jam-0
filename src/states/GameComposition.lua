local Game = {}

-- Engine stuff
local Bump              = require "libs.bump"
local Camera            = require "engine.misc.camera"
local Timer             = require "engine.misc.timer"
local Utils             = require "engine.misc.utils"
local Vector2           = require "engine.math.vector2"
local Easing            = require "engine.math.easing"
local Rect              = require "engine.math.rect"
local AudioGroup        = require "engine.audio.audioGroup"
local Sprite            = require "engine.2D.sprite"
local Lume              = require "engine.3rdparty.lume"
local Audio             = require "engine.audio.audio"
local TransitionManager = require "engine.transitions.transitionManager"
local Fade              = require "engine.transitions.fade"

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
    height = 0,
    maxHeight = 0,
    enemySpawn = -600,

    timeSpeed = 1,
    targetTimeSpeed = 1,

    starting = false,
    started = false,
    gameOver = false,

    trueDeltaTime = 0
}


-- Misc
local screenCanvas = love.graphics.newCanvas(WIDTH, HEIGHT, {format = "rgba16f"})
local world = Bump.newWorld(32)
local camera = Camera(Vector2(WIDTH/2, 0), 1)
local player = nil ---@type Entity
local menuFadeOut = 0
local showControls = true

local music = Audio("assets/sounds/music.wav", "stream")
music.loop = true
music.multiSource = false
MainAudioGroup:add(music)


-- Sprites
local WallSprite = Sprite(love.graphics.newImage("assets/images/walls.png"), nil, nil, nil, nil, Rect(Vector2(), SCREENSIZE))
WallSprite.texture:setWrap("repeat")

local Background1Sprite = Sprite(love.graphics.newImage("assets/images/back_1.png"), nil, nil, nil, Vector2(0, 1))
local MenuNameSprite = Sprite(love.graphics.newImage("assets/images/menu_name.png"))
local ControlsSprite = Sprite(love.graphics.newImage("assets/images/controls.png"))
local GameoverSprite = Sprite(love.graphics.newImage("assets/images/gameover.png"))

local skyGradient = Utils.newGradient({.5, .5, 1}, {.5, .5, 1}, {.3, .3, .8})
local popupGradient = Utils.newGradient({0,0,0,.5}, {0,0,0,.9}, {0,0,0,.9}, {0,0,0,.5})

local startTimer = Timer(0, 1.5, false)
startTimer.onEndedEvent:addCallback(function()
    GameData.started = true
    GameData.starting = false

    player = EntityBuilder.player(world, Vector2(WIDTH / 2, HEIGHT - 300), camera)
    CompositionManager.addEntity(player)

    ;(player:getComponent("BodyComponent") --[[@as BodyComponent]]).velocity.y = -700
end)


function Game:enter()
    CompositionManager.clear()

    local data = love.filesystem.read("agunmination.sav")


    GameData.maxHeight = data and (tostring(data) or 0) or 0
    GameData.height = 0
    GameData.enemySpawn = -1000
    GameData.timeSpeed = 1
    GameData.targetTimeSpeed = 1
    GameData.started = false
    GameData.starting = false
    GameData.gameOver = false

    menuFadeOut = 0

    camera.actualPosition.y = 0
    camera:setInterpolation(Easing.cubic, 30)

    music:stop()
    music:play()
    startTimer:restart()

    TransitionManager.play(Fade(1, false, {0,0,0,1}))
end

function Game:draw()
    love.graphics.setCanvas(screenCanvas)
        love.graphics.clear(.5, .5, 1)

        love.graphics.draw(skyGradient, 0, 0, 0, WIDTH, HEIGHT/3)

        Background1Sprite:draw(Vector2(0, HEIGHT - GameData.height*0.1):add(camera.shakeOffset))

        WallSprite.renderArea.topLeft.y = GameData.height
        WallSprite:draw(camera.shakeOffset)

        camera:attach()

        CompositionManager.broadcastToAllComponents("draw")

        camera:detach()

        MenuNameSprite.color[4] = 1 - menuFadeOut
        MenuNameSprite:draw(camera.shakeOffset)

        if showControls then
            ControlsSprite.color[4] = 1 - menuFadeOut
            ControlsSprite:draw(Vector2())
        end
    love.graphics.setCanvas()


    -- Post processing
    local result = screenCanvas
    result = Bloom:onPostRender(nil, result)
    result = HDR:onPostRender(nil, screenCanvas)
    result = ChromaticAberration:onPostRender(nil, result)

    love.graphics.draw(result)

    CompositionManager.broadcastToAllComponents("uiDraw")


    -- Game over
    if GameData.gameOver then
        love.graphics.draw(popupGradient, 0, 0, 0, WIDTH, HEIGHT/4)
        GameoverSprite:draw(Vector2())
    end
end

function Game:update(dt)
    dt = math.min(love.timer.getAverageDelta(), 1)
    GameData.trueDeltaTime = dt


    -- Update stuff
    CompositionManager.broadcastToAllComponents("update", dt * GameData.timeSpeed)
    camera:update(dt)
    startTimer:update(dt)

    menuFadeOut = math.min(menuFadeOut + (GameData.starting and dt or 0), 1)



    if GameData.started then
        local bounds = camera:getBounds()
        local playerTransform = player:getComponent("Transform2dComponent") --[[@as Transform2dComponent]]
        local playerDamageable = player:getComponent("DamageableComponent") --[[@as DamageableComponent]]

        GameData.height = math.min(GameData.height, playerTransform.position.y + HEIGHT/4)
        GameData.maxHeight = math.min(GameData.maxHeight, GameData.height)
        camera.position.y = GameData.height

        if playerDamageable.health <= 0 and not GameData.gameOver then
            music:stop()
            GameData.gameOver = true
            camera:shake(1, 20, .1)

            love.filesystem.write("agunmination.sav", tostring(GameData.maxHeight))
        end


        -- Spawn enemies
        if GameData.height < GameData.enemySpawn then

            if GameData.enemySpawn % 2000 == 0 then
                for i=1, math.random(1, 3) do
                    local enemyPos = Vector2(math.random(0, WIDTH-32), bounds.topLeft.y - 32)
                    CompositionManager.addEntity(EntityBuilder.jetpackEnemy(world, enemyPos, player, camera))
                end

                if math.random() <= 1/3 then
                    local enemyPos = Vector2(math.random(0, WIDTH-32), bounds.topLeft.y - 32 - math.random(0, 128))
                    CompositionManager.addEntity(EntityBuilder.parachuteEnemy(world, enemyPos, player, camera))
                end

            elseif GameData.enemySpawn % 1000 == 0 then
                for i=1, math.random(1, 3) do
                    local enemyPos = Vector2(math.random(0, WIDTH-32), bounds.topLeft.y - 32 - math.random(0, 128))
                    CompositionManager.addEntity(EntityBuilder.parachuteEnemy(world, enemyPos, player, camera))

                end

                if math.random() <= 1/3 then
                    local enemyPos = Vector2(math.random(0, WIDTH-32), bounds.topLeft.y - 32)
                    CompositionManager.addEntity(EntityBuilder.jetpackEnemy(world, enemyPos, player, camera))
                end
            end

            GameData.enemySpawn = GameData.enemySpawn - 1000
        end
    end


    -- Time slow
    GameData.timeSpeed = Lume.lerp(GameData.timeSpeed, GameData.targetTimeSpeed, Easing.quadratic(dt*15))
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
        showControls = false
    end

    if GameData.gameOver and key == "r" and not TransitionManager.isPlaying then
        local fade = Fade(1, true, {0,0,0,1})
        TransitionManager.play(fade)

        fade.onStop = function()
            Game:enter()
        end
    end
end

function Game:mousepressed(x, y, button)
    CompositionManager.broadcastToAllComponents("mousepressed", x, y, button)

    if not GameData.started then
        startTimer:play()
        GameData.starting = true
        showControls = false
    end
end

function Game:wheelmoved(x, y)
    CompositionManager.broadcastToAllComponents("wheelmoved", x, y)
end

return Game