--[[
    My RPG Prototype
]]

CombatStatus = Class{}

function CombatStatus:init(def)
    self.x = def.x
    self.y = def.y
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

end

function CombatStatus:render()
    if self.visible then
        love.graphics.setFont(gFonts['small'])
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle('fill', self.x, self.y,
            self.width, self.height, 3)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(self.entityName, self.x + 2, self.y + 1)
        love.graphics.print('HP', self.healthBar.x, self.healthBar.y - 7)
        love.graphics.print(tostring(self.healthBar.value) .. '/' .. 
            tostring(self.healthBar.max), self.healthBar.x + 14, self.healthBar.y - 7)
        self.healthBar:render()
    end
end

function CombatStatus:toggle()
    self.visible = not self.visible
end