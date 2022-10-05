--[[
    myRPG Prototype

    This class is used when the player is standing still within the FieldState.
]]

PlayerIdleState = Class{__includes = EntityIdleState}

function PlayerIdleState:init(entity)
    EntityIdleState.init(self, entity)
    self.entity.isIdle = true
    self.entity.isWalking = false
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
        math.floor(self.entity.x), math.floor(self.entity.y), 0, CHARACTER_SCALE, CHARACTER_SCALE)
end