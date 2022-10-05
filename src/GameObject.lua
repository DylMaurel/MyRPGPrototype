--
-- Defines the basic characteristics of a game object, in general.
--

GameObject = Class{}

function GameObject:init(def, x, y)
    self.x = x
    self.y = y
    self.width = def.width
    self.height = def.height

    self.type = def.type
    self.texture = def.texture
    self.frame = def.frame or 1

    -- default empty collision callback
    self.onCollide = function() end

     -- default empty selection callback
     self.onSelect = function() end
end

function GameObject:update(dt)

end

function GameObject:render()
    if self.states then
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.states[self.state].frame or self.frame],
            self.x + adjacentOffsetX, self.y + adjacentOffsetY)
    else
        love.graphics.draw(gTextures[self.texture], gFrames[self.texture][self.frame],
            self.x + adjacentOffsetX, self.y + adjacentOffsetY)
    end
end