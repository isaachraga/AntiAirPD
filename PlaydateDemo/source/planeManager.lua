import "plane"
import "CoreLibs/timer"

local pd <const> = playdate
local gfx <const> = pd.graphics
local index = 30000
local player 
local score







class('PlaneManager').extends(gfx.sprite)

function PlaneManager:resetTimer()

	triggerTimer = playdate.timer.new(15000,0, 15000, playdate.easingFunctions.linear)
end

function PlaneManager:init(time, p, pscore)
    a = {}
    --e = {}
    self:resetTimer()
    --multi stage random
    resetNum = math.random(5, 10)
    player = p
    self.index = index
    score = pscore
    
    
end

function PlaneManager:incrementScale()
    for key,value in pairs(a) do

        value:incrementScale()
        local x, y, ystart
        x = value:getSize(width) 
        y = value:getSize(height)*.2
        ystart = value:getSize(height) *.2
        value:setCollideRect(0,ystart,x,y)

    end
end

function PlaneManager:spawnPlane(time, d, s)
    --0-1600//360-120
    local xa = math.random(0, 1599)
    local ya = math.random(122, 358)
    
    if(xa > 250 and xa < 1350) then
        local p = Plane(x, y, d, s, a, dummy, xa, ya, score, self)
        p:setPosition(xa - player:getSide() + 200, ya - player:getUp() + 120)
        p:setZIndex(index)
        p:add()
        table.insert(a, p)
        
    elseif(xa >=1350) then 
        local p = Plane(x, y, d, s, a, dummy, xa-1600, ya, score, self)
        p:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p:setZIndex(index)
        p:add()
        table.insert(a, p)
        
        local p2 = Plane(x, y, d, s, a, p, xa, ya, score, self)
        p2:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p2:setZIndex(index)
        p2:add()
        table.insert(a, p2)
        
    elseif(xa <=250) then
        local p = Plane(x, y, d, s, a, dummy, xa+1600, ya, score,self)
        p:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p:setZIndex(index)
        p:add()
        table.insert(a, p)
        
        local p2 = Plane(x, y, d, s, a, p, xa, ya, score, self)
        p2:setPosition(xa - player:getSide() + 200,  ya - player:getUp() + 120)
        p2:setZIndex(index)
        p2:add()
        table.insert(a, p2)
        

    end
    self.index = self.index -1
    
end

function PlaneManager:addScore(points)
 self.score = self.score + points
end


function PlaneManager:radar()

    local x = 291
	local y = 199
    local r = 30
    gfx.drawCircleAtPoint(x, y, r)

    for key,value in pairs(a) do

        local dr = PlaneManager:mapping(value.radarDistance.value, 0, 1000, 0, 30)
        local da = PlaneManager:mapping(value:getSide(), 0, 1600, 0, (2*math.pi))
	    local cx = x+dr*math.cos(da)
	    local cy = y+dr*math.sin(da)
	    gfx.fillCircleAtPoint(cx,cy,3)
    end
    
	

    
end

function PlaneManager:mapping(input, flb, fub, llb, lub)
    output = (input-flb)/(fub-flb) * (lub-llb) + llb
    return output
end



function PlaneManager:movePlanes(x,y)
    --if less than total map dimensions

    for key,value in pairs(a) do
    value:moveByAdjustment(x,y)
    end
end
function PlaneManager:setPlanes(x,y)
    

    for key,value in pairs(a) do
        xd = value:getSide() - x + 200
        yd = value:getUp()- y + 120 
    value:setPosition(xd,yd)
    end
end



function PlaneManager:getPlaneScale()
    return triggerTimer.value
    
end

function PlaneManager:resetPlaneHMScale()
    for key,value in pairs(a) do
        value:resetHMScale()
    end
end
function PlaneManager:planeTrigger()
    
    if(triggerTimer.value/1000 >= resetNum) then
        self:resetTimer()
        self:spawnPlane(1000)
        resetNum = math.random(5, 10)
    end
end

function PlaneManager:getIndex()
    return self.index
end

function PlaneManager:gameOverCheck()
    for key,value in pairs(a) do
        if value.radarDistance.value < 75 then
            self:removeAllPlanes()
            return true
        else
            
            return false
        end
    end
end

function PlaneManager:removeAllPlanes()
    for key,value in pairs(a) do
        table.remove(a, key)
    end
end

function PlaneManager:setAllVisibile(value)
    for key,value in pairs(a) do
        value:setVisible(value)
    end
end