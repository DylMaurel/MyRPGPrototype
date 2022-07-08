
CombatSelection = Class{}

function CombatSelection:init(def)
    --[[
        def.items must be in the form:
        items = {[1] = {entity = someEntity, onSelect = someFunction},
                [2] = ...
                }
    ]]
    self.items = def
   
    -- Flag for how to render the cursor.
    self.flipped = self.items[1].entity.isEnemy

    -- create a timer group for this specific object.
    self.timers = {}
    if self.flipped == true then
        self.xOffset = 36
    else
        self.xOffset = -24
    end
    self.tweenAmount = 4
    self.tweenComplete = true

    self.font = def.font or gFonts['small']
    self.currentSelection = 1
    self.items[1].entity.isSelected = true
end

function CombatSelection:update(dt)
    -- Make the cursor continually move left and right
    if self.tweenComplete == true then
        self.tweenComplete = false
        Timer.tween(0.8, {
            [self] = {xOffset = self.xOffset + self.tweenAmount}
        })
        :group(self.timers)
        :ease(inOutEase)
        :finish(function()
                -- set things up for the next tween, in the opposite direction
                self.tweenComplete = true
                self.tweenAmount = -self.tweenAmount
        end)
    end


    Timer.update(dt, self.timers)

    if love.keyboard.wasPressed('up') then
        self:entitySelected(false)
        if self.currentSelection == 1 then
            self.currentSelection = #self.items
        else
            self.currentSelection = self.currentSelection - 1
        end
        self:entitySelected(true)
        
        -- gSounds['blip']:stop()
        -- gSounds['blip']:play()
    elseif love.keyboard.wasPressed('down') then
        self:entitySelected(false)
        if self.currentSelection == #self.items then
            self.currentSelection = 1
        else
            self.currentSelection = self.currentSelection + 1
        end
        self:entitySelected(true)
    
        -- gSounds['blip']:stop()
        -- gSounds['blip']:play()
    elseif love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        self:entitySelected(false)
        self.items[self.currentSelection].onSelect()
        
        -- gSounds['blip']:stop()
        -- gSounds['blip']:play()
    end
end

function CombatSelection:render()
    local currentY = self.items[self.currentSelection].entity.y
    local currentX = self.items[self.currentSelection].entity.x

    if self.flipped == true then
        love.graphics.draw(gTextures['cursor'], math.floor(currentX + self.xOffset), math.floor(currentY), 0, -1, 1)
    else
        love.graphics.draw(gTextures['cursor'], math.floor(currentX + self.xOffset), math.floor(currentY))
    end
end

function CombatSelection:entitySelected(boolValue)
    self.items[self.currentSelection].entity.isSelected = boolValue
end