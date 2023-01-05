import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics
cscale = 20
local image



class('cannonShot').extends(gfx.sprite)

function cannonShot:init(x, y)
    cannonShot.super.init(self)
    --explosion animation


     
        
    self.rx = x
    self.ry = y
    self:moveTo(x, y)
    
    
    --self:setImage(image)
    
    self:setZIndex(32766)
    
   


    

    
    
end

function cannonShot:setPos(x, y)
    self.rx = x
    self.ry = y
    self:moveTo(x, y)
end

function cannonShot:screenPositionCannon(x,y)
    self:moveBy(x, y)
    --if(x~= nil) then
     --   self.rx = self.rx + x
   -- end

   -- if(y~=nil) then 
    --    self.ry = self.ry - y
   -- end
    
    

end


function cannonShot:getSide()
return self.rx
end

function cannonShot:getUp()
return self.ry
end



