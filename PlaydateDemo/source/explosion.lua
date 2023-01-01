import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics




class('explosion').extends(gfx.sprite)

function explosion:init(x, y, zindex, scale)
    explosion.super.init(self)
    self.frameTimer = playdate.timer.new(660,1000, 11000)
    self.exp = gfx.imagetable.new("images/Explosion")
     self.rx = x
     self.ry = y
     self.xc = self.rx
     self.yc = self.ry
     self:moveTo(self.rx, self.ry)
     self:setScale(scale)
     
        
    
    
   


    
    self:setZIndex(zindex)
    self:add()
    self:explode()
    
end

--explosions need to adjust for scale
function explosion:explode()
    
    
    if(math.floor(self.frameTimer.value/1000) < 11) then
        --self.exp:getImage(math.floor(self.frameTimer.value/1000)):drawScaled(self:screenPositionX(), self:screenPositionY(),10)
        self:setImage(self.exp:getImage(math.floor(self.frameTimer.value/1000)))
        self:moveTo(self:screenPositionX(), self:screenPositionY())
        --print("NORMALx,y: "..self.rx..","..self.ry.." |screen x,y: "..self.xd..","..self.yd.." |player x,y: ".. playerMain:getSide()..","..playerMain:getUp())
        
       
        
    else
        anim:removeAnimation(self)
        self:remove()
        
    end
end

function explosion:screenPositionX()
    --self.xd = self.rx - player:getSide() + 175
    self.xd = self.rx - playerMain:getSide() + 200
 
    
    return self.xd
end
function explosion:screenPositionY()

    self.yd = self.ry - playerMain:getUp() + 120
    
    return self.yd
end

function explosion:screenPositionCannon(x,y)
    if(x~= nil) then
        self.xc = self.xc + x
    end

    if(y~=nil) then 
        self.yc = self.yc - y
    end

    return self.xc, self.yc

end



function explosion:explodeCannon()
   -- gfx.drawText(self.x, 0,0)
    --gfx.drawText(self.y, 50,0)
    if(math.floor(self.frameTimer.value/1000) < 11) then
        --self.exp:getImage(math.floor(self.frameTimer.value/1000)):draw(self.rx, self.ry)
        self:setImage(self.exp:getImage(math.floor(self.frameTimer.value/1000)))
       self:moveTo(self:screenPositionCannon())
       --self:moveTo(self:screenPositionX(), self:screenPositionY())
       --print("x,y: "..self.rx..","..self.ry.." |screen x,y: "..self.xc..","..self.yc.." |player x,y: ".. playerMain:getSide()..","..playerMain:getUp())
        
        
    else
        anim:removeAnimation(self)
        self:remove()
        
    end
end





