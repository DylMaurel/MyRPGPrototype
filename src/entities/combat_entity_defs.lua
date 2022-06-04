--[[
    My RPG Prototype
]]


COMBAT_ENTITY_DEFS = {
    ['player'] = {
        walkSpeed = PLAYER_WALK_SPEED,
        drawOffset = 75, -- The center of all player quads is 75, 75
        flipped = true, -- The player must face the left, but they are facing right in the png file
        animations = {
            ['idle'] = {
                frames = {1, 2, 3, 4, 5, 6, 7, 8},
                interval = 0.1,
                texture = 'player-idle'
            },
        }
    },
    ['samurai'] = {
        walkSpeed = PLAYER_WALK_SPEED,
        drawOffset = 100, -- The center of all samurai quads is 100, 100
        flipped = false,
        animations = {
            ['idle'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'samurai-idle'
            },
        }
    },
}