require("tilemap")

player = {
    tile = tilemap:createTile("sprites/player.png", 1, 1)
}

function player:render()
    tilemap:drawTile(self.tile)
end

function player:update()

end