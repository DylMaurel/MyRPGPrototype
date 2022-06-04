--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

BattleState = Class{__includes = BaseState}

function BattleState:init(player)
    self.player = player
    self.playerParty = {
        [1] = CombatEntity (COMBAT_ENTITY_DEFS['player']),
        [2] = CombatEntity(COMBAT_ENTITY_DEFS['samurai'])
    }
    --self.bottomPanel = Panel(0, VIRTUAL_HEIGHT - 64, VIRTUAL_WIDTH, 64)

    -- flag for when the battle can take input, set in the first update call
    self.battleStarted = false

    local enemies = {[1] = 'skeleton', [2] = 'goblin'}
    self.opponentParty = {}
    for i=1, math.random(4) do
        self.opponentParty[i] = CombatEntity(COMBAT_ENTITY_DEFS[enemies[math.random(2)]])
    end

    self:calcEntityPositions(32, 16, VIRTUAL_WIDTH * 0.75, VIRTUAL_HEIGHT / 2, self.playerParty)
    self:calcEntityPositions(32, -16, VIRTUAL_WIDTH * 0.25, VIRTUAL_HEIGHT / 2, self.opponentParty)

    for _, entity in pairs(self.playerParty) do
        entity:changeAnimation('idle')
        entity.x = entity.x + 150 -- begin off screen
    end
    for _, entity in pairs(self.opponentParty) do
        entity:changeAnimation('idle')
        entity.x = entity.x - 150 -- begin off screen
    end

    -- self.playerSprite = BattleSprite(self.player.party.pokemon[1].battleSpriteBack, 
    --     -64, VIRTUAL_HEIGHT - 128)
    -- self.opponentSprite = BattleSprite(self.opponent.party.pokemon[1].battleSpriteFront, 
    --     VIRTUAL_WIDTH, 8)

    -- -- health bars for pokemon
    -- self.playerHealthBar = ProgressBar {
    --     x = VIRTUAL_WIDTH - 160,
    --     y = VIRTUAL_HEIGHT - 80,
    --     width = 152,
    --     height = 6,
    --     color = {r = 189/255, g = 32/255, b = 32/255},
    --     value = self.player.party.pokemon[1].currentHP,
    --     max = self.player.party.pokemon[1].HP
    -- }

    -- self.opponentHealthBar = ProgressBar {
    --     x = 8,
    --     y = 8,
    --     width = 152,
    --     height = 6,
    --     color = {r = 189/255, g = 32/255, b = 32/255},
    --     value = self.opponent.party.pokemon[1].currentHP,
    --     max = self.opponent.party.pokemon[1].HP
    -- }

    -- -- exp bar for player
    -- self.playerExpBar = ProgressBar {
    --     x = VIRTUAL_WIDTH - 160,
    --     y = VIRTUAL_HEIGHT - 73,
    --     width = 152,
    --     height = 6,
    --     color = {r = 32/255, g = 32/255, b = 189/255},
    --     value = self.player.party.pokemon[1].currentExp,
    --     max = self.player.party.pokemon[1].expToLevel
    -- }

    -- -- flag for rendering health (and exp) bars, shown after pokemon slide in
    -- self.renderHealthBars = false

    -- -- circles underneath pokemon that will slide from sides at start
    -- self.playerCircleX = -68
    -- self.opponentCircleX = VIRTUAL_WIDTH + 32

    -- -- references to active pokemon
    -- self.playerPokemon = self.player.party.pokemon[1]
    -- self.opponentPokemon = self.opponent.party.pokemon[1]
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
    end

    for _, entity in pairs(self.playerParty) do
        entity:update(dt)
    end
    for _, entity in pairs(self.opponentParty) do
        entity:update(dt)
    end

    if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('enter') then
        gStateStack:push(FadeInState({r=1, g=1, b=1}, 0.5,
        function()
            gStateStack:pop()
            gStateStack:push(FadeOutState({r=1, g=1, b=1}, 0.5, function() end))
        end
    ))
    end
end

function BattleState:render()
    -- love.graphics.clear(214/255, 214/255, 214/255, 1)

    -- love.graphics.setColor(45/255, 184/255, 45/255, 124/255)
    -- love.graphics.ellipse('fill', self.opponentCircleX, 60, 72, 24)
    -- love.graphics.ellipse('fill', self.playerCircleX, VIRTUAL_HEIGHT - 64, 72, 24)

    -- love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(gTextures['combat-forest'],0,0, 0, 0.35,0.35)

    for _, entity in ipairs(self.playerParty) do
        -- add the shadows to the combat entity class instead of coding the shadows here.
        love.graphics.setColor(20/255, 20/255, 80/255, 180/255)
        love.graphics.ellipse('fill', entity.x, entity.y + 18, 12, 6)
         love.graphics.setColor(1, 1, 1, 1)
        entity:render()
    end
    for _, entity in ipairs(self.opponentParty) do
        love.graphics.setColor(20/255, 20/255, 80/255, 180/255)
        love.graphics.ellipse('fill', entity.x, entity.y + 25, 12, 8)
        love.graphics.setColor(1, 1, 1, 1)
        entity:render()
    end

    -- if self.renderHealthBars then
    --     self.playerHealthBar:render()
    --     self.opponentHealthBar:render()
    --     self.playerExpBar:render()

    --     -- render level text
    --     love.graphics.setColor(0, 0, 0, 1)
    --     love.graphics.setFont(gFonts['small'])
    --     love.graphics.print('LV ' .. tostring(self.playerPokemon.level),
    --         self.playerHealthBar.x, self.playerHealthBar.y - 10)
    --     love.graphics.print('LV ' .. tostring(self.opponentPokemon.level),
    --         self.opponentHealthBar.x, self.opponentHealthBar.y + 8)
    --     love.graphics.setFont(gFonts['medium'])
    --     love.graphics.setColor(1, 1, 1, 1)
    -- end

    -- self.bottomPanel:render()
end


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
        end)
    end
    for _, entity in pairs(self.playerParty) do 
        Timer.tween(1, {
            [entity] = {x = entity.standingX}
        })
        :finish(function()
            -- self:triggerStartingDialogue()
            -- self.renderHealthBars = true
        end)
    end
end

function BattleState:triggerStartingDialogue()
    
    -- display a dialogue first for the pokemon that appeared, then the one being sent out
    gStateStack:push(BattleMessageState('A wild ' .. tostring(self.opponent.party.pokemon[1].name ..
        ' appeared!'),
    
    -- callback for when the battle message is closed
    function()
        gStateStack:push(BattleMessageState('Go, ' .. tostring(self.player.party.pokemon[1].name .. '!'),
    
        -- push a battle menu onto the stack that has access to the battle state
        function()
            gStateStack:push(BattleMenuState(self))
        end))
    end))
end