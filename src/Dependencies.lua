--[[
    MyRPG
    
    Author: Dylan Maurel
]]

-- Libraries
Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'
sti = require 'lib/sti'
Camera = require 'lib/camera'
Windfield = require 'lib/windfield'
--

-- Source Code:
require 'src/StateMachine'
require 'src/StateStack'
require 'src/constants'
require 'src/Util'
require 'src/Animation'
require 'src/Doorway'
-- World
require 'src/world/GameArea'
require 'src/world/GameArea_Defs'
-- GUI
require 'src/gui/Menu'
require 'src/gui/Panel'
require 'src/gui/ProgressBar'
require 'src/gui/Selection'
require 'src/gui/Textbox'
require 'src/gui/CombatStatus'
require 'src/gui/CombatSelection'
-- Game States
require 'src/states/BaseState'
require 'src/states/TakeTurnState'
require 'src/states/FieldState'
require 'src/states/BattleState'
require 'src/states/FadeInState'
require 'src/states/FadeOutState'
require 'src/states/DialogueState'
require 'src/states/DialogueSelectState'
-- Entities
require 'src/entities/entity_defs'
require 'src/entities/combat_entity_defs'
require 'src/entities/CombatEntity'
require 'src/entities/Entity'
require 'src/entities/Player'
-- Entity States
require 'src/entities/entity_states/EntityIdleState'
require 'src/entities/entity_states/EntityWalkState'
require 'src/entities/entity_states/PlayerIdleState'
require 'src/entities/entity_states/PlayerWalkState'

gTextures = {
    ['player-walk'] = love.graphics.newImage('graphics/Male 14-1.png'),
    ['dog'] = love.graphics.newImage('graphics/Dog 01-3.png'),
    ['female-warrior'] = love.graphics.newImage('graphics/Female 02-1.png'),
    ['grandma'] = love.graphics.newImage('graphics/Female 19-3.png'),
    ['male-priest'] = love.graphics.newImage('graphics/Male 08-4.png'),
    ['male-young'] = love.graphics.newImage('graphics/Male 10-3.png'),
    ['cursor'] = love.graphics.newImage('graphics/cursor.png'),
    ['combat-forest'] = love.graphics.newImage('graphics/battle_backgrounds/battleback1.png')
}

gFrames = {
    ['player-walk'] = GenerateQuads(gTextures['player-walk'], 32, 32),
    ['dog'] = GenerateQuads(gTextures['dog'], 32, 32),
    ['female-warrior'] = GenerateQuads(gTextures['female-warrior'], 32, 32),
    ['grandma'] = GenerateQuads(gTextures['grandma'], 32, 32),
    ['male-priest'] = GenerateQuads(gTextures['male-priest'], 32, 32),
    ['male-young'] = GenerateQuads(gTextures['male-young'], 32, 32)
}

-- All the combat textures can be split into evenly sized quads, but some of these sprites
-- contain a lot of blank space, making it difficult to draw them in the right location. 
-- To deal with this, the quads can be drawn at an offset, so that when they are drawn,
-- the x, y coordinates will denote the center of the quad instead of the top left corner.
gCombatSprites = {
    ['player-idle'] = love.graphics.newImage('graphics/player_combat/Idle.png'),
    ['player-run'] = love.graphics.newImage('graphics/player_combat/Run.png'),
    ['player-attack1'] = love.graphics.newImage('graphics/player_combat/Attack1.png'),
    ['samurai-idle'] = love.graphics.newImage('graphics/samurai_combat/Idle.png'),
    ['samurai-run'] = love.graphics.newImage('graphics/samurai_combat/Run.png'),
    ['samurai-attack1'] = love.graphics.newImage('graphics/samurai_combat/Attack1.png'),
    ['skeleton-idle'] = love.graphics.newImage('graphics/skeleton_combat/Idle.png'),
    ['skeleton-run'] = love.graphics.newImage('graphics/skeleton_combat/Walk.png'),
    ['skeleton-attack'] = love.graphics.newImage('graphics/skeleton_combat/Attack.png'),
    ['goblin-idle'] = love.graphics.newImage('graphics/goblin_combat/Idle.png'),
    ['goblin-run'] = love.graphics.newImage('graphics/goblin_combat/Run.png'),
    ['goblin-attack'] = love.graphics.newImage('graphics/goblin_combat/Attack.png')
}
gCombatFrames = {
    ['player-idle'] = GenerateQuads(gCombatSprites['player-idle'], 150, 150),
    ['player-run'] = GenerateQuads(gCombatSprites['player-run'], 150, 150),
    ['player-attack1'] = GenerateQuads(gCombatSprites['player-attack1'], 150, 150),
    ['samurai-idle'] = GenerateQuads(gCombatSprites['samurai-idle'], 200, 200),
    ['samurai-run'] = GenerateQuads(gCombatSprites['samurai-run'], 200, 200),
    ['samurai-attack1'] = GenerateQuads(gCombatSprites['samurai-attack1'], 200, 200),
    ['skeleton-idle'] = GenerateQuads(gCombatSprites['skeleton-idle'], 150, 150),
    ['skeleton-run'] = GenerateQuads(gCombatSprites['skeleton-run'], 150, 150),
    ['skeleton-attack'] = GenerateQuads(gCombatSprites['skeleton-attack'], 150, 150),
    ['goblin-idle'] = GenerateQuads(gCombatSprites['goblin-idle'], 150, 150),
    ['goblin-run'] = GenerateQuads(gCombatSprites['goblin-run'], 150, 150),
    ['goblin-attack'] = GenerateQuads(gCombatSprites['goblin-attack'], 150, 150),
}

gSounds = {
    ['sword'] = love.audio.newSource('sounds/sword.wav', 'static'),
    ['hit-enemy'] = love.audio.newSource('sounds/hit_enemy.wav', 'static'),
    ['hit-player'] = love.audio.newSource('sounds/hit_player.wav', 'static'),
    ['door'] = love.audio.newSource('sounds/door.wav', 'static'),
    ['rpg-music'] = love.audio.newSource('sounds/tiny-rpg-town.wav', 'static')
}

gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32),
    ['gothic-medium'] = love.graphics.newFont('fonts/GothicPixels.ttf', 16),
    ['gothic-large'] = love.graphics.newFont('fonts/GothicPixels.ttf', 32),
    ['zelda'] = love.graphics.newFont('fonts/zelda.otf', 64),
    ['zelda-medium'] = love.graphics.newFont('fonts/zelda.otf', 16)
}