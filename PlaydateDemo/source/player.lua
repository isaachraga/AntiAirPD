import "CoreLibs/graphics"
import "CoreLibs/object"
local pd <const> = playdate
local gfx <const> = pd.graphics



class('player').extends()

function player:init(sides, ups)
    player.super.init(self)
    self.up = ups
    self.side = sides 
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


