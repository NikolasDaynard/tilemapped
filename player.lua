require("tilemap")

player = {
    tile = tilemap:createTile("sprites/player.png", 1, 1),
    position = {x = 18, y = 14},
    movementTimer = 0,
}

function player:render()
    tilemap:drawTile(self.tile)
end

function player:update(dt)
    self.movementTimer = self.movementTimer + dt
    if self.movementTimer > .3 then
        if love.keyboard.isDown("w") then
            if tilemap:isTileOpen(self.position.x, self.position.y - 1) then
                self.position.y = self.position.y - 1
            end
        end
        if love.keyboard.isDown("s") then
            if tilemap:isTileOpen(self.position.x, self.position.y + 1) then
                self.position.y = self.position.y + 1
            end
        end
        if love.keyboard.isDown("a") then
            if tilemap:isTileOpen(self.position.x - 1, self.position.y) then
                self.position.x = self.position.x - 1
            end
        end
        if love.keyboard.isDown("d") then
            if tilemap:isTileOpen(self.position.x + 1, self.position.y) then
                self.position.x = self.position.x + 1
            end
        end
        self.movementTimer = 0
    end
    self.tile.x = self.tile.x - (self.tile.x - self.position.x) / 3
    self.tile.y = self.tile.y - (self.tile.y - self.position.y) / 3
    camera:lookAt(tilemap:tileToScreen(self.tile.x, self.tile.y))
end