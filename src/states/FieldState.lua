--[[
    MyRPG Prototype
    FieldState.lua

    A FieldState is meant to encapsulate the state of a free-roaming
    game area by containing a player, objects, entities, and a tilemap
    for the area.
    We also wnat to provide the ability to create multiple FieldStates
    on top of each other. For example, A FieldState for a town area can
    be pushed to the StateStack, and then another FieldState can be created
    and pushed for the  interior of a building in the town.

    A Box2D physics world handles all collisions within a FieldState.
    We are using Windfield, a library that wraps LÖVE's physics API so that
    using Box2D becomes as simple as possible.

    Dylan Maurel
]]


FieldState = Class{__includes = BaseState}

-- will have to be modified to take in the gameArea as an argument
function FieldState:init()
    self.gameArea = townArea()
    self.physicsWorld = Windfield.newWorld(0,0)
    --gSounds['field-music']:setLooping(true)
    --gSounds['field-music']:play()
    self.collidables = {}
    self.physicsWorld:addCollisionClass('Button')
    if self.gameArea.map.layers['collidables'] then
        -- Loop through all the objects we created for the map in Tiled, and
        -- create physics colliders for each one.
        for i, obj in pairs(self.gameArea.map.layers['collidables'].objects) do
            local collidable = self.physicsWorld:newRectangleCollider(
                obj.x, obj.y, obj.width, obj.height)
            collidable:setType('static')
            collidable:setCollisionClass('Button')
            table.insert(self.collidables, collidable)
        end
    end

    --  
    -- Creating the player
    --
    self.player = Player {
        animations = ENTITY_DEFS['player'].animations,
        width = 16,
        height = 16
    }
    -- Place the player on the map.
    self.player.x = TILE_SIZE * 5
    self.player.y = TILE_SIZE * 16
    -- Create the stateMachine for the player.
    self.player.stateMachine = StateMachine {
        -- The PlayerWalkState needs access to the FieldState so that the
        -- player can interact with world objects and entities. So, whenever
        -- a PlayerWalkState is created, we pass self into it.
        ['walk'] = function() return PlayerWalkState(self.player, self) end,
        ['idle'] = function() return PlayerIdleState(self.player) end
    }
    self.player.stateMachine:change('idle')
    -- Make a physics collider for the player.
    self.player.collider = self.physicsWorld:newBSGRectangleCollider(
        self.player.x, self.player.y, 11, 13, 9        
    )
    self.player.collider:setFixedRotation(true)
    --
    -- Done creating the player
    --
    self.physicsWorld:addCollisionClass('Player')
    self.player.collider:setCollisionClass('Player')
    
    self.cam = Camera()
    self.score = 0
end

function FieldState:update(dt)
    self.gameArea:update(dt)
    self.player:update(dt)
    self.physicsWorld:update(dt)
    -- The coordinates of the player and player.collider are slightly off,
    -- so we need to subtract some offset values.
    self.player.x = self.player.collider:getX() - 11
    self.player.y = self.player.collider:getY() - 16

    -- Allow the player to query the world by pressing 'enter' or 'return'.
    -- This means we will create a collider in front of the player and see
    -- if it collides with any interactable objects or entities.
    self.queryCircle = nil
    if love.keyboard.keysPressed['enter'] or love.keyboard.keysPressed['return'] then
        local queryX, queryY = self.player.x + 11, self.player.y + 12
        if self.player.direction == 'left' then
            queryX = queryX - 12
        
        elseif self.player.direction == 'right' then
            queryX = queryX + 15
        
        elseif self.player.direction == 'up' then
            queryY = queryY - 10
        
        elseif self.player.direction == 'down' then
            queryY = queryY + 18
        end
        self.queryCircle = {x=queryX, y=queryY, radius = 10}
        local colliders = self.physicsWorld:queryCircleArea(queryX, queryY, 10, {'Button'})
        if #colliders > 0 then
            self.score = self.score + 1
        end
    end


    -- We now need to make the camera track the player.
    local halfWindowWidth = love.graphics.getWidth() / 2
    local halfWindowHeight = love.graphics.getHeight() / 2
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
        self.physicsWorld:draw()
        if self.queryCircle then
            love.graphics.circle("line",self.queryCircle.x,self.queryCircle.y,self.queryCircle.radius)
        end
    self.cam:detach()
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)
end