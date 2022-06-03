--[[

]]

DialogueSelectState = Class{__includes = BaseState}

function DialogueSelectState:init(dialogue)
    self.dialogue = dialogue
    -- Find all the dialogue answers and use those as the 'items' paramenter for a Menu
    local dialogueAnswers = {}
    for i, answer in pairs(dialogue.answers) do
        dialogueAnswers[i] = {}
        dialogueAnswers[i].text = answer
        dialogueAnswers[i].onSelect = function()
            -- insert code here for giving/receiving items while talking to an npc.

            gStateStack:pop() -- pop this current DialogueSelectState
            gStateStack:pop() -- pop the DialogueState that asked a question
            -- Push a new dialogue state for the response.
            gStateStack:push(DialogueState(dialogue.responses[i], gFonts['medium']))
            end
    end

    self.dialogueMenu = Menu {
        x = VIRTUAL_WIDTH - 64,
        y = VIRTUAL_HEIGHT - 64,
        width = 64,
        height = 64,
        items = dialogueAnswers
    }
end

function DialogueSelectState:update(dt)
    self.dialogueMenu:update(dt)
end

function DialogueSelectState:render()
    self.dialogueMenu:render()
end