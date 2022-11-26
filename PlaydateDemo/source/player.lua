import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics



class('player').extends(gfx.sprite)

function player:init(sides, ups)
    
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


