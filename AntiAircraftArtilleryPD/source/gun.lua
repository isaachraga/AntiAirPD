import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics
local scale = 2



class('gun').extends(gfx.sprite)

function gun:init()
    gun.super.init(self)
    self:setZIndex(32767)

end

function gun:shoot()
    x = math.random(20)+188
    y = math.random(20)+110
    gfx.fillRect(x,y,scale,scale)

    self:setCollideRect(x,y,7,7)
end



function gun:clear()
    self:clearCollideRect()
end


