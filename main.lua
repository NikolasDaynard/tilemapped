Camera = require 'camera'

require("tilemap")
require("player")
require("levelEditor")

-- sprite = love.graphics.newImage("sprites/testing_tile.png")

tilemap:init()

function love.load()
    camera = Camera(0, 0, 1, 0)
end

function love.update()
    if levelEditor.open then
        levelEditor:update()
        return
    end
    camera:move(.1, 0)
end

function love.draw()
    -- love.graphics.rectangle("fill", 100, 100, 10, 10)
    -- love.graphics.draw(sprite, 200, 200, 0, 10, 10)
    camera:attach()

    tilemap:render()
    player:render()

    levelEditor:render()

    camera:detach()
end