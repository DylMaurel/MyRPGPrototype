--[[
    My RPG Prototype

    Author: Dylan Maurel
]]

BattleState = Class{__includes = BaseState}

function BattleState:init(player)
    self.player = player
    self.playerParty = {
        [1] = CombatEntity (COMBAT_ENTITY_DEFS['player']),
        [2] = CombatEntity(COMBAT_ENTITY_DEFS['samurai'])
    }

    -- flag for when the battle can take input, set in the first update call
    self.battleStarted = false

    local enemies = {[1] = 'skeleton', [2] = 'goblin'}
    self.opponentParty = {}
    for i=1, math.random(4) do
        self.opponentParty[i] = CombatEntity(COMBAT_ENTITY_DEFS[enemies[math.random(2)]])
        self.opponentParty[i].showHP = true
    end

    self:calcEntityPositions(32, 16, VIRTUAL_WIDTH * 0.79, VIRTUAL_HEIGHT / 2, self.playerParty)
    self:calcEntityPositions(32, -16, VIRTUAL_WIDTH * 0.21, VIRTUAL_HEIGHT / 2, self.opponentParty)

    for _, entity in pairs(self.playerParty) do
        entity:changeAnimation('run')
        entity.x = VIRTUAL_WIDTH + 24 -- begin off screen
    end
    for _, entity in pairs(self.opponentParty) do
        entity:changeAnimation('run')
        entity.x = 0 - 24 -- begin off screen
    end

    self.turnOrder = {
        [1] = {playerSide = true, index=1},
        [2] = {playerSide = true, index=2},
    }
    for i, opp in pairs(self.opponentParty) do
        self.turnOrder[i + #self.playerParty] = {playerSide = false, index = i}
    end
    self.turnToTake = 1 -- an index into self.turnOrder that indicates whose turn it is.
    

    -- -- status gui element
    self.statusBoxes = {}
    for i=1, #self.playerParty do
        self.statusBoxes[i] = CombatStatus {
            x = VIRTUAL_WIDTH - 80,
            y = 5 + (i - 1) * 26,
            -- should update CombatEntity to include the entity's name
            entityName = i == 1 and 'Player' or 'Samurai',
            HP = self.playerParty[i].HP,
            currentHP = self.playerParty[i].currentHP
        }
    end

    self.highlightShader = self:createShader()
    -- flag for rendering health (and exp) bars, shown after the entities run in
    self.renderHUD = false
    self.takingTurns = false
    self.battleMessageActive = false
end

function BattleState:enter(params)
    
end

function BattleState:exit()
    -- gSounds['battle-music']:stop()
    -- gSounds['field-music']:play()
end

function BattleState:update(dt)
    -- this will trigger the first time this state is actively updating on the stack
    if not self.battleStarted then
        self:triggerSlideIn()
        Timer.after(1, function()
            -- After 1 second for the slideIn has passed:
            gStateStack:push(BattleMessageState(self, 'Wild enemies have appeared!'))
            self.battleMessageActive = true
            self.renderHUD = true
        end)
    end
    

    for _, entity in pairs(self.playerParty) do
        entity:update(dt)
    end
    for _, entity in pairs(self.opponentParty) do
        entity:update(dt)
    end
    for _, statusBox in pairs(self.statusBoxes) do
        statusBox:update(dt)
    end

    if self.battleMessageActive == true then return end

    if self.takingTurns == false and self.renderHUD == true then
        self.takingTurns = true
        gStateStack:push(TakeTurnState(self))
    end

end

function BattleState:render()
    love.graphics.draw(gTextures['combat-forest'],0,0, 0, 0.35,0.35)

    for _, entity in ipairs(self.playerParty) do
        if entity.isSelected == true then
            love.graphics.setShader(self.highlightShader)
            entity:render()
            love.graphics.setShader()
        else
        entity:render()
        end
    end
    for _, entity in ipairs(self.opponentParty) do
        if entity.isSelected == true then
            love.graphics.setShader(self.highlightShader)
            entity:render()
            love.graphics.setShader()
        else
        entity:render()
        end
    end

    if self.renderHUD then
        for _, status in pairs(self.statusBoxes) do
            status:render()
        end
        for _, enemy in pairs(self.opponentParty) do
            if enemy.showHP then
                love.graphics.setFont(gFonts['small'])
                love.graphics.print('HP: ' .. tostring(math.floor(enemy.currentHP)) .. '/' .. tostring(enemy.HP),
                    math.floor(enemy.x + 5), math.floor(enemy.y + 25))
            end
        end
    end
end

--
--
-- Helper Functions
--
--

-- 
-- Determines what the x and y of each entity should be. Just specify how much space
-- should be between each entity, and specify where the center of the entity line should be.
--
function BattleState:calcEntityPositions(vertSpacing, horizSpacing, middleX, middleY, party)
    
    local numPlayerParty = #party
    -- if we have an odd number of entities in the party, then
    if numPlayerParty % 2 == 1 then
        -- find the position for the topmost entity in the party
        party[1].y = middleY - ((numPlayerParty - 1) / 2) * vertSpacing
        party[1].x = middleX - ((numPlayerParty - 1) / 2) * horizSpacing
        party[1].standingX = party[1].x
        party[1].standingY = party[1].y
        if numPlayerParty > 1 then
            -- find the positions for the rest of the entities in the party
            for i=2, numPlayerParty do
                party[i].y = party[i-1].y + vertSpacing
                party[i].x = party[i-1].x + horizSpacing
                party[i].standingX = party[i].x -- Store these positions in a separate member
                party[i].standingY = party[i].y -- variable so that we can return back to them later.
            end
        end
    else -- we have an even number of entities in the party
        -- Find the position of the topmost entity
        party[1].y = middleY - (vertSpacing / 2) - ((numPlayerParty - 2) / 2) * vertSpacing
        party[1].x = middleX - (horizSpacing / 2) - ((numPlayerParty - 2) / 2) * horizSpacing
        party[1].standingX = party[1].x
        party[1].standingY = party[1].y
        for i = 2, numPlayerParty do
            -- Find the positions for the other entities--based on where the topmost entity is.
            party[i].y = party[i-1].y + vertSpacing
            party[i].x = party[i-1].x + horizSpacing
            party[i].standingX = party[i].x -- Store these positions in a separate member
            party[i].standingY = party[i].y -- variable so that we can return back to them later.
        end
    end
end

function BattleState:triggerSlideIn()
    self.battleStarted = true

    -- slide the sprites and circles in from the edges, then trigger first dialogue boxes
    for _, entity in pairs(self.opponentParty) do 
        Timer.tween(1, {
            [entity] = {x = entity.standingX}
        })
        :finish(function()
            entity:changeAnimation('idle')
        end)
    end
    for _, entity in pairs(self.playerParty) do 
        Timer.tween(1, {
            [entity] = {x = entity.standingX}
        })
        :finish(function()
            entity:changeAnimation('idle')
        end)
    end
end

--
-- Defines the shader that is used to highlight a selected sprite. The shader will
-- be applied whenever a sprite is being selected by a CombatSelection object.
--
function BattleState:createShader()
    local shaderCode = [[
        vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
            vec4 pixel = Texel(tex, texture_coords);
            vec4 brightnessScale = vec4(1.3, 1.3, 1.3, 1);
            pixel = pixel * brightnessScale;
            clamp(pixel, 0.0, 1.0);
            return pixel * color;
        }
    ]]
    
    return love.graphics.newShader(shaderCode)
end