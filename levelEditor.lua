require("camera")
require("tilemap")

levelEditor = {
    open = true,
    clicking = false,
    selectedTile = {x = 0, y = 0},
    currentLevel = nil,
}
local debug = 0

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
        if levelEditor:isTileInMenu(tile) then
            self.selectedTile.x = x
            self.selectedTile.y = y
        end
    end
end

function levelEditor:render()
    if not self.open then
        return
    end
    levelEditor:drawPallete()
end

function levelEditor:drawPallete()
    -- TODO: debind camera
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, 400, 1000)
    levelEditor:drawPalleteSprites()
    love.graphics.setColor(0, 0, 0)

    local text = love.graphics.newText(love.graphics.getFont(), "Level: " .. (self.currentLevel or "nil"))
    local width = text:getWidth()
    love.graphics.draw(text, 0, 5)

    love.graphics.rectangle("fill", width + 20, 5, 100, 20)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("select level", width + 25, 5)
end

function levelEditor:drawPalleteSprites()
    sprites = love.filesystem.getDirectoryItems("sprites")
    for i, sprite in ipairs(sprites) do
        if sprite == "selectedTile.png" then
            table.remove(sprites, i)
            break
        end
    end
    
    for i, sprite in ipairs(sprites) do
        local tile
        local j = i
        local timesSub = 1

        while j > 10 do
            j = j - 10
            timesSub = timesSub + 1
        end

        tile = tilemap:createTile("sprites/" .. sprite, (j) + debug, timesSub + 1, nil)
        
        tilemap:drawTile(tile)

        if j + debug == self.selectedTile.x and timesSub + 1 == self.selectedTile.y then
            local selectedTileSprite = tilemap:createTile("sprites/selectedTile.png", (j) + debug, timesSub + 1, nil)
            tilemap:drawTile(selectedTileSprite)
        end
    end
end

function levelEditor:isTileInMenu(checkTile)
    sprites = love.filesystem.getDirectoryItems("sprites")
    for i, sprite in ipairs(sprites) do
        local tile
        local j = i
        local timesSub = 1

        while j > 10 do
            j = j - 10
            timesSub = timesSub + 1
        end
        if checkTile.x == j + debug and checkTile.y == timesSub + 1 then
            return true
        end
    end
end
