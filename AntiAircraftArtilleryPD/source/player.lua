import "CoreLibs/graphics"
import "CoreLibs/object"



class('player').extends()

function player:init()
    player.super.init(self)
    self.side = 200
    self.up = 360
end

function player:setUp(u)
    self.up = u
end

function player:setSide(s)
    self.side = s
end

function player:getUp()
	return self.up
end

function player:getSide()
	return self.side
end


