--[[
    myRPG Prototype
]]

GameArea = Class{}

function GameArea:init(def)
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