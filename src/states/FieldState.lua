--[[
    MyRPG Prototype

    Dylan Maurel
]]

FieldState = Class{__includes = BaseState}

-- will have to be modified to take in the gameArea as an argument
function FieldState:init()
    self.gameArea = townArea()

    --gSounds['field-music']:setLooping(true)
    --gSounds['field-music']:play()
    self.player = Player {
        animations = ENTITY_DEFS['player'].animations,
        width = 16,
        height = 16
    }
    self.player.x = TILE_SIZE * 5
    self.player.y = TILE_SIZE * 16
    self.player.stateMachine = StateMachine {
        ['walk'] = function() return PlayerWalkState(self.player, self) end,
        ['idle'] = function() return PlayerIdleState(self.player) end
    }
    self.player.stateMachine:change('idle')

    self.cam = Camera()
end

function FieldState:update(dt)
    self.gameArea:update(dt)
    self.player:update(dt)

    local halfWindowWidth = love.graphics.getWidth() / 2
    local halfWindowHeight = love.graphics.getHeight() / 2
    -- We now need to make the camera track the player.
    -- Making the camera look at (love.graphics.getWidth() / 2, love.graphics.getHeight() / 2) will
    -- fix the camera in the top left of the screen. This is how the camera library is implemented. 
    -- The rest of the calculation will position the camera to have the player in the center.
    -- 11 is about the width and height of the player when the player sprite is scaled by 0.7.
    self.cam:lookAt(math.floor(halfWindowWidth + self.player.x - VIRTUAL_WIDTH / 2 + 11),
                   math.floor(halfWindowHeight + self.player.y - VIRTUAL_HEIGHT / 2 + 11))
    
    -- We now need to make sure that the camera doesn't show anywhere beyond borders of the gameArea
    local camX, camY = self.cam:position()
    local mapW = self.gameArea.mapWidth * TILE_SIZE
    local mapH = self.gameArea.mapHeight * TILE_SIZE
    -- left map border
    if camX < halfWindowWidth then
        camX = halfWindowWidth
    end
    -- right map border
    if camX > mapW + halfWindowWidth - VIRTUAL_WIDTH then
        camX = mapW + halfWindowWidth - VIRTUAL_WIDTH
    end
    -- top map border
    if camY < halfWindowHeight then
        camY = halfWindowHeight
    end
    -- bottom map border
    if camY > mapH + halfWindowHeight - VIRTUAL_HEIGHT then
        camY = mapH + halfWindowHeight - VIRTUAL_HEIGHT
    end
    self.cam:lookAt(camX, camY)
    
end

function FieldState:render()
    self.cam:attach()
        self.gameArea:render()
        -- Calling player:render() will call :render() for the player's current state.)
        self.player:render()
    self.cam:detach()
end