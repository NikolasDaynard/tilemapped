require("camera")
require("tilemap")

levelEditor = {
    open = true,
    clicking = false,
}

local levelToEdit = "testing.level"

function levelEditor:update()
    if love.mouse.isDown(1) then
        levelEditor:click()
        clicking = true
    end
end

function levelEditor:click()
    local x, y = love.mouse.getPosition() -- TODO: make this camera
    x, y = tilemap:screenToTile(x, y)

    local tile = tilemap:getTileAtPosition(x, y)

    if tile then
        
    end
end

function levelEditor:render()
    if not self.open then
        return
    end
    levelEditor:drawPallete()
end

function levelEditor:drawPallete()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 400, 1000)
    levelEditor:drawPalleteSprites()
end

function levelEditor:drawPalleteSprites()
    sprites = love.filesystem.getDirectoryItems("sprites")

    for i, sprite in ipairs(sprites) do
        tile = tilemap:createTile("sprites/" .. sprite, (i - math.floor((i - 1) / 10)) + 1, math.floor(i / 11) + 1)
        tilemap:drawTile(tile)

        -- if (math.floor(i / 11) * 10) ~= 0 then
        --     tile = tilemap:createTile("sprites/" .. sprite, i - (math.floor(i / 11) * 10), math.floor(i / 11) + 1, nil)
        -- else
        --     tile = tilemap:createTile("sprites/" .. sprite, i - (math.floor(i / 11) * 10), math.floor(i / 11) + 1, nil)
        -- end
        -- print("sprite" .. sprite)
        -- tilemap:drawTile(tile)
    end
end
