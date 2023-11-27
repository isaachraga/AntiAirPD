import "CoreLibs/graphics"
import "cannonShot"
import "CoreLibs/timer"
import "CoreLibs/object"

local pd <const> = playdate
local gfx <const> = pd.graphics





class('cannon').extends()

function cannon:init()
    cannon.super.init(self)
    self.flag = true
    self.timerMax = 15
    self.cannonTimer = playdate.timer.new(0,self.timerMax, self.timerMax)

    self.shots = {}
    for i = 1,7 do
        x = 20+math.random(360)
        y = 20+math.random(140)
        
        local cannonShot = cannonShot(x,y)
        
        cannonShot:add()
        table.insert(self.shots, cannonShot)
    end
     
  
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
            
            addAnimationC(exp)
        end
        self.flag = false
        self:resetTimer()
    end

end

function cannon:setShots(x,y)
 

    for k,v in pairs(self.shots) do
        local xd = v:getSide() + x
        local yd = v:getUp()- y

        v:setPos(xd,yd)
    end
    
end

function cannon:moveShots(x,y)
    for k, v in pairs(self.shots) do
        v:screenPositionCannon(x,y)
    end
end


function cannon:clear()
    for k,v in pairs(self.shots) do
        v:clearCollideRect()
    end
    
end