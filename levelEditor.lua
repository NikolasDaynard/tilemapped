require("tilemap")
require("levelLoader")
require("ui")

levelEditor = {
    open = false,
    clicking = false,
    selectedTile = {x = 0, y = 0, sprite = "sprites/testing_tile.png"},
    currentLevel = nil,
    levelSelectDropdownIsOpen = false,
    levelTiles = {},
    levelCollisionTiles = {},
    draggingMMBOffset = nil,
    draggingMMBStartPos = {x = 0, y = 0},
    mode = "level", -- "level" | "collision" | "scene"
}

local debug = 0

local levelToEdit = "testing.level"

function love.wheelmoved(x, y)
    if levelEditor.open then
        if y > 0 then
            camera:zoom(y / 2)
        else
            camera:zoom(1 / (math.abs(y) / 2))
        end
    end
end

function levelEditor:update()
    if love.mouse.isDown(2) then
        print("rmb")
        levelEditor:click(true)
        self.clicking = true
    elseif love.mouse.isDown(1) then
        levelEditor:click()
        self.clicking = true
    else
        self.clicking = false
    end

    if self.draggingMMBOffset then
        camera:lookAt(self.draggingMMBStartPos.x - self.draggingMMBOffset.x, self.draggingMMBStartPos.y - self.draggingMMBOffset.y)
    end

    if love.mouse.isDown(3) then
        local mmbOffsetX, mmbOffsetY = love.mouse.getPosition()
        local cameraOffsetX, cameraOffsetY = 0, 0
        
        if self.draggingMMBOffset == nil then
            cameraOffsetX, cameraOffsetY = camera:getPosition()
            self.draggingMMBStartPos = {x = mmbOffsetX + cameraOffsetX, y = mmbOffsetY + cameraOffsetY}
        end
        self.draggingMMBOffset = {x = mmbOffsetX, y = mmbOffsetY}
    else
        self.draggingMMBOffset = nil
    end

    if love.keyboard.isDown("left") then
        camera:move(-5, 0)
    end
    if love.keyboard.isDown("right") then
        camera:move(5, 0)
    end
    if love.keyboard.isDown("up") then
        camera:move(0, -5)
    end
    if love.keyboard.isDown("down") then
        camera:move(0, 5)
    end

    if love.keyboard.isDown("g") then
        if self.mode == "level" then
            self.mode = "collision"
        else
            self.mode = "level"
        end
    end

    if love.keyboard.isDown("lctrl") and love.keyboard.isDown("s") then
        -- print("levels/" .. self.currentLevel)
        levelLoader:saveLevel(self.levelTiles, self.levelCollisionTiles, "levels/" .. self.currentLevel)
    end
end
function levelEditor:render()
    if not self.open then
        return
    end
    levelEditor:drawPallete()

    camera:attach()
    if self.mode == "level" then
        for _, tile in ipairs(self.levelTiles) do
            tilemap:drawTile(tile)
        end
    else
        for _, tile in ipairs(self.levelCollisionTiles) do
            tilemap:drawTile(tile)
        end
    end
    camera:detach()
end


function levelEditor:click(deleting)
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
                    self.levelTiles, self.levelCollisionTiles = levelLoader:loadLevel("levels/" .. self.currentLevel)
                end
            end
        end
    end

    local menuX, menuY = tilemap:screenToTile(mouseX, mouseY)
    local menuTile = tilemap:getTileAtPosition(menuX, menuY)

    if levelEditor:isTileInMenu(menuTile) then
        self.selectedTile.x = menuX
        self.selectedTile.y = menuY
        self.selectedTile.sprite = "sprites/" .. levelEditor:isTileInMenu(menuTile)
    end

    local x, y = tilemap:screenToTile(camera:worldCoords(mouseX, mouseY))
    local tile = tilemap:getTileAtPosition(x, y)

    if tile then
        if not levelEditor:isTileInMenu(menuTile) then
            local tileset
            if self.mode == "level" then
                tileset = self.levelTiles
            elseif self.mode == "collision" then
                tileset = self.levelCollisionTiles
            end
            for i, allTile in ipairs(tileset) do
                if tonumber(tile.x) == tonumber(allTile.x) and tonumber(tile.y) == tonumber(allTile.y) then
                    tileset[i] = nil
                    table.remove(tileset, i)
                    break
                end
            end
            if not deleting then
                table.insert(tileset, tilemap:createTile(self.selectedTile.sprite, tile.x, tile.y))
            end
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
        for _, level in ipairs(levels) do
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
        if checkTile.x == j + debug and checkTile.y == timesSub + 1 then
            return sprite
        end
    end
end
