import "CoreLibs/timer"
import "explosion"
local pd <const> = playdate
local gfx <const> = pd.graphics
local planeTime = 44500
local secondStageTime = 550







class('Plane').extends(gfx.sprite)

function Plane:init(planeArrayGet, dummy, setRealX, setRealY, ID, imageTablePMSend, expSoundGet, apsGet, hitMarkerGet)
    Plane.super.init(self)

    self.expSound = expSoundGet
    self.imageTable = imageTablePMSend

    self.distance = playdate.timer.new(planeTime-secondStageTime, 1000, 750, playdate.easingFunctions.inExpo)
    self.radarDistance = playdate.timer.new(planeTime, 1000, 0, playdate.easingFunctions.linear)
    self.planeArrayP = planeArrayGet
    self:setImageDrawMode("copy")
    self.health = 100
    self.realX = setRealX
    self.realY = setRealY
    self.imageNum = 1
    self:setImage(self.imageTable[self.imageNum])

    self:setCollideRect(0,0,self:getSize())

    self.offsetBool = false
    self.offsetNum = 22
    self.offsetNumCounter = 14

    if(dummy ~= nil) then
        self.dummyPlane = dummy
    end

   self.rate = playdate.timer.new(planeTime, .7, 1.4, playdate.easingFunctions.inExpo)

    self.volumeLevel = playdate.timer.new(planeTime, 0, 1.5, playdate.easingFunctions.inExpo)

    self.aps = pd.sound.sampleplayer.new(apsGet)
    self.aps:play(0, self.rate.value)
    self.aps:setVolume(0)
    self.left = 1
    self.right = 1


    local hitmarker = hitMarkerGet
	self.hm = gfx.sprite.new(hitmarker)
    self.hm:setImageDrawMode(gfx.kDrawModeNXOR)
	self.hm:add()
	self.hm:setVisible(false)

    self.ID = ID
end

function Plane:volume()
    if(self.aps~=nil) then 
        self:audioLocation()
        self.aps:setVolume(self.left,self.right)
        self.aps:setRate(self.rate.value)
    end
end

function Plane:stopAudio()
    if(self.aps~=nil) then 
      self.aps:stop()
    end
end

function Plane:setPlaneAudioPause(pause)
    if(self.aps~=nil) then 
        self.aps:setPaused(pause)
      end
end



function Plane:secondStageTimer()
        --self.scaleSize2 = playdate.timer.new(secondStageTime, 500, 50000, playdate.easingFunctions.inExpo)
        self.distance = playdate.timer.new(secondStageTime, 750, 0, playdate.easingFunctions.inExpo)
end

function Plane:getSide()
    return self.realX
end

function Plane:getUp()
    return self.realY
end





--[[function Plane:incrementScale(x,y,x2,y2)
    local dummySend = 0

    if(self.scaleSize.value/1000 <.5) then
        self:setScale(self.scaleSize.value/1000)
        self:setCollideRect(x,y,x2,y2)
        dummySend = self.scaleSize.value/1000

    elseif(self.scaleSize.value/1000 >=.5) then
        if(self.scaleSize2 == nil) then 
             self:secondStageTimer()
        end
       self:setScale(self.scaleSize2.value/1000)
       dummySend = self.scaleSize.value/1000
    end

    if(self.dummyPlane ~= nil) then
        self.dummyPlane:incrementScale(dummySend)
        self.dummyPlane:setCollideRect(x,y,x2,y2)
    end
    
end
--]]

function Plane:advanceSprite()
    if self.offsetNum > 0 then
        if self.offsetBool == true then
			self.offsetBool = false
			
            self.imageNum += 1
            local x = self:getSize(width)
            local y = self:getSize(height)*.2
            

            self:setImage(self.imageTable[self.imageNum])
            self:setCollideRect(0,0,x,y)
            if(self.dummyPlane ~= nil) then
                self.dummyPlane:advanceSprite()
                
            end
            
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
        if(self.dummyPlane ~= nil) then
            self.dummyPlane:advanceSprite()
            
        end
    end
    

    --if(self.dummyPlane ~= nil) then
   --     self.dummyPlane:advanceSprite(a)
    --end
    --print(self.imageNum .. " == " .. self.ID)
end
function Plane:setSprite(a)
    self.imageNum = a
    local x = self:getSize(width) 
    local y = self:getSize(height)*.2
    local ystart = self:getSize(height) *.2

    --self:setImage(self.imageTable[self.imageNum])
    self:setImage(self.imageTable[self.imageNum])
    self:setCollideRect(0,ystart,x,y)

    --if(self.dummyPlane ~= nil) then
   --     self.dummyPlane:advanceSprite(a)
    --end
    --print(self.imageNum .. " == " .. self.ID)
end



function Plane:audioLocation()
    --clamps plane location to 1600
    if(self.realX > 1600) then self.newNum = self.realX - 1600 else self.newNum = self.realX end

    self.newNum2 = self.newNum - playerMain.side
    --clamps difference to 1600
    if(self.newNum2 < 0) then self.newNum2 += 1600 end
    
    
    if(self.newNum2 >=0 and self.newNum2 < 400) then
        --front right zone
        self.right=self.volumeLevel.value
        self.left=self.volumeLevel.value*mapping(self.newNum2, 0,400,1,0)
    elseif(self.newNum2 >=400 and self.newNum2 < 800) then
        --back left zone
        self.right=self.volumeLevel.value*mapping(self.newNum2, 400,800,1,.5)
        self.left=self.volumeLevel.value*mapping(self.newNum2, 400,800,0,.5)
    elseif(self.newNum2 >=800 and self.newNum2 < 1200) then
        --back left zone
        self.right=self.volumeLevel.value*mapping(self.newNum2, 1200,800,0,.5)
        self.left=self.volumeLevel.value*mapping(self.newNum2, 1200,800,1,.5)

    elseif(self.newNum2 >=1200 and self.newNum2 < 1600) then
        --front left zone
        self.right=self.volumeLevel.value*mapping(self.newNum2, 1600,1200,1,0)
        self.left=self.volumeLevel.value
    end
end

function Plane:setPosition(x, y)
    self:moveTo(x,y)
    self.hm:moveTo(x,y)
end



function Plane:damage(num)
    self.health = self.health - num
    self.hm:setVisible(true)
    self:checkHealth()
end

function Plane:checkHealth()
    if(self.health < 0) then
        self:destroy()
    end
end

function Plane:resetHMScale()
    self.hm:setVisible(false)
end

function Plane:tableCount()
    count = 0
    for k, v in pairs(self.planeArrayP) do
        count +=1
    end
end


function Plane:destroy()
    if(self.dummyPlane ~= nil) then 
            self.dummyPlane:destroy(self.radarDistance.value)
    end

    for k, v in pairs(self.planeArrayP) do
        if v == self then
            table.remove(self.planeArrayP, k)

            if(getGameOver()==false) then 
                scorePoint()
            end

            self.hm:setVisible(false)
            self.exp = explosion(self.realX, self.realY, self:getZIndex(), mapping(self.radarDistance.value, 1000, 0,.01,2))--.05,2,.4,20
            self:stopAudio()
            self.expSound:setVolume(mapping(self.radarDistance.value, 1000, 0, 0.01, .85))
            self.expSound:play()
            addAnimation(self.exp)
            self:remove()
        end
    end
end
