require("tilemap")

player = {
    tile = tilemap:createTile("sprites/player.png", 1, 1),
    movementTimer = 0,
}

function player:render()
    tilemap:drawTile(self.tile)
end

function player:update(dt)
    self.movementTimer = self.movementTimer + dt
    if self.movementTimer > .3 then
        if love.keyboard.isDown("w") then
            self.tile.y = self.tile.y - 1
        end
        if love.keyboard.isDown("s") then
            self.tile.y = self.tile.y + 1
        end
        if love.keyboard.isDown("a") then
            self.tile.x = self.tile.x - 1
        end
        if love.keyboard.isDown("d") then
            self.tile.x = self.tile.x + 1
        end
        self.movementTimer = 0
        camera:lookAt(tilemap:tileToScreen(self.tile.x, self.tile.y))
    end
end