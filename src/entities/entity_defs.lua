--[[
    MyRPG Prototype
]]


ENTITY_DEFS = {
    ['player'] = {
        walkSpeed = PLAYER_WALK_SPEED,
        animations = {
            ['walk-down'] = {
                frames = {1, 2, 3},
                interval = 0.155,
                texture = 'player-walk'
            },
            ['walk-up'] = {
                frames = {10, 11, 12},
                interval = 0.155,
                texture = 'player-walk'
            },
            ['walk-left'] = {
                frames = {4, 5, 6},
                interval = 0.155,
                texture = 'player-walk'
            },
            ['walk-right'] = {
                frames = {7, 8, 9},
                interval = 0.155,
                texture = 'player-walk'
            },
            ['idle-down'] = {
                frames = {2},
                texture = 'player-walk'
            },
            ['idle-up'] = {
                frames = {11},
                texture = 'player-walk'
            },
            ['idle-left'] = {
                frames = {5},
                texture = 'player-walk'
            },
            ['idle-right'] = {
                frames = {8},
                texture = 'player-walk'
            },
        }
    }
}
