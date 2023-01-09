import "CoreLibs/timer"
import "explosion"
local pd <const> = playdate
local gfx <const> = pd.graphics






class('DummyPlane').extends(gfx.sprite)

function DummyPlane:init(xa, ya, ID)
    --print("DUMMY")
    DummyPlane.super.init(self)
    self.offset = offset
    self.ID = ID

    local image = gfx.image.new("images/plane")
   
    self:setImageDrawMode("copy")
    
    self.rx = xa
    self.ry = ya
    self:setImage(image)
    self:setScale(0)
    self:setCollideRect(0,0,self:getSize())

    local hitmarker = gfx.image.new("images/HitMarker")

	self.hm = gfx.sprite.new(hitmarker)
    self.hm:setImageDrawMode(gfx.kDrawModeNXOR)
	self.hm:add()
	self.hm:setVisible(false)

end

function DummyPlane:setMainPlane(p)
    self.mainPlane = p
end

function DummyPlane:getSide()
    
    return self.rx
end

function DummyPlane:getUp()
    
    return self.ry
end

function DummyPlane:getMainPlane()
    return self.mainPlane
end

function DummyPlane:incrementScale(value)
       self:setScale(value)  
end



function DummyPlane:setPosition(x, y)
    self:moveTo(x,y)
    self.hm:moveTo(x,y)
    
end



function DummyPlane:damage(a)
    self.mainPlane:damage(a)
    self.hm:setVisible(true)
end



function DummyPlane:resetHMScale()
    self.hm:setVisible(false)
end




function DummyPlane:destroy()
    self.hm:remove()
    exp = explosion(self.rx, self.ry, self:getZIndex(), mapping(self:getScale(), .05, 2,.4,20))       
    addAnimation(exp)
    self:remove()
end
