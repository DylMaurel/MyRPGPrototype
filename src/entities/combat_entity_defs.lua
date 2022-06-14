--[[
    My RPG Prototype
]]


COMBAT_ENTITY_DEFS = {
    ['player'] = {
        baseHP = 10,
        baseAttack = 30,
        baseDefense = 25,
        baseSpeed = 30,
        HPIV = 3,
        attackIV = 3,
        defenseIV = 3,
        speedIV = 4,
        shadow = {width =12, height =6, offsetY =18, offsetX = 0},
        drawOffset = 75, -- The center of all player quads is 75, 75
        flipped = true, -- The player must face the left, but they are facing right in the png file
        animations = {
            ['idle'] = {
                frames = {1, 2, 3, 4, 5, 6, 7, 8},
                interval = 0.1,
                texture = 'player-idle'
            },
            ['attack1'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'player-attack1',
                looping = false
            },
            ['run'] = {
                frames = {1, 2, 3, 4, 5, 6, 7, 8},
                interval = 0.1,
                texture = 'player-run'
            },
            ['take-hit'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'player-take-hit'
            },
            ['dying'] = {
                frames = {1, 2, 3, 4, 5, 6},
                interval = 0.1,
                texture = 'player-death'
            },
            ['dead'] = {
                frames = {6},
                interval = 0.1,
                texture = 'player-death'
            },
        }
    },
    ['samurai'] = {
        baseHP = 10,
        baseAttack = 35,
        baseDefense = 20,
        baseSpeed = 35,
        HPIV = 3,
        attackIV = 3,
        defenseIV = 3,
        speedIV = 5,
        shadow = {width =14, height =6, offsetY =27, offsetX = -2},
        drawOffset = 100, -- The center of all samurai quads is 100, 100
        flipped = true,
        animations = {
            ['idle'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'samurai-idle'
            },
            ['attack1'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'samurai-attack1',
                looping = false
            },
            ['run'] = {
                frames = {1, 2, 3, 4, 5, 6, 7, 8},
                interval = 0.1,
                texture = 'samurai-run'
            },
            ['take-hit'] = {
                frames = {3, 2, 1},
                interval = 0.155,
                texture = 'samurai-take-hit'
            },
            ['dying'] = {
                frames = {1, 2, 3, 4, 5, 6, 7},
                interval = 0.1,
                texture = 'samurai-death'
            },
            ['dead'] = {
                frames = {7},
                interval = 0.1,
                texture = 'samurai-death'
            },
        }
    },
    ['skeleton'] = {
        baseHP = 50,
        baseAttack = 20,
        baseDefense = 15,
        baseSpeed = 15,
        HPIV = 3,
        attackIV = 3,
        defenseIV = 3,
        speedIV = 3,
        shadow = {width =18, height =6, offsetY =25, offsetX = 3},
        drawOffset = 75, -- The center of all skeleton quads is 75, 75
        flipped = false,
        animations = {
            ['idle'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'skeleton-idle'
            },
            ['attack'] = {
                frames = {1, 2, 3, 4, 5, 6, 7, 8},
                interval = 0.1,
                texture = 'skeleton-attack',
                looping = false
            },
            ['run'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'skeleton-run'
            },
            ['take-hit'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'skeleton-take-hit'
            },
            ['dying'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'skeleton-death'
            },
            ['dead'] = {
                frames = {4},
                interval = 0.155,
                texture = 'skeleton-death'
            },
        }
    },
    ['goblin'] = {
        baseHP = 40,
        baseAttack = 20,
        baseDefense = 15,
        baseSpeed = 20,
        HPIV = 3,
        attackIV = 3,
        defenseIV = 3,
        speedIV = 3,
        shadow = {width =18, height =6, offsetY =25, offsetX = 0},
        drawOffset = 75, -- The center of all goblin quads is 75, 75
        flipped = false,
        animations = {
            ['idle'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'goblin-idle'
            },
            ['attack'] = {
                frames = {1, 2, 3, 4, 5, 6, 7, 8},
                interval = 0.1,
                texture = 'goblin-attack',
                looping = false
            },
            ['run'] = {
                frames = {1, 2, 3, 4, 5, 6, 7, 8},
                interval = 0.1,
                texture = 'goblin-run'
            },
            ['take-hit'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'goblin-take-hit'
            },
            ['dying'] = {
                frames = {1, 2, 3, 4},
                interval = 0.155,
                texture = 'goblin-death'
            },
            ['dead'] = {
                frames = {4},
                interval = 0.155,
                texture = 'goblin-death'
            },
        }
    },
}