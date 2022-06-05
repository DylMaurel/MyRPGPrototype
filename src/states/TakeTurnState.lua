--[[
    My RPG Prototype

    Author: Dylan Maurel
]]

TakeTurnState = Class{__includes = BaseState}

function TakeTurnState:init(battleState)
    self.battleState = battleState
end

function TakeTurnState:update(dt)
    self.battleState:update(dt)

    if love.keyboard.wasPressed('P') or love.keyboard.wasPressed('p') then
        self:attack()
        -- increment the index for the turnOrder table, so that the next entity can attack.
        self.battleState.turnToTake = self.battleState.turnToTake + 1
    end

    -- Check if all entities have played their turn for this round. If so, pop this state.
    if self.battleState.turnToTake > #self.battleState.turnOrder then
        -- set the turn order for the next round
        self.battleState.turnToTake = 1
        self.battleState.takingTurns = false
        gStateStack:pop()
    end
end

function TakeTurnState:render()
end

function TakeTurnState:attack()
    local battState = self.battleState
    local attackingEntity = nil
    local isPlayerSide = nil

    -- Find out who is attacking on this turn within the current round.
    local attackingEntityIndex = battState.turnOrder[battState.turnToTake].index
    if battState.turnOrder[battState.turnToTake].playerSide == true then
        attackingEntity = battState.playerParty[attackingEntityIndex]
        isPlayerSide = true
    else
        attackingEntity = battState.opponentParty[attackingEntityIndex]
        isPlayerSide = false
    end
    --
    -- Should probably move the above code into the update function.
    -- Then just pass in the attackEntity and targetEntity as parameters to :attack().
    -- I think that would make it easier when you have to show a battle menu for the player.
    --

    -- Don't show an enemy's HP if they are currently attacking. It's looks less cluttered this way.
    if isPlayerSide == false then attackingEntity.showHP = false end
    attackingEntity:changeAnimation('run')

    --Move the entity to the middle of the screen, and perform the attack animation.
    Timer.tween(0.5, {
        [attackingEntity] = {x = VIRTUAL_WIDTH / 2,
                             y = VIRTUAL_HEIGHT / 2}
    })
    -- The following callback is called once the entity reaches the center of the screen
    :finish(function()
        -- Here is where you would change to the animation for the selected move
        if isPlayerSide == true then attackingEntity:changeAnimation('attack1') else
        attackingEntity:changeAnimation('attack')
        end
        -- You should tween for the move's duration, but moves aren't implemented yet.
        Timer.after(1, function()
            Timer.tween(0.3, {
                [attackingEntity] = {x = attackingEntity.standingX,
                                     y = attackingEntity.standingY}
            })
            :finish(function() -- Is called after the entity returns to its original position
                if isPlayerSide == false then attackingEntity.showHP = true end
                attackingEntity:changeAnimation('idle')
            end) 
            attackingEntity:changeAnimation('run')
        end
        )
    end)

end

