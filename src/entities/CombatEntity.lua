--[[
    MyRPG Prototype    

    Used during combat, this class renders an entity to the screen and keeps track of information
    for that entity.
]]

CombatEntity = Class{}

function CombatEntity:init(def)
    self.flipped = def.flipped or false
    self.animations = self:createAnimations(def.animations)
    self.drawOffset = def.drawOffset
    self.shadow = def.shadow
    --self.HP = def.HP or 100
    self.currentHP = self.HP
    self.isEnemy = def.isEnemy or (not def.flipped)
    self.isDead = false

    -- STATS Specific to the kind of entity
    self.baseHP = def.baseHP
    self.baseAttack = def.baseAttack
    self.baseDefense = def.baseDefense
    self.baseSpeed = def.baseSpeed

    self.HPIV = def.HPIV
    self.attackIV = def.attackIV
    self.defenseIV = def.defenseIV
    self.speedIV = def.speedIV

    -- STATS specific to the entity's current level
    self.HP = self.baseHP
    self.attack = self.baseAttack
    self.defense = self.baseDefense
    self.speed = self.baseSpeed

    -- Stats specific to the current battle
    self.currentHP = self.baseHP
    self.currentAttack = self.baseAttack 
    self.currentDefense = self.baseDefense
    self.currentSpeed = self.baseSpeed

    
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

-- Returns the amount of time it takes to loop through a given animation once
function CombatEntity:animationDuration(animName)
    return self.animations[animName].interval * #self.animations[animName].frames
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
    -- render shadow
    love.graphics.setColor(10/255, 10/255, 30/255, 100/255)
    love.graphics.ellipse('fill', math.floor(self.x + self.shadow.offsetX),
        math.floor(self.y + self.shadow.offsetY), self.shadow.width, self.shadow.height)
    love.graphics.setColor(1, 1, 1, 1)

    -- render sprite
    local anim = self.currentAnimation
    local scaleX = self.flipped and -1 or 1
    love.graphics.draw(gCombatSprites[anim.texture], gCombatFrames[anim.texture][anim:getCurrentFrame()],
        math.floor(self.x), math.floor(self.y), 0, scaleX, 1, self.drawOffset, self.drawOffset)

end