--[[
    MyRPG Prototype
]]
EntityWalkState = Class{__includes = BaseState}


function EntityWalkState:init(entity)
    self.entity = entity
    self.entity:changeAnimation('walk-down')

    -- used for AI control
    -- self.moveDuration = 0
    -- self.movementTimer = 0

end



function EntityWalkState:update(dt)
    -- possibly insert code for what happens during collisions
end



function EntityWalkState:processAI(params, dt)
    -- local room = params.room
    -- local directions = {'left', 'right', 'up', 'down'}

    -- if self.moveDuration == 0 or self.bumped then
        
    --     -- set an initial move duration and direction
    --     self.moveDuration = math.random(5)
    --     self.entity.direction = directions[math.random(#directions)]
    --     self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
    -- elseif self.movementTimer > self.moveDuration then
    --     self.movementTimer = 0

    --     -- chance to go idle
    --     if math.random(3) == 1 then
    --         self.entity:changeState('idle')
    --     else
    --         self.moveDuration = math.random(5)
    --         self.entity.direction = directions[math.random(#directions)]
    --         self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
    --     end
    -- end

    -- self.movementTimer = self.movementTimer + dt
end

function EntityWalkState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        self.entity.x, self.entity.y)
    
end