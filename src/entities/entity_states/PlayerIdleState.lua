-- This class can be extended to add more functionality to the player.

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:init(entity)
    EntityIdleState.init(self, entity)
end

function PlayerIdleState:update(dt)
    if love.keyboard.isDown('left') or
        love.keyboard.isDown('right') or 
        love.keyboard.isDown('up') or
        love.keyboard.isDown('down') then
        
            self.entity:changeState('walk')
    end
end

function PlayerIdleState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x), math.floor(self.entity.y), 0, 0.7, 0.7)
end