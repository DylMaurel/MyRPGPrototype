Doorway = Class{}

function Doorway:init(def, onPassThrough)
    self.x = def.x
    self.y = def.y
    self.width = def.width
    self.height = def.height
    self.name = def.name
    -- This is the direction the player must face in order to go
    -- through the door.
    self.direction = def.direction
    -- Doors have 2 types: open and closed. Closed doors require the player to
    -- select the door, but open doors do not require the player to select them.
    self.type = def.type or 'open'
    -- fadeColor is the color that must be passed into the FadeIn and FadeOut
    -- states whenever the player passes through the door.
    if def.fadeColor == 'black' then
        self.fadeColor = {r=0,g=0,b=0}
    else
        self.fadeColor = {r=1,g=1,b=1} --white
    end

    -- A field for whether the door is locked or unlocked can be added in the future.

    if onPassThrough == nil then
        self.onPassThrough = function() end
    else
        self.onPassThrough = onPassThrough
    end

end