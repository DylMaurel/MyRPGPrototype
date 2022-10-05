--[[
    MyRPG Prototype

    Definitions file to define the properties of specific game areas.
]]


GAME_AREA_DEFS = {
    ['town-area'] = {
        -- Define the path to the map file that was exported from Tiled.
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
            },
            ['bottom-exit'] = {
                area = 'forest',
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
    },

    ['forest'] = {
        filepath = 'maps/forestMap.lua',
        width = 30,
        height = 27,
        areaName = 'forest',
        showBlackSpace = false,
        -- The optional layer called "render-last" should not be listed here,
        -- since the layers listed here are only the ones that will be rendered
        -- in GameArea.lua
        tileLayers = {
            [1] = "ground",
            [2] = "ground-objects1",
            [3] = "ground-objects2",
        },
        -- We need to define the area that each door connects to, as well as
        -- the name of the door in the next area that connects to this door.
        doorways = {
            ['exit'] = {
                area = 'town-area',
                otherDoor = 'bottom-exit' 
            }
        }
    },
}