--[[
    My RPG Prototype

    Dylan Maurel
]]

-- To be used by BattleMessageState
CombatTextbox = Class{}

function CombatTextbox:init(text)
    self.width = math.floor(VIRTUAL_WIDTH / 2) - 1
    --self.height = math.floor(VIRTUAL_HEIGHT / 7)
    self.height = 26
    self.x = math.floor((VIRTUAL_WIDTH / 2) - (self.width / 2))
    self.y = 5

    self.text = text
    self.font = gFonts['small']
    _, self.textChunks = self.font:getWrap(self.text, self.width - 19)
    self.displayingChunks = {}
    
    -- This variable will be used to determine how many characters of the text
    -- need to be displayed in a given frame. (e.g., if the textPosition == 5, then only
    -- the first 5 characters of the string will be displayed.)
    -- This value is less than or equal to the sum of the lengths of each string in displayingChunks. 
    self.textPosition = 1
    self.timers = {}

    self.chunkCounter = 1
    self.endOfText = false
    self.closed = false

    self:next()
end

--[[
    Retrieves the text for the next page if there is any.
]]
function CombatTextbox:nextChunks()
    local chunks = {}

    for i = self.chunkCounter, self.chunkCounter + 1 do
        table.insert(chunks, self.textChunks[i])

        -- if we've reached the number of total chunks, we can return
        if i == #self.textChunks then
            self.endOfText = true
            return chunks
        end
        
    end

    self.chunkCounter = self.chunkCounter + 2

    return chunks
end

--[[
    Goes to the next page of text if there is any, otherwise toggles the textbox.
]]
function CombatTextbox:next()
    if self.endOfText then
        self.displayingChunks = {}
        self.closed = true
    else
        self.textPosition = 1 -- reset the text position
        self.displayingChunks = self:nextChunks()

        local numChars = 0
        -- define the speed with which the text should appear in the textbox.
        local charsPerSecond = 40
        for _, chunk in pairs(self.displayingChunks) do
            numChars = numChars + string.len(chunk)
        end
        -- Remember the lastCharPosition so that the user can end the tween and
        -- display all the text immediately, if they want to.
        self.lastCharPosition = numChars
        -- this is a variation of the forumula: time = distance / rate
        local tweenTime = numChars / charsPerSecond
        Timer.tween(tweenTime, {
            [self] = {textPosition = numChars}
        })
        :group(self.timers)
        
    end
end

function CombatTextbox:update(dt)
    if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        -- show the entire text if the user presses enter
        if self.textPosition < self.lastCharPosition then
            Timer.clear(self.timers)
            self.textPosition = self.lastCharPosition
        -- If the full text is showing and the textbox is triggerable, go to the next chunks of text
        elseif self.triggerable then
            self:next()
        end
    end
    Timer.update(dt, self.timers)
end

function CombatTextbox:isClosed()
    return self.closed
end

function CombatTextbox:render()
    love.graphics.setFont(self.font)
    -- print the transparent background for the text. Also print the line around the background.
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y),
        self.width, self.height, 3)
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.rectangle('line', math.floor(self.x - 1), math.floor(self.y - 1),
    self.width + 1, self.height + 1, 3)
    love.graphics.setColor(1, 1, 1, 1)
    
    -- Loop through each line of text that must be displayed. Print the text
    -- based on the current value of self.textPosition
    local charCounter = 0
    local lineStartPos = 0
    local roundedTextPos = math.floor(self.textPosition + 0.5)

    -- print the lines of text, gradually, according to the tweened text position.
    for i, chunk in ipairs(self.displayingChunks) do
        lineStartPos = charCounter -- start of the line
        charCounter = charCounter + string.len(chunk) -- end of the line
        if roundedTextPos < charCounter then
            love.graphics.print(string.sub(self.displayingChunks[i], 1, roundedTextPos - lineStartPos),
                self.x + 3, self.y + 3 + (i - 1) * 11)
            break
        else
            love.graphics.print(self.displayingChunks[i], self.x + 3, self.y + 3 + (i - 1) * 11)
        end
    end
end

function CombatTextbox:renderDownArrow(yOffset)
    local topY = self.y + self.height - 11 + yOffset
    local bottomY = self.y + self.height - 5 + yOffset

    love.graphics.polygon('fill', self.x + self.width - 14, topY,
        self.x + self.width - 6, topY, self.x + self.width - 10, bottomY)

end