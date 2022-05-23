--[[
    MyRPG Prototype
]]


GAME_AREA_DEFS = {
    ['town-area'] = {
        filepath = 'maps/townMap.lua',
        width = 48,
        height = 27,
        areaName = 'town-area',
        showBlackSpace = false,
        -- The optional layer called "render-last" should not be listed here,
        -- since the layers listed here are only the ones that will be rendered
        -- in GameArea.lua
        tileLayers = {
            [1] = "grass",
            [2] = "groundObjects",
            [3] = "buildings"
        },
        -- We need to define the area that each door connects to, as well as
        -- the name of the door in the next area that connects to this door.
        doorways = {
            ['inn-door'] = {
                area = 'house-interior',
                otherDoor = 'exit' 
            }
        }
    },
    ['house-interior'] = {
        filepath = 'maps/houseInterior.lua',
        width = 20,
        height = 18,
        areaName = 'house-interior',
        showBlackSpace = true,
        -- The optional layer called "render-last" should not be listed here,
        -- since the layers listed here are only the ones that will be rendered
        -- in GameArea.lua
        tileLayers = {
            [1] = "walls-and-floor",
            [2] = "edges",
            [3] = "furnishings1",
            [4] = "furnishings2",
            [5] = "transparent"
        },
         -- We need to define the area that each door connects to, as well as
        -- the name of the door in the next area that connects to this door.
        doorways = {
            ['exit'] = {
                area = 'town-area',
                otherDoor = 'inn-door' 
            }
        }
    }
}