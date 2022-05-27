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
function FieldState:init(areaName, arrivalDoorName, playerDir)
    self.gameArea = GameArea(GAME_AREA_DEFS[areaName])
    self.physicsWorld = Windfield.newWorld(0,0)
    self.collidables = {}
    self.doorways = {}
    self.physicsWorld:addCollisionClass('Doorway')

    if self.gameArea.map.layers['collidables'] then
        -- Loop through all the objects we created for the map in Tiled, and
        -- create physics colliders for each one.
        for i, obj in pairs(self.gameArea.map.layers['collidables'].objects) do
            local collidable = self.physicsWorld:newRectangleCollider(
                obj.x, obj.y, obj.width, obj.height)
            collidable:setType('static')

            if obj.properties.isDoorway then
                local doorway = Doorway(
                    {x=obj.x, y=obj.y, width=obj.width, height=obj.height,
                    direction = obj.properties.direction, type = obj.properties.type,
                    name = obj.properties.name, fadeColor = obj.properties.fadeColor})
                self.doorways[doorway.name] = doorway
                collidable:setCollisionClass('Doorway')
                collidable:setObject(doorway)
            end
            table.insert(self.collidables, collidable)
        end
    end
    -- Create a table of all non-player entities in the area. 
    self.entities = {}
    self:generateEntities()

    --  
    -- Creating the player
    --
    self.player = Player {
        animations = ENTITY_DEFS['player'].animations,
        width = 16,
        height = 16,
        direction = playerDir
    }
    -- Place the player on the map. Their position depends on what door the player
    -- arrived from. 
    local arrivalDoor = self.doorways[arrivalDoorName]
    local px, py = 0, 0
    if playerDir == 'up' then
        px = arrivalDoor.x + math.floor(arrivalDoor.width / 2 - self.player.width * CHARACTER_SCALE / 2)
        py = arrivalDoor.y - self.player.height
    elseif playerDir == 'down' then
        px = arrivalDoor.x + math.floor(arrivalDoor.width / 2 - self.player.width * CHARACTER_SCALE / 2)
        py = arrivalDoor.y + arrivalDoor.height
    elseif playerDir == 'left' then
        px = arrivalDoor.x - self.player.width
        py = arrivalDoor.y + math.floor(arrivalDoor.height / 2 - self.player.height * CHARACTER_SCALE / 2)
    else
        px = arrivalDoor.x + arrivalDoor.width
        py = arrivalDoor.y + math.floor(arrivalDoor.height / 2 - self.player.height * CHARACTER_SCALE / 2)
    end
    self.player.x = px
    self.player.y = py
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
    self.physicsWorld:addCollisionClass('Player')
    self.player.collider:setCollisionClass('Player')
    self.player.x = self.player.collider:getX() - 11
    self.player.y = self.player.collider:getY() - 16
    --
    -- Done creating the player
    --

    self.cam = Camera()
    FieldState:updateCamera(self)
end

function FieldState:update(dt)
    self.gameArea:update(dt)
    self.player:update(dt)
    for _, entity in pairs(self.entities) do
        entity:processAI(self, dt)
        entity:update(dt)
        entity.x = entity.collider:getX() - 11
        entity.y = entity.collider:getY() - 16
    end
    self.physicsWorld:update(dt)
    -- The coordinates of the player and player.collider are slightly off,
    -- so we need to subtract some offset values.
    self.player.x = self.player.collider:getX() - 11
    self.player.y = self.player.collider:getY() - 16

    -- Allow the player to query the world by pressing 'enter' or 'return'.
    -- This means we will create a collider in front of the player and see
    -- if it collides with any interactable objects or entities.
    self.queryCircle = nil --visualizing the queryCircle
    if love.keyboard.keysPressed['enter'] or love.keyboard.keysPressed['return'] then
        local queryX = self.player.x + self.player.width * CHARACTER_SCALE
        local queryY = self.player.y + self.player.height * CHARACTER_SCALE + 5
        if self.player.direction == 'left' then
            queryX = queryX - self.player.width * CHARACTER_SCALE
        
        elseif self.player.direction == 'right' then
            queryX = queryX + self.player.width * CHARACTER_SCALE
        
        elseif self.player.direction == 'up' then
            queryY = queryY - self.player.height * CHARACTER_SCALE
        
        elseif self.player.direction == 'down' then
            queryY = queryY + self.player.height * CHARACTER_SCALE
        end
        self.queryCircle = {x=queryX, y=queryY, radius = 8} --visualizing the queryCircle
        -- Check for interacting with a doorway
        local doorColliders = self.physicsWorld:queryCircleArea(queryX, queryY, 7, {'Doorway'})
        if #doorColliders > 0 then
            local doorway = doorColliders[1]:getObject()
            -- make sure the player is facing the proper direction to enter the door.
            if (self.player.direction == doorway.direction) and doorway.type == 'closed' then
                gSounds['door']:play()
                -- Remove the current FieldState from the StateStack.
                -- In the future, we could call some function here that saves game data.
                gStateStack:push(FadeInState( doorway.fadeColor, 0.5,
                    function()
                        -- Pop the current FieldState. This happens after FadeInState pops itself.
                        gStateStack:pop()
                        -- We need to know what game area to go to as well as what door the player
                        -- needs to appear from. This info is found in GAME_AREA_DEFS
                        local doorInfo = GAME_AREA_DEFS[self.gameArea.name].doorways[doorway.name]
                        gStateStack:push(FieldState(
                            doorInfo.area, doorInfo.otherDoor, self.player.direction)
                        )
                        gStateStack:push(FadeOutState( doorway.fadeColor, 0.5, function() end))
                    end
                ))
            end
        end
        -- Check for interacting with an entity
        local entityColliders = self.physicsWorld:queryCircleArea(queryX, queryY, 7, {'Entity'})
        if #entityColliders > 0 then
            local entity = entityColliders[1]:getObject()
            -- make the entity face the player
            if self.player.direction == 'left' then
                entity.direction = 'right'
            elseif self.player.direction == 'right' then
                entity.direction = 'left'
            elseif self.player.direction == 'up' then
                entity.direction = 'down'
            else
                entity.direction = 'up'
            end
            entity:changeState('idle')
            entity:onInteract()
        end
    end
    FieldState:updateCamera(self)
end

function FieldState:render()
    self.cam:attach()
        self.gameArea:render()
        for _, entity in pairs(self.entities) do
            entity:render()
        end
        self.player:render()
        self.physicsWorld:draw()
        if self.queryCircle then
            love.graphics.circle("line",self.queryCircle.x,self.queryCircle.y,self.queryCircle.radius)
        end

        if self.gameArea.map.layers['render-last'] then
            self.gameArea.map:drawLayer(self.gameArea.map.layers["render-last"])
        end

        --love.graphics.draw(gTextures['female-warrior'], gFrames['female-warrior'][1], 271, 344, 0, 0.7, 0.7)
    self.cam:detach()
    
    
   
    
end


function FieldState:generateEntities()
    self.physicsWorld:addCollisionClass('Entity')
    if self.gameArea.map.layers['entity-locations'] then
        for _, obj in pairs(self.gameArea.map.layers['entity-locations'].objects) do
            local entity = Entity(
                {animations = ENTITY_DEFS[obj.properties.entityName].animations,
                width = 16, height = 16, x = obj.x, y = obj.y,
                dialogueText = ENTITY_DEFS[obj.properties.entityName].dialogueText})

            entity.stateMachine = StateMachine {
                ['walk'] = function() return EntityWalkState(entity, self) end,
                ['idle'] = function() return EntityIdleState(entity) end
            }
            entity.stateMachine:change('idle')

            entity.collider = self.physicsWorld:newBSGRectangleCollider(
                entity.x + 6, entity.y + entity.height / 2, 11, 13, 9)
            entity.collider:setCollisionClass('Entity')
            entity.collider:setFixedRotation(true)
            -- Setting the entity's mass really high prevents the player from pushing the entity. 
            entity.collider:setMass(1000)
            -- Here we set the callback function that will be called when this entity collides
            -- with something, but before the collision response is actually calculated.
            entity.collider:setPreSolve(function(collider_1, collider_2, contact)
                if collider_1.collision_class == 'Player' and collider_2.collision_class == 'Entity' then
                    -- Setting the entity's velocity to zero just before the collision-calculation will make sure
                    -- that the entity does not push the player. Also, the entity conveniently stops moving.
                    collider_2:setLinearVelocity(0,0)
                    local obj = collider_2:getObject()
                    obj:changeState('idle')
                elseif collider_1.collision_class == 'Entity' and collider_2.collision_class == 'Player' then
                    collider_1:setLinearVelocity(0,0)
                    local obj = collider_1:getObject()
                    obj:changeState('idle')
                end
            end)
            -- By setting the entity object to its collider, we are able to retrieve the entity object
            -- later on whenever things happen to the collider in the the physicsWorld.
            entity.collider:setObject(entity)
            table.insert(self.entities, entity)
        end
    end

end

--
-- Even though this method is better suited to be private, the StateStack and StateMachine
-- are the only other classes where methods are called on a state. So I don't think it's a big deal.
--
function FieldState:updateCamera(self)
    -- We now need to make the camera track the player.
    local halfWindowWidth = love.graphics.getWidth() / 2
    local halfWindowHeight = love.graphics.getHeight() / 2
    -- Making the camera look at (love.graphics.getWidth() / 2, love.graphics.getHeight() / 2) will
    -- fix the camera in the top left of the screen. This is how the camera library is implemented. 
    -- The rest of the calculation will position the camera to have the player in the center.
    -- 11 is about the width and height of the player when the player sprite is scaled by 0.7.
    self.cam:lookAt(math.floor(halfWindowWidth + self.player.x - VIRTUAL_WIDTH / 2 + 11),
                   math.floor(halfWindowHeight + self.player.y - VIRTUAL_HEIGHT / 2 + 11))
    
    if not self.gameArea.showBlackSpace then
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

end