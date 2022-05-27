--[[
    GD50
    Pokemon

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

DialogueState = Class{__includes = BaseState}

function DialogueState:init(dialogues, font, callback)
    self.dialogues = dialogues
    self.font = font or gFonts['small']
    --for i, text in pairs(dialogue) do
    self.textbox = Textbox(6, 6, VIRTUAL_WIDTH - 12, 64, dialogues[1].text, self.font)
    --end
    self.currentDialogue = 1
    
    self.callback = callback or function() end
end

function DialogueState:update(dt)
    self.textbox:update(dt)
    if self.dialogues[self.currentDialogue].isQuestion == true then
        gStateStack:push(DialogueSelectState(self.dialogues[self.currentDialogue]))
    else
        if self.textbox:isClosed() then
            if #self.dialogues > self.currentDialogue then
                self.currentDialogue = self.currentDialogue + 1
                self.textbox = Textbox(6, 6, VIRTUAL_WIDTH - 12, 64, self.dialogues[self.currentDialogue].text, self.font)
            else
                self.callback()
                gStateStack:pop()
            end
        end
    end
    -- self.textbox:update(dt)

    -- if self.textbox:isClosed() then
    --     self.callback()
    --     gStateStack:pop()
    -- end
end

function DialogueState:render()
    self.textbox:render()
end