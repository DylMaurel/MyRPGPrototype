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
require 'src/world/townArea'
require 'src/states/BaseState'
require 'src/states/FieldState'
require 'src/entities/entity_defs'
require 'src/entities/Entity'
require 'src/entities/Player'
require 'src/entities/entity_states/EntityIdleState'
require 'src/entities/entity_states/EntityWalkState'
require 'src/entities/entity_states/PlayerIdleState'
require 'src/entities/entity_states/PlayerWalkState'

gTextures = {
    -- player
    ['player-walk'] = love.graphics.newImage('graphics/Male 14-1.png')
}

gFrames = {
    ['player-walk'] = GenerateQuads(gTextures['player-walk'], 32, 32)
}