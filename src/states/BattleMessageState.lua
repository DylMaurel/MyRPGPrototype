--[[

]]

BattleMessageState = Class{__includes = BaseState}

function BattleMessageState:init(battleState, text, timeTillUpdateable, callback)
    self.battleState = battleState
    self.timeTillUpdateable = timeTillUpdateable
    self.updateable = false
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
    -- Exit this update method if not enough time has elapsed. Otherwise, continue execution.
    if self.elapsedTime < self.timeTillUpdateable then
        self.elapsedTime = self.elapsedTime + dt
        return
    end
    self.updateable = true
    self.combatTextbox:update(dt)

      -- Continually tween the down arrow's position up and down
      if self.tweenComplete == true then
        self.tweenComplete = false
        Timer.tween(1.5, {
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
    -- update the timer group for this state
    Timer.update(dt, self.timers)
    
    if self.combatTextbox:isClosed() then
            self.callback()
            self.battleState.battleMessageActive = false
            gStateStack:pop()
    end
 
end

function BattleMessageState:render()
    self.combatTextbox:render()
    if self.updateable == true then
    -- We floor the arrow's Yoffset on one end of the tween and ceil the Yoffset on
    -- the other end of the tween because it looks smoother this way.
        local yOffset = 0
        if self.tweenAmount < 0 then 
            yOffset = math.floor(self.arrowYOffset) 
        else
            yOffset = math.ceil(self.arrowYOffset)
        end
        self.combatTextbox:renderDownArrow(yOffset)
    end
end

