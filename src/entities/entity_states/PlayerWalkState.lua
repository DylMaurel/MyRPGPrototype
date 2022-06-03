PlayerWalkState = Class{__includes = EntityWalkState}

function PlayerWalkState:init(player, gameArea)
    self.player = player
    self.gameArea = gameArea
    self.player.isWalking = true
    self.player.isIdle = false
end

function PlayerWalkState:update(dt)
    local xVel, yVel = 0, 0
    local goIdle = true

    if love.keyboard.isDown('left') then
        self.player.direction = 'left'
        self.player:changeAnimation('walk-left')
         xVel = xVel - PLAYER_WALK_SPEED
         goIdle = false
    end
    if love.keyboard.isDown('right') then
        self.player.direction = 'right'
        self.player:changeAnimation('walk-right')
        xVel = xVel + PLAYER_WALK_SPEED
        goIdle = false
    end
    if love.keyboard.isDown('up') then
        self.player.direction = 'up'
        self.player:changeAnimation('walk-up')
        yVel = yVel - PLAYER_WALK_SPEED
        goIdle = false
    end
    if love.keyboard.isDown('down') then
        self.player.direction = 'down'
        self.player:changeAnimation('walk-down')
        yVel = yVel + PLAYER_WALK_SPEED
        goIdle = false
    end
    if goIdle then
        self.player:changeState('idle')
    end

    self.player.collider:setLinearVelocity(xVel, yVel)
end

function PlayerWalkState:render()
    local anim = self.player.currentAnimation
    love.graphics.draw(gTextures[anim.texture], gFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.player.x), math.floor(self.player.y), 0, CHARACTER_SCALE, CHARACTER_SCALE)
end