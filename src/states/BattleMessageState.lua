--[[

]]

BattleMessageState = Class{__includes = BaseState}

function BattleMessageState:init(battleState, text, timeTillTrigger, callback)
    self.battleState = battleState
    self.battleState.battleMessageActive = true
    self.timeTillTrigger = timeTillTrigger or 0
    self.triggerable = false
    self.elapsedTime = 0
    self.text = text
    self.combatTextbox = CombatTextbox(text)
    self.callback = callback or function() end

    -- make a specific timer group for this state
    self.timers = {}
    -- Instantiate variables to control the down arrow
    self.tweenAmount = 2
    self.arrowYOffset = 0
    self.tweenComplete = true

    
end

function BattleMessageState:update(dt)
    self.battleState:update(dt)
    self.combatTextbox:update(dt)
    -- Exit this update method if not enough time has elapsed. Otherwise, continue execution.
    if self.elapsedTime < self.timeTillTrigger then
        self.elapsedTime = self.elapsedTime + dt
        return
    end
    self.triggerable = true
    self.combatTextbox.triggerable = true

    -- Continually tween the down arrow's position up and down
    if self.tweenComplete == true then
        self.tweenComplete = false
        Timer.tween(1.75, {
            [self] = {arrowYOffset = self.arrowYOffset + self.tweenAmount}
        })
        :group(self.timers)
        :ease(inOutEase)
        :finish(function()
                -- set things up for the next tween, in the opposite direction
                self.tweenComplete = true
                self.tweenAmount = -self.tweenAmount
        end)
    end
    -- update the timer group for this class
    Timer.update(dt, self.timers)
    
    if self.combatTextbox:isClosed() then
            self.battleState.battleMessageActive = false
            gStateStack:pop()
            self.callback()
    end
 
end

function BattleMessageState:render()
    self.combatTextbox:render()
    if self.triggerable == true and self.combatTextbox.textPosition == self.combatTextbox.lastCharPosition then
        -- round the arrowYOffset to the nearest integer
        self.combatTextbox:renderDownArrow(math.floor(self.arrowYOffset + 0.5))
    end
end

