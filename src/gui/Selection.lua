--[[

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Selection class gives us a list of textual items that link to callbacks;
    this particular implementation only has one dimension of items (vertically),
    but a more robust implementation might include columns as well for a more
    grid-like selection, as seen in many kinds of interfaces and games.

    Edited by: Dylan Maurel
    Reason for edit: Make the cursor continually move left and right.

]]

Selection = Class{}

function Selection:init(def)
    self.items = def.items
    self.x = def.x
    self.y = def.y

    self.height = def.height
    self.width = def.width
    self.font = def.font or gFonts['small']

    self.gapHeight = self.height / #self.items

    self.currentSelection = 1

    -- variables for continually tweening the cursor left and right
    self.timers = {}
    self.xOffset = 10
    self.tweenAmount = 2
    self.tweenComplete = true
end

function Selection:update(dt)
      -- Make the cursor continually move left and right
      if self.tweenComplete == true then
        self.tweenComplete = false
        Timer.tween(1.75, {
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
        if self.currentSelection == 1 then
            self.currentSelection = #self.items
        else
            self.currentSelection = self.currentSelection - 1
        end
        
        -- gSounds['blip']:stop()
        -- gSounds['blip']:play()
    elseif love.keyboard.wasPressed('down') then
        if self.currentSelection == #self.items then
            self.currentSelection = 1
        else
            self.currentSelection = self.currentSelection + 1
        end
        
        -- gSounds['blip']:stop()
        -- gSounds['blip']:play()
    elseif love.keyboard.wasPressed('return') or love.keyboard.wasPressed('enter') then
        self.items[self.currentSelection].onSelect()
        
        -- gSounds['blip']:stop()
        -- gSounds['blip']:play()
    end
end

function Selection:render()
    local currentY = self.y
    local roundedXOffset = math.floor(self.xOffset + 0.5)

    for i = 1, #self.items do
        local paddedY = currentY + (self.gapHeight / 2) - self.font:getHeight() / 2

        -- draw selection marker if we're at the right index
        if i == self.currentSelection then
            love.graphics.draw(gTextures['cursor'], self.x - roundedXOffset, math.floor(paddedY) - 1)
        end

        love.graphics.printf(self.items[i].text, math.floor(self.x),
             math.floor(paddedY), self.width, 'center')

        currentY = currentY + self.gapHeight
    end
end