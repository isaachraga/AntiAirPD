import "CoreLibs/graphics"
import "cannonShot"

local pd <const> = playdate
local gfx <const> = pd.graphics
cscale = 20
local image



class('cannon').extends(gfx.sprite)

function cannon:init()
    self.shots = {}
    for i = 1,7 do
        x = 20+math.random(360)
        y = 20+math.random(140)
        
        local cannonShot = cannonShot(x,y)
        
        cannonShot:add()
        table.insert(self.shots, cannonShot)
    end
     
  
end

function cannon:shoot()

    for k, v in pairs(self.shots) do 
    v:setScale(cscale)
    x = 20+math.random(360)
    y = 20+math.random(140)
    v:moveTo(x,y)
    v:setPos(x, y)
    v:setCollideRect(0,0,20,20)

    end
    
    

  
end

function cannon:setShots(x,y)
    

    for key,value in pairs(self.shots) do
        local xd = value:getSide() + x
        local yd = value:getUp()- y
   
        value:setPos(xd,yd)
    end
end


function cannon:clear()
    --self:setScale(0)
    --self:clearCollideRect()
end