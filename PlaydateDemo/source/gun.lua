import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics
scale = 2



class('gun').extends(gfx.sprite)

function gun:init()
    gun.super.init(self)
    local image = gfx.image.new("images/shot")
    
    
    
    self:setImage(image)
    
    self:setZIndex(32767)
    
   


    

    
    
end

function gun:shoot()
    self:setScale(scale)
    x = math.random(20)
    y = math.random(20)
    self:moveTo(188+x, 110+y)
    self:setCollideRect(0,0,7,7)
    
    

  
end



function gun:clear()
    self:setScale(0)
    self:clearCollideRect()
end


