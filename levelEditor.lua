require("camera")
require("tilemap")
require("levelLoader")
require("ui")

levelEditor = {
    open = true,
    clicking = false,
    selectedTile = {x = 0, y = 0},
    currentLevel = nil,
    levelSelectDropdownIsOpen = false,
    levelTiles = {},
}
local debug = 0

local levelToEdit = "testing.level"

function levelEditor:update()
    if love.mouse.isDown(1) then
        levelEditor:click()
        self.clicking = true
    else
        self.clicking = false
    end
end

function levelEditor:click()
    local mouseX, mouseY = love.mouse.getPosition() -- TODO: make this camera (nope)
    local levels = love.filesystem.getDirectoryItems("levels")

    -- check level dropdown
    if self.levelSelectDropdownIsOpen then
        local width = love.graphics.newText(love.graphics.getFont(), "Level: " .. (self.currentLevel or "nil")):getWidth()

        local longestText = 0
        for _, level in ipairs(levels) do
            longestText = math.max(love.graphics.newText(love.graphics.getFont(), level):getWidth(), longestText)
        end
        
        love.graphics.rectangle("fill", width + 20, 5, longestText + 10, #levels * 20)
        for i, level in ipairs(levels) do
            if ui:clickHitRect(mouseX, mouseY, width + 25, 5 + (i - 1) * 20, longestText + 10, 20) then
                if not self.clicking then
                    self.currentLevel = level
                    self.levelTiles = levelLoader:loadLevel(self.currentLevel)
                end
            end
        end
    end

    local x, y = tilemap:screenToTile(mouseX, mouseY)

    local tile = tilemap:getTileAtPosition(x, y)

    if tile then
        if levelEditor:isTileInMenu(tile) then
            self.selectedTile.x = x
            self.selectedTile.y = y
        end
    end

    -- check the level select button
    local text = love.graphics.newText(love.graphics.getFont(), "Level: " .. (self.currentLevel or "nil"))
    local width = text:getWidth()

    if ui:clickHitRect(mouseX, mouseY, width + 20, 5, 100, 20) then
        self.levelSelectDropdownIsOpen = true
    else
        self.levelSelectDropdownIsOpen = false
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

    -- level select dropdown render stuff here
    if self.levelSelectDropdownIsOpen then
        love.graphics.setColor(1, .1, 1)

        local levels = love.filesystem.getDirectoryItems("levels")
        love.graphics.setColor(1, .1, 1)

        local longestText = 0
        for i, level in ipairs(levels) do
            longestText = math.max(love.graphics.newText(love.graphics.getFont(), level):getWidth(), longestText)
        end

        love.graphics.rectangle("fill", width + 20, 5, longestText + 10, #levels * 20)
        
        local mouseX, mouseY = love.mouse.getPosition()
        
        love.graphics.setColor(0, 0, 0)
        for i, level in ipairs(levels) do
            if ui:clickHitRect(mouseX, mouseY, width + 25, 5 + (i - 1) * 20, longestText + 10, 20) then
                love.graphics.setColor(1, .6, 1)
                love.graphics.rectangle("fill", width + 20, 5 + ((i - 1) * 20), longestText + 10, 20)
                love.graphics.setColor(0, 0, 0)
            end
            love.graphics.print(level, width + 25, 5 + (i - 1) * 20)
        end


        love.graphics.setColor(1, 1, 1)
    end
end

function levelEditor:drawPalleteSprites()
    local sprites = love.filesystem.getDirectoryItems("sprites")
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
    local sprites = love.filesystem.getDirectoryItems("sprites")

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
