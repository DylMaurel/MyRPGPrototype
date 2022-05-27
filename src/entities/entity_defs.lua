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
    },

    ['dog'] = {
        walkSpeed = ENTITY_WALK_SPEED,
        dialogues = {
            [1] = {
               text = 'Arf! arf!',
            }
        },
        movesAround = true,
        animations = {
            ['walk-down'] = {
                frames = {1, 2, 3},
                interval = 0.155,
                texture = 'dog'
            },
            ['walk-up'] = {
                frames = {10, 11, 12},
                interval = 0.155,
                texture = 'dog'
            },
            ['walk-left'] = {
                frames = {4, 5, 6},
                interval = 0.155,
                texture = 'dog'
            },
            ['walk-right'] = {
                frames = {7, 8, 9},
                interval = 0.155,
                texture = 'dog'
            },
            ['idle-down'] = {
                frames = {2},
                texture = 'dog'
            },
            ['idle-up'] = {
                frames = {11},
                texture = 'dog'
            },
            ['idle-left'] = {
                frames = {5},
                texture = 'dog'
            },
            ['idle-right'] = {
                frames = {8},
                texture = 'dog'
            },
        }
    },

    ['female-warrior'] = {
        walkSpeed = ENTITY_WALK_SPEED,
        dialogues = {
            [1] = {
                text = 'The lands south of here are dangerous. They are filled with' .. 
                ' monsters who will ambush you without warning. Be wary traveller.',
                }
        },
        movesAround = true,
        animations = {
            ['walk-down'] = {
                frames = {1, 2, 3},
                interval = 0.155,
                texture = 'female-warrior'
            },
            ['walk-up'] = {
                frames = {10, 11, 12},
                interval = 0.155,
                texture = 'female-warrior'
            },
            ['walk-left'] = {
                frames = {4, 5, 6},
                interval = 0.155,
                texture = 'female-warrior'
            },
            ['walk-right'] = {
                frames = {7, 8, 9},
                interval = 0.155,
                texture = 'female-warrior'
            },
            ['idle-down'] = {
                frames = {2},
                texture = 'female-warrior'
            },
            ['idle-up'] = {
                frames = {11},
                texture = 'female-warrior'
            },
            ['idle-left'] = {
                frames = {5},
                texture = 'female-warrior'
            },
            ['idle-right'] = {
                frames = {8},
                texture = 'female-warrior'
            },
        }
    },

    ['male-priest'] = {
        walkSpeed = ENTITY_WALK_SPEED,
        dialogues = {
            [1] = {
                text = 'Do you see that house nearby? That\'s where I live.' ..
                ' You shouldn\'t try to go inside, though. That area has' ..
                'n\'t been implemented yet. A blue screen awaits.',
                isQuestion = false
                }
        },
        movesAround = true,
        animations = {
            ['walk-down'] = {
                frames = {1, 2, 3},
                interval = 0.155,
                texture = 'male-priest'
            },
            ['walk-up'] = {
                frames = {10, 11, 12},
                interval = 0.155,
                texture = 'male-priest'
            },
            ['walk-left'] = {
                frames = {4, 5, 6},
                interval = 0.155,
                texture = 'male-priest'
            },
            ['walk-right'] = {
                frames = {7, 8, 9},
                interval = 0.155,
                texture = 'male-priest'
            },
            ['idle-down'] = {
                frames = {2},
                texture = 'male-priest'
            },
            ['idle-up'] = {
                frames = {11},
                texture = 'male-priest'
            },
            ['idle-left'] = {
                frames = {5},
                texture = 'male-priest'
            },
            ['idle-right'] = {
                frames = {8},
                texture = 'male-priest'
            },
        }
    },

    ['male-young'] = {
        walkSpeed = ENTITY_WALK_SPEED,
        dialogues = {
            [1] = {
                text = 'Hey mister, there seems to be monsters around these parts.',
                isQuestion = false
            },
            [2] = {
                text = 'Would you like some health potions?',
                isQuestion = true,
                answers = {
                    [1] = 'Yes',
                    [2] = 'No'
                }, 
                -- A response to a player's answer will open up a new dialogue state in a recursive-ish manner.
                -- So, a response must be formatted in the same way that a dialogue is formatted.
                -- That is, the dialogues table and the responses table have the same format.
                responses = {
                    [1] = { -- this response is linked to answer 1 because they both have an index of 1
                        [1] = {
                        text = 'Okay, here are the potions.',
                        isQuestion = false
                        }
                    },
                    [2] = { -- this response is linked to answer 2 because they both have an index of 2
                        [1] = {
                        text = 'Okay, maybe next time.',
                        isQuestion = false
                        }
                    }
                }
            }
        },
        movesAround = false,
        animations = {
            ['walk-down'] = {
                frames = {1, 2, 3},
                interval = 0.155,
                texture = 'male-young'
            },
            ['walk-up'] = {
                frames = {10, 11, 12},
                interval = 0.155,
                texture = 'male-young'
            },
            ['walk-left'] = {
                frames = {4, 5, 6},
                interval = 0.155,
                texture = 'male-young'
            },
            ['walk-right'] = {
                frames = {7, 8, 9},
                interval = 0.155,
                texture = 'male-young'
            },
            ['idle-down'] = {
                frames = {2},
                texture = 'male-young'
            },
            ['idle-up'] = {
                frames = {11},
                texture = 'male-young'
            },
            ['idle-left'] = {
                frames = {5},
                texture = 'male-young'
            },
            ['idle-right'] = {
                frames = {8},
                texture = 'male-young'
            },
        }
    },

    ['grandma'] = {
        walkSpeed = ENTITY_WALK_SPEED,
        dialogues = {
            [1] = {
                text = 'What can I do for you, sonny?',
                isQuestion = false
                }
        },
        movesAround = true,
        animations = {
            ['walk-down'] = {
                frames = {1, 2, 3},
                interval = 0.155,
                texture = 'grandma'
            },
            ['walk-up'] = {
                frames = {10, 11, 12},
                interval = 0.155,
                texture = 'grandma'
            },
            ['walk-left'] = {
                frames = {4, 5, 6},
                interval = 0.155,
                texture = 'grandma'
            },
            ['walk-right'] = {
                frames = {7, 8, 9},
                interval = 0.155,
                texture = 'grandma'
            },
            ['idle-down'] = {
                frames = {2},
                texture = 'grandma'
            },
            ['idle-up'] = {
                frames = {11},
                texture = 'grandma'
            },
            ['idle-left'] = {
                frames = {5},
                texture = 'grandma'
            },
            ['idle-right'] = {
                frames = {8},
                texture = 'grandma'
            },
        }
    }
}
