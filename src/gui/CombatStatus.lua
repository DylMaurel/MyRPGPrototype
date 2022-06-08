--[[
    My RPG Prototype
]]

CombatStatus = Class{}

function CombatStatus:init(def)
    self.x = def.x
    self.y = def.y
    self.initialX = self.x
    self.initialY = self.y
    self.width = 75
    self.height = 24
    self.entityName = def.entityName

    self.healthBar = ProgressBar {
        x = self.x + 8,
        y = self.y + 17,
        width = 64,
        height = 4,
        color = {r = 189/255, g = 189/255, b = 32/255},
        value = def.currentHP,
        max = def.HP
    }

    self.visible = true
end

function CombatStatus:update(dt)
    self.healthBar.x = self.x + 8
    self.healthBar.y = self.y + 17
end

function CombatStatus:render()
    if self.visible then
        love.graphics.setFont(gFonts['small'])
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y),
            self.width, self.height, 3)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(self.entityName, math.floor(self.x + 2), math.floor(self.y + 1))
        love.graphics.print('HP', math.floor(self.healthBar.x), math.floor(self.healthBar.y - 7))
        love.graphics.print(tostring(math.floor(self.healthBar.value)) .. '/' .. 
            tostring(self.healthBar.max), math.floor(self.healthBar.x + 14), math.floor(self.healthBar.y - 7))
        self.healthBar:render()
    end
end

function CombatStatus:toggle()
    self.visible = not self.visible
end