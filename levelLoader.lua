require("helpers")
require("tilemap")

levelLoader = {
    readingTiles = false,
    readingTile = true,
    workingTile = {},
    tiles = {},
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
            self.readingTiles = true

        elseif line == "Tile:" then
            self.readingTile = true
            self.tile = {}

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
            table.insert(self.tiles, self.workingTile)
        end
    end

    local returnTiles = {}

    for _, tile in ipairs(self.tiles) do
        table.insert(returnTiles, tilemap:createTile("sprites/" .. tile.sprite, tile.x, tile.y))
    end

    return returnTiles
end