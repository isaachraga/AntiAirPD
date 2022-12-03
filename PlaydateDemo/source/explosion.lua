import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics




class('explosion').extends(gfx.sprite)

function explosion:init(x, y, zindex, scale)
    self.frameTimer = playdate.timer.new(480,1000, 11000)
    self.exp = gfx.imagetable.new("images/Explosion")
     self.rx = x
     self.ry = y
     self:moveTo(x, y)
     self:setScale(scale)
     
        
    
    
   


    
    self:setZIndex(zindex)
    self:add()
    self:explode()
    
end

--explosions need to adjust for scale
function explosion:explode()
    gfx.drawText(self.x, 0,0)
    gfx.drawText(self.y, 50,0)
    if(math.floor(self.frameTimer.value/1000) < 11) then
        --self.exp:getImage(math.floor(self.frameTimer.value/1000)):drawScaled(self:screenPositionX(), self:screenPositionY(),10)
        self:setImage(self.exp:getImage(math.floor(self.frameTimer.value/1000)))
        self:moveTo(self:screenPositionX(), self:screenPositionY())
       
        
    else
        anim:removeAnimation(self)
        self:remove()
        
    end
end

function explosion:screenPositionX()
    --self.xd = self.rx - player:getSide() + 175
    self.xd = self.rx - player:getSide() + 200
 
    
return self.xd
end
function explosion:screenPositionY()

    self.yd = self.ry - player:getUp() + 120
    
return self.yd
end

function explosion:explodeCannon()
   -- gfx.drawText(self.x, 0,0)
    --gfx.drawText(self.y, 50,0)
    if(math.floor(self.frameTimer.value/1000) < 11) then
        --self.exp:getImage(math.floor(self.frameTimer.value/1000)):draw(self.rx, self.ry)
        self:setImage(self.exp:getImage(math.floor(self.frameTimer.value/1000)))
        self:moveTo(self.rx, self.ry)
        
        
    else
        anim:removeAnimation(self)
        self:remove()
        
    end
end





