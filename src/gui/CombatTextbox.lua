--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Edited by: Dylan Maurel
]]

-- To be used by BattleMessageState
CombatTextbox = Class{}

function CombatTextbox:init(text)
    self.width = math.floor(VIRTUAL_WIDTH / 2)
    --self.height = math.floor(VIRTUAL_HEIGHT / 7)
    self.height = 26
    self.x = math.floor((VIRTUAL_WIDTH / 2) - (self.width / 2))
    self.y = 5

    self.text = text
    self.font = gFonts['small']
    _, self.textChunks = self.font:getWrap(self.text, self.width - 19)

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
        self.displayingChunks = self:nextChunks()
    end
end

function CombatTextbox:update(dt)
    if love.keyboard.wasPressed('space') or love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        self:next()
    end
end

function CombatTextbox:isClosed()
    return self.closed
end

function CombatTextbox:render()
    
    love.graphics.setFont(self.font)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y),
        self.width, self.height, 3)
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.rectangle('line', math.floor(self.x - 1), math.floor(self.y - 1),
    self.width + 1, self.height + 1, 3)
    love.graphics.setColor(1, 1, 1, 1)
    

    for i = 1, #self.displayingChunks do
        love.graphics.print(self.displayingChunks[i], self.x + 3, self.y + 3 + (i - 1) * 11)
    end
end

function CombatTextbox:renderDownArrow(yOffset)
    local topY = self.y + self.height - 11 + yOffset
    local bottomY = self.y + self.height - 5 + yOffset

    love.graphics.polygon('fill', self.x + self.width - 14, topY,
        self.x + self.width - 6, topY, self.x + self.width - 10, bottomY)

end