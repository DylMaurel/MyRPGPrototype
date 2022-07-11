--[[
    My RPG Prototype

    This class defines the behavior for a single round of a battle.
    In a single round, every entity takes their turn.

    Author: Dylan Maurel
]]

TakeTurnState = Class{__includes = BaseState}

function TakeTurnState:init(battleState)
    self.battleState = battleState
    -- :findNextTurn() has the side-effect of assigning values to self.isPlayerSide
    -- as well as self.attackEntity
    self:findNextTurn()
    self.turnFinished = false
    -- These are the lines that highlight the status box for the current entity's
    -- turn, if that entity is on the player's side.
    self.showStatusLines = false

    -- If the current turn belongs to an entity on the player's side,
    -- then we shift that entity forward and shift it's status box forward.
    if self.isPlayerSide == true then
        self:shiftEntityForTurn()
    end

    if self:checkVictory() then
        gSounds['door']:play()
        TakeTurnState:newBattle()
    end
    if self:checkDefeat() then
        gSounds['sword']:play()
        TakeTurnState:newBattle()
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
        return
    end

    if self.combatSelection ~= nil then self.combatSelection:update(dt) end
    if self.menu ~= nil then self.menu:update(dt) end

    -- Check if the current turn is over for an entity.
    -- If so, determine the info for the next turn by calling :findNextTurn()
    if self.turnFinished == true then
        -- If there is a turn remaining in the round, then :findNextTurn() updates the turn info
        -- and has returns true. If a turn doesn't exist (because of dead entities), then
        -- calling :findNextTurn would return false.
        if self:findNextTurn() == false then return end
        -- If the current turn belongs to the player's side, then we call
        -- shiftEntityForTurn() in order to move the entity and its status box forward.
        if self.isPlayerSide == true then
            self:shiftEntityForTurn()
        else
            -- If the turn doesn't belong to the player's side, we don't need to show
            -- the status lines that highlight a player entity's status box.
            self.showStatusLines = false
            -- Make the enemy attack, but after waiting for a little bit.
            Timer.after(1, function() 
                local playerParty = self.battleState.playerParty
                local aliveEntityIndices = {}
                for i, entity in ipairs(playerParty) do
                    if entity.isDead == false then
                        table.insert(aliveEntityIndices, i)
                    end
                end
                local opponentIndex = aliveEntityIndices[math.random(#aliveEntityIndices)]
                self:attack(playerParty[opponentIndex], opponentIndex) 
            end)
        end
        self.turnFinished = false
    end

end

function TakeTurnState:render()
    if self.menu ~= nil then
        self.menu:render()
    end
    if self.combatSelection ~= nil then self.combatSelection:render() end
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

function TakeTurnState:newBattle()
    gStateStack:push(FadeInState({r=1, g=1, b=1}, 0.5,
            function()
                gStateStack:pop() -- pop this TakeTurnState
                gStateStack:pop() --  pop the underlying BattleState
                gStateStack:push(BattleState()) -- For testing, push a new battleState
                gStateStack:push(FadeOutState({r=1, g=1, b=1}, 0.5, function() end))
            end))

end
function TakeTurnState:checkVictory()
    for i, entity in pairs(self.battleState.opponentParty) do
        if entity.currentHP ~= 0 then
            return false
        end
    end
    return true
end
function TakeTurnState:checkDefeat()
    for i, entity in pairs(self.battleState.playerParty) do
        if entity.currentHP ~= 0 then
            return false
        end
    end
    return true
end



-- The menu will appear and disappear throughout the round, depending on
-- whose turn it is. So we have a function that will make create a menu
-- in front of the entity whose turn it is.
function TakeTurnState:createMenu()
    local itemsForFightSelection = {}

    local selectionIndex = 1
    for i, enemy in ipairs(self.battleState.opponentParty) do
        if enemy.isDead == false then
            itemsForFightSelection[selectionIndex] = {entity = enemy, onSelect = 
                function()
                    self:attack(enemy, i)
                    self.combatSelection = nil
                end}
            selectionIndex = selectionIndex + 1
        end
    end

    self.menu = Menu({x=self.attackEntity.x - 53, y=self.attackEntity.y - 19,
    width=36, height=36, items = {
        [1] = {text = 'Fight', onSelect = function()
             self.combatSelection = CombatSelection(itemsForFightSelection)
             self.menu = nil
             end},
        [2] = {text = 'Item', onSelect = function() end},
        [3] = {text = 'Flee', onSelect = function() TakeTurnState:newBattle() end}
    },
    frontColor = {r=0, g=0, b=0, a=0.5}, backColor = {r=1, g=1, b=1, a=0.9}
    })
end

--    Determines who the attacker is for the current turn, and whether they are
-- on the player's side or the opponent's side. This method has the side effect of
-- updating self.attackEntity, self.isPlayerSide, and self.attackEntityIndex.
--    If there are entities in the battle that are dead, then we want to skip their turn.
-- But also, there is a chance that no turns are remaining, because the last entities in 
-- the turn order are dead. So, we return true if a turn exists, and false otherwise.
function TakeTurnState:findNextTurn()
    local battState = self.battleState
    if battState.turnToTake > #battState.turnOrder then return false end

    -- Find out who is attacking on this turn within the current round.
    local attackEntityIndex = battState.turnOrder[battState.turnToTake].index
    if battState.turnOrder[battState.turnToTake].playerSide == true then
        local entity = battState.playerParty[attackEntityIndex]
        if entity.isDead == false then
            self.attackEntity = battState.playerParty[attackEntityIndex]
            self.isPlayerSide = true
        else
            battState.turnToTake = battState.turnToTake + 1
            return self:findNextTurn()
        end
    else
        local entity = battState.opponentParty[attackEntityIndex]
        if entity.isDead == false then
            self.attackEntity = battState.opponentParty[attackEntityIndex]
            self.isPlayerSide = false
        else
            -- entity is dead. So call :findNextTurn() again for the next entity in the turn order
            battState.turnToTake = battState.turnToTake + 1
            return self:findNextTurn()
        end
    end
    self.attackEntityIndex = attackEntityIndex
    return true
end

--
-- Move's the attacking entity into attacking position, attacks, then returns the entity
-- to its regular standing position. When the attack is complete. We set the self.isTurnFinished
-- flag to true, and we increment self.turnToTake
--
function TakeTurnState:attack(targetEntity, targetEntityIndex)
    -- determine where the entity must stand in order to attack. Player-side and enemy-side have different attack positions.
    local attackPos = {}
    if self.isPlayerSide == false then 
        -- Don't show an enemy's HP if they are currently attacking. It's looks less cluttered this way.
        self.attackEntity.showHP = false
        attackPos = {x = (VIRTUAL_WIDTH / 2) - 16, y = VIRTUAL_HEIGHT / 2}
    else
        attackPos = {x = (VIRTUAL_WIDTH / 2) + 16, y = VIRTUAL_HEIGHT / 2}
    end
    self.attackEntity:changeAnimation('run')

    -- Calculate the times of the various animations before we do anything. This way we can schedule
    -- the events properly.
    -- We currently hard code the chosen move because moves aren't implemented yet.
    local moveName = self.isPlayerSide and 'attack1' or 'attack'
    local moveDuration = self.attackEntity:animationDuration(moveName)
    local hitAnimDuration = targetEntity:animationDuration('take-hit')
    -- Calculate the damage taken beforehand, so that we know if a death animation needs to occur.
    -- Then, we also know exactly how much time the attack and its resulting animations will take.
    -- And because of this, we can determine exactly when we need to go to the next turn.
    local dmg = math.floor(math.max(1, (self.attackEntity.currentAttack * 1.5) -  targetEntity.currentDefense))
    local computedHP = math.max(0, targetEntity.currentHP - dmg)
    local willFaint = computedHP <= 0 and true or false
    local faintAnimTime = 0 -- default is that there is no faintAnimation, so it doesn't take any time.
    if willFaint then faintAnimTime = targetEntity:animationDuration('dying') end

    --Move the entity to the middle of the screen
    Timer.tween(0.5, {
        [self.attackEntity] = {x = attackPos.x,
                             y = attackPos.y}
    })
    :finish(function() self.attackEntity:changeAnimation('idle') end)

    -- Make the attacking entity stand idle in the attack position for 0.25 seconds before
    -- they start their attack animation (0.5 sec for moving to the attack position + 0.25sec = 0.75sec).
    -- Then, Begin the attack animation for the selected move.
    Timer.after(0.75, function() 
        self.attackEntity:changeAnimation(moveName)
        -- Make the target of the attack go through a take-hit animation during the attack.
        Timer.after(moveDuration * 0.75, function()
            targetEntity:changeAnimation('take-hit')
            Timer.after(hitAnimDuration, function() targetEntity:changeAnimation('idle') end)
        end)
        -- After the attack animation is complete, push a BattleMessageState to indicate how much damage was dealt
        -- Also, tween any health information and make the target faint if necessary.
        Timer.after(moveDuration, function()
            self.attackEntity:changeAnimation('idle')
            -- We create a callback function that will be called when the BattleMessageState is closed.
            -- However, there are two different outcomes that must be considered:
            -- 1. The target faints  ,  2. The target doesn't faint.
            -- We make callbacks for both possibilities, but only one of them is passed into the BattleMessageState.
            local afterDamagedNoFaint = function() 
                self:endAttack()
            end
            local afterDamagedWithFaint = function()
                -- create a callback to be called once the faint message has been exited.
                local afterFaint = function()
                    if self:checkVictory() then
                        gStateStack:push(BattleMessageState(self.battleState, 'Victory!', 0,
                        function()
                            self:newBattle()
                        end))
                        return
                    end
                    if self:checkDefeat() then
                        gStateStack:push(BattleMessageState(self.battleState, 'Defeat!', 0,
                        function()
                            self:newBattle()
                        end))
                        return
                    end
                    self:endAttack()
                end
                self:faint(targetEntity, afterFaint)
            end
            
            local battleMessageCallback = willFaint and afterDamagedWithFaint or afterDamagedNoFaint
            
            -- push a BattleMessageState to tell how much damage was dealt. The third parameter to the new state ensures
            -- that the BattleMessageState cannot be exited until 1 second for the upcoming damage tween has passed.
            -- Although we are pushing a new state onto the StateStack, the BattleMessageState will update
            -- the underlying BattleState so that entities continue their idle animations.
            -- Furthermore, the Timers that have been created here will continue to update even if the TakeTurnState
            -- is no longer updating. This is because we are creating timers that belong to the default timer group, which
            -- is updated in main.lua
            gStateStack:push(BattleMessageState(self.battleState,
                'The attacker dealt ' .. tostring(targetEntity.currentHP - computedHP) .. ' damage.', 1
                , battleMessageCallback))

             -- Damage the target entity, and tween any necessary hp information.
            if targetEntity.isEnemy == true then
                Timer.tween(1, {[targetEntity] = {currentHP = computedHP}})
            else
                targetEntity.currentHP = computedHP
                local targetHealthBar = self.battleState.statusBoxes[targetEntityIndex].healthBar
                Timer.tween(1, {[targetHealthBar] = {value = targetEntity.currentHP}})
            end
        end)
    end)
end


function TakeTurnState:faint(entity, callback)
    entity.isDead = true
    entity:changeAnimation('dying')
    local dieDuration = entity:animationDuration('dying')
    Timer.after(dieDuration - 0.05, function() entity:changeAnimation('dead') end)
    gStateStack:push(BattleMessageState(self.battleState, 'The entity fainted!', dieDuration, callback))
end


function TakeTurnState:endAttack()
    self.attackEntity:changeAnimation('run')
    Timer.tween(0.3, {
        [self.attackEntity] = {x = self.attackEntity.standingX,
                               y = self.attackEntity.standingY}
    })
    :finish(function() -- Is called after the entity returns to its original position
        if self.isPlayerSide == false then self.attackEntity.showHP = true
        else
            -- if the turn belonged to the player's side then we must return the
            -- status box to it's original position
            local statusBox = self.battleState.statusBoxes[self.attackEntityIndex]
            Timer.tween(0.3, {
                [statusBox] =  {x = statusBox.initialX}
            })
        end    
        self.attackEntity:changeAnimation('idle')
        -- Signal that the current turn is complete
        self.turnFinished = true
        -- update the turnToTake variable so that we can go to the next turn.
        self.battleState.turnToTake = self.battleState.turnToTake + 1
    end)
end

-- This function should be called if the current turn belongs to an entity
-- on the player's side.
-- We shift that entity forward and shift it's status box forward.
function TakeTurnState:shiftEntityForTurn()
    self.showStatusLines = true
    local statusBox = self.battleState.statusBoxes[self.attackEntityIndex]
    Timer.tween(0.3, {[self.attackEntity] = {x = self.attackEntity.x - 32}})
    Timer.tween(0.3, { [statusBox] =  {x = statusBox.x - 14} })
    :finish(function() self:createMenu() end)
end

