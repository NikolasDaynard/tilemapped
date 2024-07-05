require("helpers")

levelLoader = {
    readingTiles = false,
    readingCollisionTiles = false,
    workingTile = {},
    tiles = {},
    collisionTiles = {},
    entities = {},
}

function levelLoader:loadLevel(level)
    self.tiles = {}

    local contents, size = love.filesystem.read(level)
    -- new line splitting from https://stackoverflow.com/questions/32847099/split-a-string-by-n-or-r-using-string-gmatch
    lines = {}
    for s in contents:gmatch("[^\r\n]+") do
        table.insert(lines, s)
    end

    for _, line in ipairs(lines) do
        if line == "Tiles:" then
            self.readingEntities = false
            self.readingCollisionTiles = false
            self.readingTiles = true
        end
        if line == "CollisionTiles:" then
            self.readingEntities = false
            self.readingCollisionTiles = true
            self.readingTiles = false
        end
        if line == "Entities:" then
            self.readingEntities = true
            self.readingCollisionTiles = false
            self.readingTiles = false
        end

        if self.readingTiles then
            if line == "Tile:" then
                self.workingTile = {}

            elseif string.find(line, "x: ") ~= nil then
                local value = split(line)
                self.workingTile.x = value[2]

            elseif string.find(line, "y: ") ~= nil then
                local value = split(line)
                self.workingTile.y = value[2]
            elseif string.find(line, "sprite: ") ~= nil then
                local value = split(line)
                self.workingTile.sprite = value[2]

                -- last val so save
                table.insert(self.tiles, deepCopy(self.workingTile))
            end
        end

        if self.readingCollisionTiles then
            if line == "Tile:" then
                self.workingTile = {}

            elseif string.find(line, "x: ") ~= nil then
                local value = split(line)
                self.workingTile.x = value[2]

            elseif string.find(line, "y: ") ~= nil then
                local value = split(line)
                self.workingTile.y = value[2]
                -- last val so save
                table.insert(self.collisionTiles, deepCopy(self.workingTile))
            end
        end

        -- Entity:
        -- x: 0
        -- y: 0
        -- sprite: sprites/goldTile.png
        -- onInteract: interaction:test()

        -- last val so save
        -- 
        if self.readingEntities then
            if line == "Tile:" then
                self.workingTile = {}

            elseif string.find(line, "x: ") ~= nil then
                local value = split(line)
                self.workingTile.x = value[2]
            elseif string.find(line, "y: ") ~= nil then
                local value = split(line)
                self.workingTile.y = value[2]
            elseif string.find(line, "sprite: ") ~= nil then
                local value = split(line)
                self.workingTile.sprite = value[2]
            elseif string.find(line, "onInteract: ") ~= nil then
                local value = split(line)
                self.workingTile.callback = value[2] -- callbacks have foo:bar so you need to concat it NVM
                table.insert(self.entities, deepCopy(self.workingTile))
            end
        end
    end

    local returnTiles = {}
    local returnCollisionTiles = {}
    local returnEntities = {}

    for _, tile in ipairs(self.tiles) do
        table.insert(returnTiles, tilemap:createTile("sprites/" .. tile.sprite, tile.x, tile.y))
    end

    for _, tile in ipairs(self.collisionTiles) do
        table.insert(returnCollisionTiles, tilemap:createTile("sprites/X.png", tile.x, tile.y))
    end

    for _, tile in ipairs(self.entities) do
        table.insert(returnEntities, tilemap:createEntity("sprites/" .. tile.sprite, tile.x, tile.y, tile.callback))
    end

    return returnTiles, returnCollisionTiles, returnEntities
end
-- only works as dev. Dunno how to do this as player
function levelLoader:saveLevel(tiles, collisionTiles, entities, level)
    file = io.open(level, "w")
    file:write("Entities:\n")
    for _, tile in ipairs(entities) do
        file:write("Entity:\n")
        file:write("x: " .. tile.x .. "\n")
        file:write("y: " .. tile.y .. "\n")
        file:write("sprite: " .. split(tile.spriteName, "/")[2] .. "\n")
        file:write("onInteract: " .. (tile.callback or "") .. "\n")
    end
    file:write("Tiles:\n")
    for _, tile in ipairs(tiles) do
        file:write("Tile:\n")
        file:write("x: " .. tile.x .. "\n")
        file:write("y: " .. tile.y .. "\n")
        file:write("sprite: " .. split(tile.spriteName, "/")[2] .. "\n") -- this remoced the sprites/
    end
    file:write("CollisionTiles:\n")
    for _, tile in ipairs(collisionTiles) do
        file:write("Tile:\n")
        file:write("x: " .. tile.x .. "\n")
        file:write("y: " .. tile.y .. "\n")
    end

    io.close(file)
end