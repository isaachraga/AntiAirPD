import "CoreLibs/graphics"
import "cannonShot"
import "CoreLibs/timer"
import "CoreLibs/object"

local pd <const> = playdate
local gfx <const> = pd.graphics
cscale = 20
local image




class('cannon').extends()

function cannon:init()
    cannon.super.init(self)

    self.flag = true
    self.timerMax = 5
    self:initTimer()

    self.shots = {}
    for i = 1,7 do
        x = 20+math.random(360)
        y = 20+math.random(140)
        
        local cannonShot = cannonShot(x,y)
        
        cannonShot:add()
        table.insert(self.shots, cannonShot)
    end
     
  
end

function cannon:initTimer()
    self.cannonTimer = playdate.timer.new(0,self.timerMax, self.timerMax)
end

function cannon:resetTimer()
    self.cannonTimer = playdate.timer.new(self.timerMax*1000,0, self.timerMax)
end


function cannon:shoot()

    if(self.flag == true) then 
        for k, v in pairs(self.shots) do
            sca = math.random(20)/10+.5
            v:setScale(sca)
            x = 100+math.random(200)
            y = 20+math.random(150)

            v:moveTo(x,y)
            v:setPos(x, y)
            v:setCollideRect(-10*sca, -10*sca, 20*sca, 20*sca)
            
            
            exp = explosion(x, y, 32764,sca)
            
            anim:addAnimationC(exp)
        end
        self.flag = false
        self:resetTimer()
    end

end

function cannon:setShots(x,y)
 

    for key,value in pairs(self.shots) do
        local xd = value:getSide() + x
        local yd = value:getUp()- y

        value:setPos(xd,yd)
    end
    
end

function cannon:moveShots(x,y)
    for k, v in pairs(self.shots) do
        v:screenPositionCannon(x,y)
    end
end


function cannon:clear()
    --self:setScale(0)
    for key,value in pairs(self.shots) do
        value:clearCollideRect()
    end
    
end