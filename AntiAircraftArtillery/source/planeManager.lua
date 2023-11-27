import "plane"
import "dummyPlane"
import "CoreLibs/timer"
import "CoreLibs/object"

local pd <const> = playdate
local gfx <const> = pd.graphics
local index = 30000
local player 
local resetNum
local beep
local beepFlag = false
local ID
local planeLimit = 1

local imageTablePM

local radarBeepDistance1 = 450
local radarBeepDistance2 = 150
local noFlashing = false



class('PlaneManager').extends()
function PlaneManager:init(p, imageTableTestSend, beepGet, expSoundGet, apsGet, hitMarkerGet)
    PlaneManager.super.init(self)
    self.planeArray = {}
    self.imageTablePM = imageTableTestSend
    self.expSoundSend = expSoundGet
    self.apsSend = apsGet
    self.hitMarkerSend = hitMarkerGet

    self:resetTimer()
    resetNum = math.random(5, 10)
    player = p
    --self.imageCount = pd.timer.new(25, 0, 1, playdate.easingFunctions.linear)
    self.index = index
    self:blinkTimer1Reset()
    self:blinkTimer2Reset()

    beep = beepGet
    beep:setVolume(.5)
    beepFlag = true
    ID=0
    if(pd.getReduceFlashing()) then 
		noFlashing = true
	end
end
--[[function PlaneManager:resetImageCount()
    self.imageCount = pd.timer.new(25, 0, 1, playdate.easingFunctions.linear)
end]]--

function PlaneManager:setVolumes()
    for k,v in pairs(self.planeArray) do
        v:volume()
    end
end
function PlaneManager:stopPlaneAudio()
    for k,v in pairs(self.planeArray) do
        v:stopAudio()
    end
end
function PlaneManager:setPlaneAudioPause(pause)
    for k,v in pairs(self.planeArray) do
        v:setPlaneAudioPause(pause)
    end
end

function PlaneManager:increasePlaneLimit()
    planeLimit +=1
    --print(planeLimit)
end



function PlaneManager:incrementScale()
    
   --[[if(self.imageCount.value ==1) then
        for k,v in pairs(self.planeArray) do
            v:advanceSprite()
        end
        
   end]]--

   for k,v in pairs(self.planeArray) do
    v:advanceSprite()
end
end

function PlaneManager:tableCount()
    count = 0
    for k, v in pairs(self.planeArray) do  
            count +=1
    end
    return count
end

function PlaneManager:spawnPlane()
    --0-1600//360-120
    local xa = math.random(0, 1599)
    --local xa = 50
    -- local xa = 1400
    local ya = math.random(122, 358)
    --local ya = 358

    if(xa > 250 and xa < 1350) then
        ID+=1
        local p = Plane(self.planeArray, nil, xa, ya, ID, self.imageTablePM, self.expSoundSend, self.apsSend, self.hitMarkerSend)
        p:setPosition(xa - player:getSide() + 200, ya - player:getUp() + 120)
        p:setZIndex(index)
        p:add()
        table.insert(self.planeArray, p)

    elseif(xa >=1350) then 
        ID+=1
        local p = DummyPlane(xa-1600, ya,  ID, -1600, self.imageTablePM, self.hitMarkerSend)
        p:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p:setZIndex(index)
        p:add()

        local p2 = Plane(self.planeArray, p, xa, ya, ID, self.imageTablePM, self.expSoundSend, self.apsSend, self.hitMarkerSend)
        p2:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p2:setZIndex(index)
        p:setMainPlane(p2)
        p2:add()
        table.insert(self.planeArray, p2)

    elseif(xa <=250) then
        ID+=1
        local p = DummyPlane(xa+1600, ya, ID, 1600, self.imageTablePM, self.hitMarkerSend)
        p:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p:setZIndex(index)
        p:add()


        local p2 = Plane(self.planeArray, p, xa, ya, ID, self.imageTablePM, self.expSoundSend, self.apsSend, self.hitMarkerSend)
        p2:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p2:setZIndex(index)
        p:setMainPlane(p2)
        p2:add()
        table.insert(self.planeArray, p2)

    end
    self.index = self.index -1

end




function PlaneManager:radar()

    local x = 291
	local y = 199
    local r = 30
    gfx.drawCircleAtPoint(x, y, r)

    for k,v in pairs(self.planeArray) do

        local dr = mapping(v.radarDistance.value, 0, 1000, 0, 30)
        local da = mapping(v:getSide(), 0, 1600, 0, (2*math.pi))
	    local cx = x+dr*math.cos(da)
	    local cy = y+dr*math.sin(da)

        if(noFlashing == false) then 
            if(v.radarDistance.value < radarBeepDistance1 and v.radarDistance.value >=radarBeepDistance2) then
                if(self.bt1.value > 1) then
                    gfx.fillCircleAtPoint(cx,cy,3)
                    if(self.bt1.value == 4) then
                    self:blinkTimer1Reset()
                    end
                end
            elseif(v.radarDistance.value < radarBeepDistance2) then
                if(self.bt2.value > 1) then
                    gfx.fillCircleAtPoint(cx,cy,3)
                    if(self.bt2.value == 4) then
                    self:blinkTimer2Reset()
                    end
                end
            else
                gfx.fillCircleAtPoint(cx,cy,3)
            end

        else
            gfx.fillCircleAtPoint(cx,cy,3)
        end
    end
end

--[[function PlaneManager:movePlanes(x,y)


    for k,v in pairs(self.planeArray) do
        v:moveByAdjustment(x,y)
    end
end]]--
function PlaneManager:setPlanes(x,y)
    for k,v in pairs(self.planeArray) do
        xd = v:getSide() - x + 200
        yd = v:getUp()- y + 120 
        v:setPosition(xd,yd)
        if(v.dummyPlane~= nil) then
            xd = v.dummyPlane:getSide() - x + 200
            yd = v.dummyPlane:getUp()- y + 120 
            v.dummyPlane:setPosition(xd,yd)
        end
    end
end



function PlaneManager:getPlaneScale()
    return triggerTimer.value
end

function PlaneManager:resetPlaneHMScale()
    for k,v in pairs(self.planeArray) do
        v:resetHMScale()
        if(v.dummyPlane ~= nil) then
            v.dummyPlane:resetHMScale()
        end
    end
end
function PlaneManager:planeTrigger()
    if(triggerTimer.value/1000 >= resetNum ) then
        if(self:tableCount() < planeLimit) then--6
            self:resetTimer()
            self:spawnPlane()
            resetNum = math.random(1, 5)
        else
            self:resetTimer()
            resetNum = math.random(1, 9)
        end
        
    end
end

function PlaneManager:getIndex()
    return self.index
end

function PlaneManager:gameOverCheck()
    for k,v in pairs(self.planeArray) do
        if (v.radarDistance.value < 5) then
            return true
        else
            return false
        end
    end
end

function PlaneManager:removeAllPlanes()
    for k,v in pairs(self.planeArray) do
        v:destroy()
    end
end

function PlaneManager:setAllVisibile(visibility)
    for k,v in pairs(self.planeArray) do
        v:setVisible(visibility)
    end
end



function PlaneManager:resetTimer()
	triggerTimer = playdate.timer.new(15000,0, 15000, playdate.easingFunctions.linear)
end

function PlaneManager:blinkTimer1Reset()
	self.bt1 = playdate.timer.new(1200,0, 4, playdate.easingFunctions.linear)
    if(beepFlag)then
        beep:play()
    end
end

function PlaneManager:blinkTimer2Reset()

	self.bt2 = playdate.timer.new(75,0, 4, playdate.easingFunctions.linear)
    if(beepFlag) then
        beep:play()
    end
end

