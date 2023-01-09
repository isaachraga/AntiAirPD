import "plane"
import "dummyPlane"
import "CoreLibs/timer"
import "CoreLibs/object"

local pd <const> = playdate
local gfx <const> = pd.graphics
local index = 30000
local player 


local radarBeepDistance1 = 450
local radarBeepDistance2 = 150
local noFlashing = false








class('PlaneManager').extends()





function PlaneManager:init(p)
    PlaneManager.super.init(self)
    irBeep = false
    a = {}

    self:resetTimer()

    resetNum = math.random(5, 10)
    player = p
    self.index = index
    
    self:blinkTimer1Reset()
    self:blinkTimer2Reset()
    rBeep = pd.sound.sampleplayer.new("sounds/Beep")
    rBeep:setVolume(.5)
    
    irBeep = true
    ID=0
    if(pd.getReduceFlashing()) then 
		noFlashing = true
	end
    
    
end

function PlaneManager:setVolumes()
    for k,v in pairs(a) do

        v:volume()
        
    end
end
function PlaneManager:stopPlaneAudio()
    for k,v in pairs(a) do

        v:stopAudio()
        
    end
end

function PlaneManager:checkPlaneAudio()
    for k,v in pairs(a) do

        v:volumePrint()
        
    end
end

function PlaneManager:incrementScale()
    for k,v in pairs(a) do
        local x, y, ystart
        x = v:getSize(width) 
        y = v:getSize(height)*.2
        ystart = v:getSize(height) *.2

        v:incrementScale(0,ystart,x,y)
        

    end
end

function PlaneManager:tableCount()
    count = 0
    for k, v in pairs(a) do  
            count +=1
    end
    return count
end

function PlaneManager:spawnPlane()

    --0-1600//360-120
    local xa = math.random(0, 1599)
    local ya = math.random(122, 358)

  
    
    if(xa > 250 and xa < 1350) then
        ID+=1
        local p = Plane(a, nil, xa, ya, ID)
        p:setPosition(xa - player:getSide() + 200, ya - player:getUp() + 120)
        p:setZIndex(index)
        p:add()
        table.insert(a, p)

        
    elseif(xa >=1350) then 
        ID+=1
        local p = DummyPlane(xa-1600, ya,  ID, -1600)
        p:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p:setZIndex(index)
        p:add()

        
        
        local p2 = Plane(a, p, xa, ya, ID)
        p2:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p2:setZIndex(index)
        p:setMainPlane(p2)
        p2:add()
        table.insert(a, p2)

        
        
    elseif(xa <=250) then
        ID+=1
        local p = DummyPlane(xa+1600, ya, ID, 1600)
        p:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p:setZIndex(index)
        p:add()


        
        
        local p2 = Plane(a, p, xa, ya, ID)
        p2:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p2:setZIndex(index)
        p:setMainPlane(p2)
        p2:add()
        table.insert(a, p2)

        
        

    end
    self.index = self.index -1
    --print("Spawn: "..ID)

end




function PlaneManager:radar()

    local x = 291
	local y = 199
    local r = 30
    gfx.drawCircleAtPoint(x, y, r)

    for k,v in pairs(a) do

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

function PlaneManager:movePlanes(x,y)


    for k,v in pairs(a) do
        v:moveByAdjustment(x,y)
    end
end
function PlaneManager:setPlanes(x,y)
    

    for k,v in pairs(a) do
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
    for k,v in pairs(a) do
        v:resetHMScale()
        if(v.dummyPlane ~= nil) then
            v.dummyPlane:resetHMScale()
        end
    end
end
function PlaneManager:planeTrigger()
    
    if(triggerTimer.value/1000 >= resetNum ) then
        if( self:tableCount() < 8) then
            self:resetTimer()
            self:spawnPlane()
            resetNum = math.random(1, 7)
        else
            self:resetTimer()
            resetNum = math.random(1, 7)
        end
    end
end

function PlaneManager:getIndex()
    return self.index
end

function PlaneManager:gameOverCheck()
    for k,v in pairs(a) do
        if v.radarDistance.value < 5 then

            return true
        else
            
            return false
        end
    end
end

function PlaneManager:removeAllPlanes()
    for k,v in pairs(a) do
        v:destroy()
    end
end

function PlaneManager:setAllVisibile(visibility)
    for k,v in pairs(a) do
        v:setVisible(visibility)
    end
end



function PlaneManager:resetTimer()

	triggerTimer = playdate.timer.new(15000,0, 15000, playdate.easingFunctions.linear)
end

function PlaneManager:blinkTimer1Reset()

	self.bt1 = playdate.timer.new(1200,0, 4, playdate.easingFunctions.linear)
    if(irBeep) then
        rBeep:play()
    end
end

function PlaneManager:blinkTimer2Reset()

	self.bt2 = playdate.timer.new(75,0, 4, playdate.easingFunctions.linear)
    if(irBeep) then
        rBeep:play()
    end
end

