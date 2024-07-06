require("levelLoader")

-- where da tiles get rendered

tilemap = {
    tileMap = {},
    tiles = {},
    entities = {},
    collisionMap = {},
    entityMap = {},
    loadedSprites = {},
}

function tilemap:init()
    if currentLevel == nil or levelEditor.open then
        for i = 1, 30 do
            for j = 1, 30 do
                tilemap:addTile("sprites/testing_tile.png", i, j)
                -- table.insert()
            end
        end
    else
        local levelTiles, collisionTiles, entities = levelLoader:loadLevel(currentLevel)
        for _, tile in ipairs(levelTiles) do
            tilemap:addTile(tile.spriteName, tile.x, tile.y, nil)
        end
        for _, tile in ipairs(collisionTiles) do
            tilemap:addCollider(tile.x, tile.y)
        end
        for _, tile in ipairs(entities) do
            tilemap:addEntity(tile.spriteName, tile.x, tile.y, tile.callback)
        end
    end
end

function tilemap:createEntity(name, x, y, callback)
    if self.loadedSprites[name] == nil then
        self.loadedSprites[name] = love.graphics.newImage(name)
    end

    return {sprite = self.loadedSprites[name], spriteName = name, x = x, y = y, callback = callback}
end


function tilemap:createTile(name, x, y, update)
    if self.loadedSprites[name] == nil then
        self.loadedSprites[name] = love.graphics.newImage(name)
    end

    return {sprite = self.loadedSprites[name], spriteName = name, x = x, y = y, update = update}
end

-- update is chill if it's nil dw
-- x and y are in tilemap space not world
function tilemap:addTile(name, x, y, update)

    self.tileMap[x .. ", " .. y] = tilemap:createTile(name, x, y, update)
    table.insert(self.tiles, self.tileMap[x .. ", " .. y])
end

function tilemap:addEntity(name, x, y, callback)

    self.entityMap[x .. ", " .. y] = tilemap:createEntity(name, x, y, callback)
    table.insert(self.entities, self.entityMap[x .. ", " .. y])
end


function tilemap:isTileOpen(x, y)
    return not self.collisionMap[x .. ", " .. y]
end

function tilemap:addCollider(x, y)
    self.collisionMap[x .. ", " .. y] = true
end

function tilemap:insertTile(name, x, y, update)

end

function tilemap:render()
    for _, tile in ipairs(self.tiles) do
        tilemap:drawTile(tile)
    end
    for _, entity in ipairs(self.entities) do
        tilemap:drawEntity(entity)
    end
end

function tilemap:drawEntity(tile)
    love.graphics.draw(tile.sprite, (tile.x - 1) * 32, (tile.y - 1) * 32, 0)
end


function tilemap:drawTile(tile, scale)
    local sx, sy
    if scale then
        sx = 32 / tile.sprite:getWidth()
        sy = 32 / tile.sprite:getHeight()
    end


    love.graphics.draw(tile.sprite, (tile.x - 1) * 32, (tile.y - 1) * 32, 0, sx or 1, sy or 1)
    sprite = nil
end

function tilemap:tileToScreen(x, y)
    return x * 32, y * 32
end
function tilemap:screenToTile(x, y)
    return math.floor(((x + 16) / 32) + .5), math.floor(((y + 16) / 32) + .5)
end

function tilemap:getTileAtPosition(x, y)
    return self.tileMap[x .. ", " .. y]
end