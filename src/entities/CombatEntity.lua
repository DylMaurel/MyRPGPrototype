--[[
    MyRPG Prototype    

]]

CombatEntity = Class{}

function CombatEntity:init(def)
    self.flipped = def.flipped or false
    self.animations = self:createAnimations(def.animations)
    self.drawOffset = def.drawOffset
    self.health = def.health or 10
    
    -- self.width = def.width
    -- self.height = def.height
    self.x = def.x or 0
    self.y = def.y or 0

    -- These coordinates are the positions that the entity stands throughout the battle.
    -- These variables will be initialized when BattleState:calcEntityPositions() is called.
    -- We must remember these variables because an entity's x and y can move when they are
    -- attacking, and we need a way for them to return to their original position.
    self.standingX = nil
    self.standingY = nil
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
            interval = animationDef.interval,
            looping = animationDef.looping
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