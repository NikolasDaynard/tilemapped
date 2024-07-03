-- where da tiles get rendered

tilemap = {
    tileMap = {},
    tiles = {},
    loadedSprites = {}
}

function tilemap:init()
    for i = 1, 30 do
        for j = 1, 30 do
            tilemap:addTile("sprites/testing_tile.png", i, j)
            -- table.insert()
        end
    end
end

function tilemap:createTile(name, x, y, update)
    if self.loadedSprites[name] == nil then
        self.loadedSprites[name] = love.graphics.newImage(name)
    end

    return {sprite = self.loadedSprites[name], x = x, y = y, update = update}
end

-- update is chill if it's nil dw
-- x and y are in tilemap space not world
function tilemap:addTile(name, x, y, update)

    self.tileMap[x .. ", " .. y] = tilemap:createTile(name, x, y, update)
    table.insert(self.tiles, self.tileMap[x .. ", " .. y])
end

function tilemap:insertTile(name, x, y, update)

end

function tilemap:render()
    for _, tile in ipairs(self.tiles) do
        tilemap:drawTile(tile)
    end
end

function tilemap:drawTile(tile)
    love.graphics.draw(tile.sprite, (tile.x - 1) * 32, (tile.y - 1) * 32, 0)
end

function tilemap:screenToTile(x, y)
    return math.floor(((x + 16) / 32) + .5), math.floor(((y + 16) / 32) + .5)
end

function tilemap:getTileAtPosition(x, y)
    return self.tileMap[x .. ", " .. y]
end