import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics




class('explosion').extends(gfx.sprite)

function explosion:init(x, y, zindex)
    self.frameTimer = playdate.timer.new(480,1000, 11000)
    self.exp = gfx.imagetable.new("images/Explosion")
     self.rx = x
     self.ry = y
        
    
    
   


    
    self:setZIndex(zindex)
    self:add()
    
end

--explosions need to play, not set up yet
function explosion:explode()
    if(math.floor(self.frameTimer.value/1000) < 11) then
        self.exp:getImage(math.floor(self.frameTimer.value/1000)):draw(20,20)
    else
        self:remove()
    end
end





