--[[
    MyRPG Prototype    

]]

CombatEntity = Class{}

function CombatEntity:init(def)
    self.flipped = def.flipped or false
    self.animations = self:createAnimations(def.animations)
    self.drawOffset = def.drawOffset
    self.health = 10
    
    -- self.width = def.width
    -- self.height = def.height

    self.x = def.x or 0
    self.y = def.y or 0
    
end

-- function CombatEntity:changeState(name)
--     self.stateMachine:change(name)
-- end

function CombatEntity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end

function CombatEntity:createAnimations(animations)
    local animationsReturned = {}

    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            texture = animationDef.texture,
            frames = animationDef.frames,
            interval = animationDef.interval
        }
    end

    return animationsReturned
end


function CombatEntity:update(dt)
    self.currentAnimation:update(dt)
end

function CombatEntity:render()
    local anim = self.currentAnimation
    local scaleX = self.flipped and -1 or 1
    love.graphics.draw(gCombatSprites[anim.texture], gCombatFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.x), math.floor(self.y), 0, scaleX, 1, self.drawOffset, self.drawOffset)
end