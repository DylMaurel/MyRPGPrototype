--[[

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Edited by Dylan Maurel to include custom colors
]]

Panel = Class{}

function Panel:init(x, y, width, height, backColor, frontColor)
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    self.backColor = backColor or {r=1,g=1,b=1,a=1}
    self.frontColor = frontColor or {r=56/255, g=56/255, b=80/255, a=1}

    self.visible = true
end

function Panel:update(dt)

end

function Panel:render()
    if self.visible then
        -- draw back of panel
        love.graphics.setColor(
            self.backColor.r, self.backColor.g, self.backColor.b, self.backColor.a)
        love.graphics.rectangle('line', math.floor(self.x - 1), math.floor(self.y - 1),
        self.width + 2, self.height + 2, 3)
        -- draw front of panel
        love.graphics.setColor(
            self.frontColor.r, self.frontColor.g, self.frontColor.b, self.frontColor.a)
        love.graphics.rectangle('fill', math.floor(self.x), math.floor(self.y),
        self.width, self.height, 3)
      
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Panel:toggle()
    self.visible = not self.visible
end