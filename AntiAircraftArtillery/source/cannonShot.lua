import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics



class('cannonShot').extends(gfx.sprite)

function cannonShot:init(x, y)
    cannonShot.super.init(self)
    self.rx = x
    self.ry = y
    self:moveTo(x, y)
    self:setZIndex(32766)
end

function cannonShot:setPos(x, y)
    self.rx = x
    self.ry = y
    self:moveTo(x, y)
end

function cannonShot:screenPositionCannon(x,y)
    self:moveBy(x, y)
end


function cannonShot:getSide()
return self.rx
end

function cannonShot:getUp()
return self.ry
end




