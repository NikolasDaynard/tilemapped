Camera = require 'camera'

require("tilemap")
require("player")
require("levelEditor")

-- sprite = love.graphics.newImage("sprites/testing_tile.png")

currentLevel = "levels/testing.level"

tilemap:init()

function love.load()
    camera = Camera(0, 0, 1, 0, Camera.smooth.damped(.1))
end

function love.update(dt)
    if levelEditor.open then
        levelEditor:update()
        return
    end

    player:update(dt)
end

function love.draw()
    -- love.graphics.rectangle("fill", 100, 100, 10, 10)
    -- love.graphics.draw(sprite, 200, 200, 0, 10, 10)
    camera:attach()

    tilemap:render()
    player:render()

    camera:detach()

    levelEditor:render()
end