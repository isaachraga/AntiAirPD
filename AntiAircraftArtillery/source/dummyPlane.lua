import "CoreLibs/timer"
import "explosion"
local pd <const> = playdate
local gfx <const> = pd.graphics






class('DummyPlane').extends(gfx.sprite)

function DummyPlane:init(setRealX, setRealY, ID, imageTablePMSend, hitmarkerGet)
    DummyPlane.super.init(self)
    self.ID = ID

    self.imageTable = imageTablePMSend

    self:setImageDrawMode("copy")
    
    self.realX = setRealX
    self.realY = setRealY
    self.imageNum = 1
    self:setImage(self.imageTable[self.imageNum])
    self:setCollideRect(0,0,self:getSize())

	self.hm = gfx.sprite.new(hitmarkerGet)
    self.hm:setImageDrawMode(gfx.kDrawModeNXOR)
	self.hm:add()
	self.hm:setVisible(false)

    self.offsetBool = false
    self.offsetNum = 22
    self.offsetNumCounter = 14

end

function DummyPlane:setMainPlane(p)
    self.mainPlane = p
end

function DummyPlane:advanceSprite()
    self.imageNum += 1
    local x = self:getSize(width)
    local y = self:getSize(height)*.2
    

    self:setImage(self.imageTable[self.imageNum])
    self:setCollideRect(0,0,x,y)
    
    
end

function DummyPlane:getSide()
    
    return self.realX
end

function DummyPlane:getUp()
    
    return self.realY
end

function DummyPlane:getMainPlane()
    return self.mainPlane
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


function DummyPlane:destroy(size)
    self.hm:remove()
    exp = explosion(self.realX, self.realY, self:getZIndex(), mapping(size, 1000, 0,.01,2))       
    addAnimation(exp)
    self:remove()
end
