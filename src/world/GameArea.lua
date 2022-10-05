--[[
    myRPG Prototype

    This class parses information from GameArea_Defs to create render a game area that can be connected, by
    doorways, to other game areas. This class is also responsible for creating the box2d physics world that will
    calculate all collisions within a game area.
]]

GameArea = Class{}

function GameArea:init(def)
    -- use the Simple Tiled Implementation (sti) library to read a map file that was exported from Tiled.
    self.map = sti(def.filepath)
    self.name = def.areaName
    self.mapWidth = def.width
    self.mapHeight = def.height
    -- A table of the names of the tile layers.
    self.tileLayers = def.tileLayers
    -- A bool to indicate if the camera should show black space outside the map.
    self.showBlackSpace = def.showBlackSpace
end

function GameArea:update(dt)

end

-- Returns a box2d physics world that contains colliders for the game area.
-- Also returns a table of Doorway objects.
function GameArea:createPhysicsWorld()
    local physicsWorld = Windfield.newWorld(0,0)
    physicsWorld:addCollisionClass('Doorway')
    local doorways = {}
    
    -- If we made a 'collidables' object layer in Tiled, then we need to loop through 
    -- all the objects in that layer and create physics colliders for each one.
    if self.map.layers['collidables'] then
        for i, obj in pairs(self.map.layers['collidables'].objects) do
            local collidable = nil
            -- In tiled we can make both rectangle and polygon shaped objects.
            -- We have to create a collider for the appropriate shape.
            if obj.shape == "polygon" then
                -- The format in which polygon vertices are stored in STI is different
                -- than the format that Windfield (the physics api) requires.
                -- So, we change the format of the vertices here.
                local vertices = {}
                for _, pair in pairs(obj.polygon) do
                    table.insert(vertices, pair.x)
                    table.insert(vertices, pair.y)
                end
                collidable = physicsWorld:newPolygonCollider(vertices)
            else
                collidable = physicsWorld:newRectangleCollider(
                obj.x, obj.y, obj.width, obj.height)
            end
            -- Static colliders can influence other colliders, but static colliders can't
            -- be influenced themselves. This is what we want for buildings, trees, etc.
            collidable:setType('static')

            if obj.properties.isDoorway then
                local doorway = Doorway(
                    {x=obj.x, y=obj.y, width=obj.width, height=obj.height,
                    direction = obj.properties.direction, type = obj.properties.type,
                    name = obj.properties.name, fadeColor = obj.properties.fadeColor})
                doorways[doorway.name] = doorway
                collidable:setCollisionClass('Doorway')
                collidable:setObject(doorway)
            end
        end
    end
    return physicsWorld, doorways
end



function GameArea:render()
    -- This function requires that the tile layers are listed in order
    -- within GameArea_Defs.
    for _, layerName in ipairs(self.tileLayers) do
        if layerName == "transparent" then
            love.graphics.setColor(1, 1, 1, 0.5)
            self.map:drawLayer(self.map.layers[layerName])
            love.graphics.setColor(1, 1, 1, 1)
        else
            self.map:drawLayer(self.map.layers[layerName])
        end
    end
end