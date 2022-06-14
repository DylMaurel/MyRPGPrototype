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
    -- If so, determine the info for the next turn by calling :findTurn()
    if self.turnFinished == true then
        -- check victory
        if self:checkVictory() then
            gSounds['door']:play()
            TakeTurnState:newBattle()
        end
        if self:checkDefeat() then
            gSounds['sword']:play()
            TakeTurnState:newBattle()
        end
        -- check defeat


        -- If there is a turn remaining in the round, then :findTurn() updates the turn info
        -- and has returns true. If a turn doesn't exist (because of dead entities), then
        -- calling :findTurn would return false.
        if self:findTurn() == false then return end
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
        local panel = self.menu.panel
        love.graphics.rectangle('line', math.floor(panel.x - 1), math.floor(panel.y - 1),
            panel.width + 2, panel.height + 2)
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

    self.menu = Menu({x=self.attackEntity.x - 52, y=self.attackEntity.y - 19,
    width=36, height=36, items = {
        [1] = {text = 'Fight', onSelect = function()
             self.combatSelection = CombatSelection(itemsForFightSelection)
             self.menu = nil
             end},
        [2] = {text = 'Item', onSelect = function() end},
        [3] = {text = 'Flee', onSelect = function() TakeTurnState:newBattle() end}
    },
    frontColor = {r=0, g=0, b=0, a=0.5}, backColor = {r=0, g=0, b=0, a=0}
})
end

--    Determines who the attacker is for the current turn, and whether they are
-- on the player's side or the opponent's side. This method has the side effect of
-- updating self.attackEntity, self.isPlayerSide, and self.attackEntityIndex.
--    If there are entities in the battle that are dead, then we want to skip their turn.
-- But also, there is a chance that no turns are remaining, because the last entities in 
-- the turn order are dead. So, we return true if a turn exists, and false otherwise.
function TakeTurnState:findTurn()
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
            return self:findTurn()
        end
    else
        local entity = battState.opponentParty[attackEntityIndex]
        if entity.isDead == false then
            self.attackEntity = battState.opponentParty[attackEntityIndex]
            self.isPlayerSide = false
        else
            -- entity is dead. So call :findTurn() again for the next entity in the turn order
            battState.turnToTake = battState.turnToTake + 1
            return self:findTurn()
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
    local attackPos = {}
    -- Don't show an enemy's HP if they are currently attacking. It's looks less cluttered this way.
    if self.isPlayerSide == false then 
        self.attackEntity.showHP = false
        attackPos = {x = (VIRTUAL_WIDTH / 2) - 16, y = VIRTUAL_HEIGHT / 2}
    else
        attackPos = {x = (VIRTUAL_WIDTH / 2) + 16, y = VIRTUAL_HEIGHT / 2}
    end
    self.attackEntity:changeAnimation('run')


    --Move the entity to the middle of the screen
    Timer.tween(0.5, {
        [self.attackEntity] = {x = attackPos.x,
                             y = attackPos.y}
    })
    :finish(function() self.attackEntity:changeAnimation('idle') end)


    -- 0.75 - 0.5 = 0.25, which is the amount of time the entity stands idle in the 
    -- attack position, before they start their attack animation.
    Timer.after(0.75, function() 
        -- Here is where you would change to the animation for the selected move
        if self.isPlayerSide == true then self.attackEntity:changeAnimation('attack1') else
        self.attackEntity:changeAnimation('attack')
        end
        local moveDuration = self.attackEntity:animationPlayTime()

        -- Make the target of the attack go through a take-hit animation, get damaged,
        -- then return to idle animation or go through dying animation.
        Timer.after(moveDuration * 0.75, function()
            targetEntity:changeAnimation('take-hit')
            local hitAnimDuration = targetEntity:animationPlayTime()
            Timer.after(hitAnimDuration, function() targetEntity:changeAnimation('idle') end)
            -- Damage the target entity
            local dmg = math.floor(math.max(1, (self.attackEntity.currentAttack * 1.5) -  targetEntity.currentDefense))
            local computedHP = targetEntity.currentHP - dmg

            local checkDeath = function()
                if targetEntity.currentHP == 0 then
                    self:faint(targetEntity)
                end
            end
            if targetEntity.isEnemy == true then
                Timer.tween(1, {[targetEntity] = {currentHP = math.max(0, computedHP)}})
                :finish(checkDeath)
            else
                targetEntity.currentHP = math.max(0, computedHP)
                local targetHealthBar = self.battleState.statusBoxes[targetEntityIndex].healthBar
                Timer.tween(1, {[targetHealthBar] = {value = targetEntity.currentHP}})
                :finish(checkDeath)
            end
        end)

        -- Wait for the move animation to complete, then begin tween to original position, and change
        -- the entity'es animation to 'run'
        Timer.after(moveDuration, function()
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
            end) 
            self.attackEntity:changeAnimation('run')
        end)
        -- Wait until all events for the round should be complete, then...
        Timer.after((moveDuration) + 1, function()
             -- Signal that the current turn is complete
             self.turnFinished = true
             -- update the turnToTake variable so that we can go to the next turn.
             self.battleState.turnToTake = self.battleState.turnToTake + 1
        end)
    end)

end


function TakeTurnState:faint(entity)
    entity.isDead = true
    entity:changeAnimation('dying')
    local dieDuration = entity:animationPlayTime()
    Timer.after(dieDuration - 0.05, function() entity:changeAnimation('dead') end)
end

-- This function should be called if the current turn belongs to an entity
-- on the player's side.
-- We shift that entity forward and shift it's status box forward.
function TakeTurnState:shiftEntityForTurn()
    self.showStatusLines = true
    local statusBox = self.battleState.statusBoxes[self.attackEntityIndex]
    Timer.tween(0.3, {[self.attackEntity] = {x = self.attackEntity.x - 32}})
    Timer.tween(0.3, { [statusBox] =  {x = statusBox.x - 24} })
    :finish(function() self:createMenu() end)
end

