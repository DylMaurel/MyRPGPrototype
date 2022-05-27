--[[
    MyRPG Prototype
]]


EntityIdleState = Class{__includes = BaseState}

function EntityIdleState:init(entity)
    self.entity = entity
    if self.entity.collider then
        self.entity.collider:setLinearVelocity(0, 0)
    end
    self.entity:changeAnimation('idle-' .. self.entity.direction)

    -- used for AI waiting
    self.waitDuration = 0
    self.waitTimer = 0
    self.triedChangeDir = false

    
end

--[[
    We can call this function if we want to use this state on an agent in our game; otherwise,
    we can use this same state in our Player class and have it not take action.
]]
function EntityIdleState:processAI(params, dt)
    if self.entity.movesAround == false then
        return
    end
    

    if self.waitDuration == 0 then
        self.waitDuration = math.random(5)
    else
        self.waitTimer = self.waitTimer + dt
        -- Chance to change their direction after waiting for a while 
        if self.triedChangeDir == false and self.waitTimer > self.waitDuration / 2 then
            self.triedChangeDir = true
            local directions = {'up', 'down', 'left', 'right'}
            if math.random(2) == 1 then
                self.entity.direction = directions[math.random(#directions)]
                self.entity:changeAnimation('idle-' .. self.entity.direction)
                -- Chance to stay still for a while
                if math.random(2) == 2 then
                    self.waitTimer = 0
                end
            end
        end

        if self.waitTimer > self.waitDuration then
            if math.random(2) == 1 then
                self.entity:changeState('walk')
            else
                self.entity:changeState('idle')
            end
        end
    end
end

function EntityIdleState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x), math.floor(self.entity.y), 0, CHARACTER_SCALE, CHARACTER_SCALE)
end