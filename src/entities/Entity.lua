--[[
    MyRPG Prototype    

]]

Entity = Class{}

function Entity:init(def)
    self.direction = def.direction or 'down'
    self.animations = self:createAnimations(def.animations)
    self.dialogues = def.dialogues
    self.width = def.width
    self.height = def.height
    self.movesAround = def.movesAround

    self.x = def.x or 0
    self.y = def.y or 0
    
end

function Entity:changeState(name)
    self.stateMachine:change(name)
end

function Entity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

function Entity:createAnimations(animations)
    local animationsReturned = {}

    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            texture = animationDef.texture or 'entities',
            frames = animationDef.frames,
            interval = animationDef.interval
        }
    end

    return animationsReturned
end

--[[
    Called when we interact with this entity, as by pressing enter.
]]
function Entity:onInteract()
    if self.dialogues then
        gStateStack:push(DialogueState(self.dialogues, gFonts['medium']))
    end
end

function Entity:processAI(params, dt)
    self.stateMachine:processAI(params, dt)
end

function Entity:update(dt)
    self.currentAnimation:update(dt)
    self.stateMachine:update(dt)
end

function Entity:render()
    self.stateMachine:render()
end