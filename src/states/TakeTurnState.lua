--[[
    My RPG Prototype

    This class defines the behavior for a single round of a battle.
    In a single round, every entity takes their turn.

    Author: Dylan Maurel
]]

TakeTurnState = Class{__includes = BaseState}

function TakeTurnState:init(battleState)
    self.battleState = battleState
    -- :findTurn() has the side-effect of assigning values to self.isPlayerSide
    -- as well as self.attackEntity
    self:findTurn()
    self.turnFinished = false
    -- These are the lines that highlight the status box for the current entity's
    -- turn, if that entity is on the player's side.
    self.showStatusLines = false

    -- If the current turn belongs to an entity on the player's side,
    -- then we shift that entity forward and shift it's status box forward.
    if self.isPlayerSide == true then
        self:shiftEntityForTurn()
    end

end

function TakeTurnState:update(dt)
    self.battleState:update(dt)

     -- Check if all entities have played their turn for this round. If so, pop this state.
     if self.battleState.turnToTake > #self.battleState.turnOrder then
        -- prepare the BattleState for the next round of turns
        self.battleState.turnToTake = 1
        self.battleState.takingTurns = false
        gStateStack:pop()
    end

    if self.menu ~= nil then self.menu:update() end

    -- Check if the current turn is over for an entity.
    -- If so, determine the info for the next turn by calling :findTurn()
    if self.turnFinished == true then
        self:findTurn()
        -- If the current turn belongs to the player's side, then we call
        -- shiftEntityForTurn() in order to move the entity and its status box forward.
        if self.isPlayerSide == true then
            self:shiftEntityForTurn()
        else
            -- If the turn doesn't belong to the player's side, we don't need to show
            -- the status lines that highlight a player entity's status box.
            self.showStatusLines = false
            -- Make the enemy attack, but after waiting for a little bit.
            Timer.after(1, function() self:attack() end)
        end
        self.turnFinished = false
    end
end

function TakeTurnState:render()
    if self.menu ~= nil then
        self.menu:render()
        local panel = self.menu.panel
        love.graphics.rectangle('line', math.floor(panel.x - 1), math.floor(panel.y - 1),
            panel.width + 2, panel.height + 2)
    end
    if self.showStatusLines == true then
        local statusBox = self.battleState.statusBoxes[self.attackEntityIndex]
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle('fill', statusBox.x, statusBox.y - 1, statusBox.width, 1)
        love.graphics.rectangle('fill', statusBox.x, statusBox.y + statusBox.height, statusBox.width, 1)
    end
end

--
--
-- Helper Functions:
--
--

--
-- The menu will appear and disappear throughout the round, depending on
-- whose turn it is. So we have a function that will make create a menu
-- in front of the entity for the player's current turn.
--
function TakeTurnState:createMenu()
    self.menu = Menu({x=self.attackEntity.x - 52, y=self.attackEntity.y - 19,
    width=36, height=36, items = {
        [1] = {text = 'Fight', onSelect = function()
             self:attack()
             self.menu = nil
             end},
        [2] = {text = 'Item', onSelect = function() end},
        [3] = {text = 'Flee', onSelect = function() end}
    },
    frontColor = {r=0, g=0, b=0, a=0.5}, backColor = {r=0, g=0, b=0, a=0}
})
end

-- Determines who the attacker is for the current turn, and whether they are
-- on the player's side or the opponent's side. Doesn't return anything, but it
-- updates the self.attackEntity, self.isPlayerSide, and self.attackEntityIndex
function TakeTurnState:findTurn()
    local battState = self.battleState
    -- Find out who is attacking on this turn within the current round.
    local attackEntityIndex = battState.turnOrder[battState.turnToTake].index
    if battState.turnOrder[battState.turnToTake].playerSide == true then
        self.attackEntity = battState.playerParty[attackEntityIndex]
        self.isPlayerSide = true
    else
        self.attackEntity = battState.opponentParty[attackEntityIndex]
        self.isPlayerSide = false
    end
    --
    self.attackEntityIndex = attackEntityIndex
    --
end

--
-- Move's the attacking entity into attacking position, attacks, then returns the entity
-- to its regular standing position. When the attack is complete. We set the self.isTurnFinished
-- flag to true, and we increment self.turnToTake
--
function TakeTurnState:attack()
    local attackPos = {}
    -- Don't show an enemy's HP if they are currently attacking. It's looks less cluttered this way.
    if self.isPlayerSide == false then 
        self.attackEntity.showHP = false
        attackPos = {x = (VIRTUAL_WIDTH / 2) - 16, y = VIRTUAL_HEIGHT / 2}
    else
        attackPos = {x = (VIRTUAL_WIDTH / 2) + 16, y = VIRTUAL_HEIGHT / 2}
    end
    self.attackEntity:changeAnimation('run')


    --Move the entity to the middle of the screen, and perform the attack animation.
    Timer.tween(0.5, {
        [self.attackEntity] = {x = attackPos.x,
                             y = attackPos.y}
    })
    -- The following callback is called once the entity reaches the center of the screen
    :finish(function()
        -- Here is where you would change to the animation for the selected move
        if self.isPlayerSide == true then self.attackEntity:changeAnimation('attack1') else
        self.attackEntity:changeAnimation('attack')
        end
        -- You should tween for the move's duration, but moves aren't implemented yet.
        Timer.after(1, function()
            Timer.tween(0.3, {
                [self.attackEntity] = {x = self.attackEntity.standingX,
                                     y = self.attackEntity.standingY}
            })
            :finish(function() -- Is called after the entity returns to its original position
                if self.isPlayerSide == false then self.attackEntity.showHP = true
                else
                    Timer.tween(0.3, {[self.attackEntity] = {x = self.attackEntity.standingX}})
                    -- if the turn belonged to the player's side then we must return the
                    -- status box to it's original position
                    local statusBox = self.battleState.statusBoxes[self.attackEntityIndex]
                    Timer.tween(0.3, {
                        [statusBox] =  {x = statusBox.initialX}
                    })
                end    
                
                self.attackEntity:changeAnimation('idle')
                self.turnFinished = true
                -- update the turnToTake variable so that we can go to the next turn.
                self.battleState.turnToTake = self.battleState.turnToTake + 1
            end) 
            self.attackEntity:changeAnimation('run')
        end
        )
    end)

end

-- This function should be called if the current turn belongs to an entity
-- on the player's side.
-- We shift that entity forward and shift it's status box forward.
function TakeTurnState:shiftEntityForTurn()
    self.showStatusLines = true
    local statusBox = self.battleState.statusBoxes[self.attackEntityIndex]
    Timer.tween(0.3, {[self.attackEntity] = {x = self.attackEntity.x - 32}})
    Timer.tween(0.3, {
        [statusBox] =  {x = statusBox.x - 24}
    })
    :finish(function() self:createMenu() end)
end

