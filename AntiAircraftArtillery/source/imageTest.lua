local pd <const> = playdate
local gfx <const> = pd.graphics






class('imageTest').extends(gfx.sprite)
--plane scale max 10 min .05
function imageTest:init(imageTableTestPMSend)
    imageTest.super.init(self)
    self.image = imageTableTestPMSend
    self:setImageDrawMode("copy")
    self.imageNum = 1
    self:setImage(self.image[self.imageNum])
end

function imageTest:advanceSprite(num)
    self.imageNum += num
    --self:setImage(self.image[self.imageNum])
    self:setImage(self.image[self.imageNum])

    --if(self.dummyPlane ~= nil) then
   --     self.dummyPlane:advanceSprite(a)
    --end
    --print(self.imageNum .. " == " .. self.ID)
end

function imageTest:setSprite(a)
    self.imageNum = a
    
    self:setImage(self.image[self.imageNum])
    --self:setCollideRect(0,ystart,x,y)

    --if(self.dummyPlane ~= nil) then
   --     self.dummyPlane:advanceSprite(a)
    --end
    --print(self.imageNum .. " == " .. self.ID)
end




