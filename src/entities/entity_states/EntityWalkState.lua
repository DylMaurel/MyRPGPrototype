--[[
    MyRPG Prototype
]]
EntityWalkState = Class{__includes = BaseState}


function EntityWalkState:init(entity)
    self.entity = entity
    self.entity:changeAnimation('walk-down')

    -- used for AI control
    self.moveDuration = 0
    self.movementTimer = 0

end



function EntityWalkState:update(dt)
    -- possibly insert code for what happens during collisions
end



function EntityWalkState:processAI(params, dt)
    -- local room = params.room
    local directions = {'left', 'right', 'up', 'down'}

    if self.moveDuration == 0 then
        
        -- set an initial move duration and direction
        self.moveDuration = math.random()
        self.entity.direction = directions[math.random(#directions)]
        self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
        local xVel, yVel = 0, 0
        if self.entity.direction == 'up' then
            yVel = -ENTITY_WALK_SPEED
        elseif self.entity.direction == 'down' then
            yVel = ENTITY_WALK_SPEED
        elseif self.entity.direction == 'left' then
            xVel = -ENTITY_WALK_SPEED
        else
            xVel = ENTITY_WALK_SPEED 
        end
        self.entity.collider:setLinearVelocity(xVel, yVel)
    elseif self.movementTimer > self.moveDuration then
        self.movementTimer = 0

        -- chance to go idle
        if math.random() <= 0.75 then
            --self.entity.collider:setLinearVelocity(0, 0)
            self.entity:changeState('idle')
        else
            self.moveDuration = math.random()
            self.entity.direction = directions[math.random(#directions)]
            self.entity:changeAnimation('walk-' .. tostring(self.entity.direction))
            local xVel, yVel = 0, 0
            if self.entity.direction == 'up' then
                yVel = -ENTITY_WALK_SPEED
            elseif self.entity.direction == 'down' then
                yVel = ENTITY_WALK_SPEED
            elseif self.entity.direction == 'left' then
                xVel = -ENTITY_WALK_SPEED
            else
                xVel = ENTITY_WALK_SPEED 
            end
            self.entity.collider:setLinearVelocity(xVel, yVel)
        end
    end

    self.movementTimer = self.movementTimer + dt
end

function EntityWalkState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x), math.floor(self.entity.y), 0, CHARACTER_SCALE, CHARACTER_SCALE)
    
end