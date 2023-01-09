import "CoreLibs/timer"
import "explosion"
local pd <const> = playdate
local gfx <const> = pd.graphics
local planeTime = 30000
local secondStageTime = 550




class('Plane').extends(gfx.sprite)
--plane scale max 10 min .05
function Plane:init(a, dummy, xa, ya, ID)
    Plane.super.init(self)

    expSound = ape
    local image = gfx.image.new("images/plane")
    self.scaleSize = playdate.timer.new(planeTime-secondStageTime, 50, 500, playdate.easingFunctions.inExpo)
    self.scaleSize2 = nil
    self.distance = playdate.timer.new(planeTime-secondStageTime, 1000, 750, playdate.easingFunctions.inExpo)
    self.radarDistance = playdate.timer.new(planeTime, 1000, 0, playdate.easingFunctions.linear)
    self.a = a
    self:setImageDrawMode("copy")
    
    self.health = 100

    self.rx = xa
    self.ry = ya
    self:setImage(image)
    self:setScale(self.scaleSize.value/1000)
    self:setCollideRect(0,0,self:getSize())

    

    if(dummy ~= nil) then
        self.dummyPlane = dummy 
    end

    self.rate = playdate.timer.new(planeTime, .7, 1.4, playdate.easingFunctions.inExpo)
    self.volumeLevel = playdate.timer.new(planeTime, 0, 1.5, playdate.easingFunctions.inQuart)
    self.aps = pd.sound.sampleplayer.new("sounds/AirplaneLoop")
    self.aps:play(0, self.rate.value)
    self.aps:setVolume(0)
    self.left = 1
    self.right = 1

    local hitmarker = gfx.image.new("images/HitMarker")
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



function Plane:secondStageTimer()

        self.scaleSize2 = playdate.timer.new(secondStageTime, 500, 50000, playdate.easingFunctions.inExpo)
        self.distance = playdate.timer.new(secondStageTime, 750, 0, playdate.easingFunctions.inExpo)

    
end

function Plane:getSide()
    
    return self.rx
end

function Plane:getUp()
    
    return self.ry
end





function Plane:incrementScale(x,y,x2,y2)
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
        --print("ScalePPP"..self.scaleSize.value.."||"..dummySend)
        self.dummyPlane:incrementScale(dummySend)
        self.dummyPlane:setCollideRect(x,y,x2,y2)
    end
    
end


function Plane:audioLocation()
    --clamps plane location to 1600
    if(self.rx > 1600) then self.newNum = self.rx - 1600 else self.newNum = self.rx end

    self.newNum2 = self.newNum - playerMain.side
    --clamps difference to 1600
    if(self.newNum2 < 0) then self.newNum2 += 1600 end
    
    
    if(self.newNum2 >=0 and self.newNum2 < 400) then
        self.right=self.volumeLevel.value
        self.left=self.volumeLevel.value*mapping(self.newNum2, 0,400,1,0)
    elseif(self.newNum2 >=400 and self.newNum2 < 800) then
        self.right=self.volumeLevel.value*mapping(self.newNum2, 400,800,1,.5)
        self.left=self.volumeLevel.value*mapping(self.newNum2, 400,800,0,.5)

    elseif(self.newNum2 >=800 and self.newNum2 < 1200) then
        self.right=self.volumeLevel.value*mapping(self.newNum2, 1200,800,0,.5)
        self.left=self.volumeLevel.value*mapping(self.newNum2, 1200,800,1,.5)

    elseif(self.newNum2 >=1200 and self.newNum2 < 1600) then
        self.right=self.volumeLevel.value*mapping(self.newNum2, 1600,1200,1,0)
        self.left=self.volumeLevel.value
    end
end

function Plane:setPosition(x, y)
    self:moveTo(x,y)
    self.hm:moveTo(x,y)
    
    
end



function Plane:damage(a)
    self.health = self.health - a
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
    for k, v in pairs(a) do
        count +=1
    end
end


function Plane:destroy()
    
    if(self.dummyPlane ~= nil) then 
       
            self.dummyPlane:destroy()
    end

    for k, v in pairs(a) do
        if v == self then
            
            table.remove(a, k)
            if(getGameOver()==false) then 
                score = score + 1
            end
            self.hm:setVisible(false)

            exp = explosion(self.rx, self.ry, self:getZIndex(), mapping(self:getScale(), .05, 2,.4,20))
            self:stopAudio()
            expSound:setVolume(mapping(self.radarDistance.value, 1000, 0, 0.01, .85))
            expSound:play()
            addAnimation(exp)
            self:remove()
        end
    end
end
