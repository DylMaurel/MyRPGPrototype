PlayerWalkState = Class{__includes = EntityWalkState}

function PlayerWalkState:init(entity, gameArea)
    self.entity = entity
    self.gameArea = gameArea
end

function PlayerWalkState:update(dt)
    if love.keyboard.isDown('left') then
        self.entity.direction = 'left'
        self.entity:changeAnimation('walk-left')
        self.entity.x = self.entity.x - PLAYER_WALK_SPEED * dt
    elseif love.keyboard.isDown('right') then
        self.entity.direction = 'right'
        self.entity:changeAnimation('walk-right')
        self.entity.x = self.entity.x + PLAYER_WALK_SPEED * dt
    elseif love.keyboard.isDown('up') then
        self.entity.direction = 'up'
        self.entity:changeAnimation('walk-up')
        self.entity.y = self.entity.y - PLAYER_WALK_SPEED * dt
    elseif love.keyboard.isDown('down') then
        self.entity.direction = 'down'
        self.entity:changeAnimation('walk-down')
        self.entity.y = self.entity.y + PLAYER_WALK_SPEED * dt
    else
        self.entity:changeState('idle')
    end
end

function PlayerWalkState:render()
    local anim = self.entity.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.entity.x), math.floor(self.entity.y), 0, 0.7, 0.7)
end