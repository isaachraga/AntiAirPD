import "CoreLibs/timer"
import "explosion"
local pd <const> = playdate
local gfx <const> = pd.graphics






class('DummyPlane').extends(gfx.sprite)

function DummyPlane:init(setRealX, setRealY, ID, offset, imageTablePMSend, hitmarkerGet)
    --print("DUMMY")
    DummyPlane.super.init(self)
    self.offset = offset
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
    if self.offsetNum > 0 then
        if self.offsetBool == true then
			self.offsetBool = false
			
            self.imageNum += 1
            local x = self:getSize(width)
            local y = self:getSize(height)*.2
            

            self:setImage(self.imageTable[self.imageNum])
            self:setCollideRect(0,0,x,y)
            
            self.offsetNumCounter -= 1;

			if self.offsetNumCounter < 1 then 
			   self.offsetNum-=1
			   self.offsetNumCounter = 14
			end
			
		else
			self.offsetBool = true
			
		end
    else
        
        self.imageNum += 1
        local x = self:getSize(width)
        local y = self:getSize(height)*.2
        
        if x > 300 then
            x = 300
        end
        if y > 220 then 
            y = 220
        end

        self:setImage(self.imageTable[self.imageNum])
        self:setCollideRect(0,0,x,y)
    end
    
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

function DummyPlane:incrementScale(num)
       self:setScale(num)  
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
