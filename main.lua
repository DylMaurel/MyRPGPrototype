--[[
    MyRPG Prototype

    Dylan Maurel

    ART:
    Courtesy of ...
]]

require 'src/Dependencies'

function love.load()
    love.window.setTitle('myRPG')
    -- This filter creates a more vintage, pixel-like look.
    love.graphics.setDefaultFilter('nearest', 'nearest')
    math.randomseed(os.time())

    -- The push library enable us to code towards a virtual screen size. This way,
    -- users can resize the screen without any complications.
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })

    -- initialize the global state stack that will determine the flow of the game.
    gStateStack = StateStack()
    -- Specify which area needs to be loaded in the FieldState. Also specify the
    -- starting position of the player.

    --gStateStack:push(FieldState('town-area', 'inn-door', 'down'))
    gStateStack:push(FadeInState({r=1, g=1, b=1}, 0.5,
    function()
        gStateStack:push(BattleState())
        gStateStack:push(FadeOutState({r=1, g=1, b=1}, 0.5, function() end))
    end
    ))

    love.keyboard.keysPressed = {}

    -- In the future, background music could be managed by some sort of music manager class,
    -- instead of just having one song always being played the whole time.
    gSounds['rpg-music']:setLooping(true)
    gSounds['rpg-music']:play()
end


function love.resize(w, h)
    push:resize(w, h)
end

-- Whenever a key is pressed, love will call this function.
-- We have added our own keysPressed table to love.keyboard.
-- So, any part of the code can query the keysPressed table to
-- see what keys were pressed during a given frame.
-- This idea was learned from CS50's Intro to Game Dev course.
function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    love.keyboard.keysPressed[key] = true
end


function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end


function love.update(dt)
    Timer.update(dt)
    gStateStack:update(dt)

    love.keyboard.keysPressed = {}
end


function love.draw()
    push:start()
    gStateStack:render()
    --love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), 10, 10)
    push:finish()
end