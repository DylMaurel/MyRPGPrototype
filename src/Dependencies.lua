--[[
    MyRPG
    
    Author: Dylan Maurel
]]

Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'
sti = require 'lib/sti'
Camera = require 'lib/camera'
Windfield = require 'lib/windfield'

require 'src/StateMachine'
require 'src/StateStack'
require 'src/constants'
require 'src/Util'
require 'src/Animation'
require 'src/Doorway'
require 'src/world/GameArea'
require 'src/world/GameArea_Defs'
require 'src/states/BaseState'
require 'src/states/FieldState'
require 'src/states/FadeInState'
require 'src/states/FadeOutState'
require 'src/entities/entity_defs'
require 'src/entities/Entity'
require 'src/entities/Player'
require 'src/entities/entity_states/EntityIdleState'
require 'src/entities/entity_states/EntityWalkState'
require 'src/entities/entity_states/PlayerIdleState'
require 'src/entities/entity_states/PlayerWalkState'

gTextures = {
    -- player
    ['player-walk'] = love.graphics.newImage('graphics/Male 14-1.png'),
    ['dog'] = love.graphics.newImage('graphics/Dog 01-3.png'),
    ['female-warrior'] = love.graphics.newImage('graphics/Female 02-1.png'),
    ['grandma'] = love.graphics.newImage('graphics/Female 19-3.png'),
    ['male-priest'] = love.graphics.newImage('graphics/Male 08-4.png'),
    ['male-young'] = love.graphics.newImage('graphics/Male 10-3.png')
}

gFrames = {
    ['player-walk'] = GenerateQuads(gTextures['player-walk'], 32, 32),
    ['dog'] = GenerateQuads(gTextures['dog'], 32, 32),
    ['female-warrior'] = GenerateQuads(gTextures['female-warrior'], 32, 32),
    ['grandma'] = GenerateQuads(gTextures['grandma'], 32, 32),
    ['male-priest'] = GenerateQuads(gTextures['male-priest'], 32, 32),
    ['male-young'] = GenerateQuads(gTextures['male-young'], 32, 32)
}

gSounds = {
    ['music'] = love.audio.newSource('sounds/music.mp3', 'static'),
    ['sword'] = love.audio.newSource('sounds/sword.wav', 'static'),
    ['hit-enemy'] = love.audio.newSource('sounds/hit_enemy.wav', 'static'),
    ['hit-player'] = love.audio.newSource('sounds/hit_player.wav', 'static'),
    ['door'] = love.audio.newSource('sounds/door.wav', 'static')
}