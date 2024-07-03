require("tilemap")
require("player")

-- sprite = love.graphics.newImage("sprites/testing_tile.png")

-- tilemap:addTile("sprites/testing_tile.png", 1, 1)
-- tilemap:addTile("sprites/testing_tile.png", 2, 1)
-- tilemap:addTile("sprites/testing_tile.png", 4, 4)
tilemap:init()

function love.draw()
    -- love.graphics.rectangle("fill", 100, 100, 10, 10)
    -- love.graphics.draw(sprite, 200, 200, 0, 10, 10)
    tilemap:render()
    player:render()
end