--[[
    myRPG Prototype
]]

townArea = Class{}

function townArea:init()
    self.map = sti('maps/townMap.lua')
    self.mapWidth = 48
    self.mapHeight = 27
end

function townArea:update(dt)

end

function townArea:render()
    -- Calling self.map:draw() will draw all map layers--including the the collidable
    -- layer, which is supposed to be invisible. So instead, we must draw each visible
    -- layer individually
    self.map:drawLayer(self.map.layers["grass"])
    self.map:drawLayer(self.map.layers["groundObjects"])
    self.map:drawLayer(self.map.layers["buildings"])
end