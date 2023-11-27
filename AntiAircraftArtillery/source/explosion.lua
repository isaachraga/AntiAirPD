import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics




class('explosion').extends(gfx.sprite)

function explosion:init(x, y, zindex, scale)
    explosion.super.init(self)
    self.frameTimer = playdate.timer.new(660,1000, 11000)
    self.exp = gfx.imagetable.new("images/Explosion")
    self.rx = x
    self.ry = y
    self.dx = self.rx
    self.dy = self.ry
    self:moveTo(self.rx, self.ry)
    self:setScale(scale)
    self:setZIndex(zindex)
    self:add()
    self:explode()
end

--PLANE

function explosion:explode()
    if(math.floor(self.frameTimer.value/1000) < 11) then
        self:setImage(self.exp:getImage(math.floor(self.frameTimer.value/1000)))
        self:moveTo(self:screenPositionX(), self:screenPositionY())
    else
        removeAnim(self)
        self:remove()
    end
end

function explosion:screenPositionX()
    self.xd = self.rx - getSide() + 200
    return self.xd
end
function explosion:screenPositionY()

    self.yd = self.ry - getUp() + 120
    return self.yd
end

--CANNON

function explosion:explodeCannon()

    if(math.floor(self.frameTimer.value/1000) < 11) then
        self:setImage(self.exp:getImage(math.floor(self.frameTimer.value/1000)))
       self:moveTo(self:screenPositionCannon())
    else
        removeAnim(self)

        self:remove()
    end
end

function explosion:screenPositionCannon(x,y)
    if(x~= nil) then
        self.dx = self.dx + x
    end

    if(y~=nil) then 
        self.dy = self.dy - y
    end

    return self.dx, self.dy

end









