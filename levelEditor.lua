require("tilemap")
require("levelLoader")
require("ui")

levelEditor = {
    open = true,
    clicking = false,
    selectedTile = {x = 0, y = 0, sprite = "sprites/testing_tile.png"},
    currentLevel = nil,
    levelSelectDropdownIsOpen = false,
    levelTiles = {},
    levelCollisionTiles = {},
    levelEntities = {},
    draggingMMBOffset = nil,
    draggingMMBStartPos = {x = 0, y = 0},
    sidePanelSize = 400,
    mode = "interaction", -- "all" | "level" | "collision" | "scene" | "interaction"
    flag = "editing", -- "viewing" | "interaction" | "editing"
    textbox = {x = 1, y = 1, text = "foo", open = true}
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

function love.keypressed(k)
    if levelEditor.textbox.open then
        levelEditor.textbox.text = levelEditor.textbox.text .. k
    end
end

function levelEditor:update()
    if love.mouse.isDown(2) then
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

    if love.keyboard.isDown("0") then
        self.mode = "all"
        self.flag = "viewing"
    elseif love.keyboard.isDown("1") then
        self.mode = "collision"
        self.flag = "editing"
    elseif love.keyboard.isDown("2") then
        self.mode = "level"
        self.flag = "editing"
    elseif love.keyboard.isDown("3") then
        self.mode = "entities"
        self.flag = "editing"
    elseif love.keyboard.isDown("4") then
        self.mode = "all"
        self.flag = "interaction"
    end

    if love.keyboard.isDown("lctrl") and love.keyboard.isDown("s") then
        -- print("levels/" .. self.currentLevel)
        levelLoader:saveLevel(self.levelTiles, self.levelCollisionTiles, self.levelEntities, "levels/" .. self.currentLevel)
    end
end

function levelEditor:click(deleting)
    local mouseX, mouseY = love.mouse.getPosition() -- TODO: make this camera (nope)
    local levels = love.filesystem.getDirectoryItems("levels")

    if mouseX > self.sidePanelSize - 20 and mouseX < self.sidePanelSize + 20 then
        self.sidePanelSize = mouseX
        return
    end

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
                    self.levelTiles, self.levelCollisionTiles, self.levelEntities = levelLoader:loadLevel("levels/" .. self.currentLevel)
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
            local tileset = {}
            if self.flag ~= "viewing" then
                if self.mode == "level" then
                    tileset = self.levelTiles
                elseif self.mode == "collision" then
                    tileset = self.levelCollisionTiles
                elseif self.mode == "entities" then
                    tileset = self.levelEntities
                end
            end

            if self.flag == "interaction" then
                
            end

            if deleting then
                for i, allTile in ipairs(tileset) do
                    if tonumber(tile.x) == tonumber(allTile.x) and tonumber(tile.y) == tonumber(allTile.y) then
                        tileset[i] = nil
                        table.remove(tileset, i)
                        break
                    end
                end
            end

            if not deleting and self.flag == "editing" then
                if not self.mode == "entities" then
                    table.insert(tileset, tilemap:createTile(self.selectedTile.sprite, tile.x, tile.y))
                else
                    tile.callback = "camera:zoom(20)"
                    table.insert(tileset, tilemap:createEntity(self.selectedTile.sprite, tile.x, tile.y, tile.callback))
                end
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

function levelEditor:render()
    if not self.open then
        return
    end

    camera:attach()
    if self.mode == "level" or self.mode == "all" then
        for _, tile in ipairs(self.levelTiles) do
            tilemap:drawTile(tile)
        end
    end
    if self.mode == "collision" or self.mode == "all" then
        for _, tile in ipairs(self.levelCollisionTiles) do
            tilemap:drawTile(tile)
        end
    end
    if self.mode == "entities" or self.mode == "all" then
        for _, tile in ipairs(self.levelEntities) do
            tilemap:drawTile(tile)
        end
    end

    levelEditor:renderTextbox() -- needs to place above tiel

    camera:detach()

    levelEditor:drawPallete()
end

function levelEditor:drawPallete()
    -- TODO: debind camera
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, self.sidePanelSize, 1000) -- palete side panel
    levelEditor:drawPalleteSprites()
    love.graphics.setColor(0, 0, 0)

    local text = love.graphics.newText(love.graphics.getFont(), "Level: " .. (self.currentLevel or "nil"))
    local width = math.max(text:getWidth(), love.graphics.newText(love.graphics.getFont(), self.mode .. "|" .. self.flag):getWidth())

    love.graphics.setColor(1, 1, 1)
    -- block for behind the flags
    love.graphics.rectangle("fill", 0, 15, love.graphics.newText(love.graphics.getFont(), self.mode .. "|" .. self.flag):getWidth(), 20)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.mode .. "|" .. self.flag, 0, 15)

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
    
    local spritesPerLine = math.floor(self.sidePanelSize / 32)
    if spritesPerLine == 0 then
        spritesPerLine = 1
    end

    for i, sprite in ipairs(sprites) do
        local tile
        local j = i
        local timesSub = 1

        while j > spritesPerLine do
            j = j - spritesPerLine
            timesSub = timesSub + 1
        end

        tile = tilemap:createTile("sprites/" .. sprite, (j) + debug, timesSub + 1, nil)
        
        tilemap:drawTile(tile, true) -- set scaling true to normalize everything to 32x32

        if j + debug == self.selectedTile.x and timesSub + 1 == self.selectedTile.y then
            local selectedTileSprite = tilemap:createTile("sprites/selectedTile.png", (j) + debug, timesSub + 1, nil)
            tilemap:drawTile(selectedTileSprite)
        end
    end
end
function levelEditor:renderTextbox()
    if not self.textbox.open then
        return
    end

    local textboxX, textboxY = tilemap:tileToScreen(self.textbox.x, self.textbox.y)

    local textboxText = love.graphics.newText(love.graphics.getFont(), self.textbox.text)

    love.graphics.setColor(1, .1, 1)
    love.graphics.rectangle("fill", textboxX, textboxY, textboxText:getWidth(), 20)
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(self.textbox.text, textboxX, textboxY)
    love.graphics.setColor(1, 1, 1)
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
