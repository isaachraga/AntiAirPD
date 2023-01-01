
import "CoreLibs/timer"
import "explosion"
local pd <const> = playdate
local gfx <const> = pd.graphics
planeTime = 30000
secondStageTime = 550




class('Plane').extends(gfx.sprite)

function Plane:init(x, y, d, s, a, dummy, xa, ya, pscore, pm, ID)
    Plane.super.init(self)
    expSound = aps
    local image = gfx.image.new("images/plane")
    self.scaleSize = playdate.timer.new(planeTime-secondStageTime, 50, 500, playdate.easingFunctions.inExpo)
    self.scaleSize2 = nil
    self.distance = playdate.timer.new(planeTime-secondStageTime, 1000, 750, playdate.easingFunctions.inExpo)
    self.radarDistance = playdate.timer.new(planeTime, 1000, 0, playdate.easingFunctions.linear)
    self.a = a
    self:setImageDrawMode("copy")
    self.score = pscore
   
    self.health = 100

    --self:moveTo(x,y)
    --self:moveTo(200, 120)
    --self.rx = 200
    self.rx = xa
    self.ry = ya
    self:setImage(image)
    self:setScale(self.scaleSize.value/1000)
    self:setCollideRect(0,0,self:getSize())
    self.pm = pm
    if(dummy ~= nil) then
        self.dummyPlane = dummy
    end


    --invert h
    local hitmarker = gfx.image.new("images/HitMarker")
   
	self.hm = gfx.sprite.new(hitmarker)
    self.hm:setImageDrawMode(gfx.kDrawModeNXOR)
    
    
    
	
	--playerSprite:setScale(planeScale)
	self.hm:add()
	--self.hm.setZIndex=32767
	self.hm:setVisible(false)
    
    self.ID = ID
    
end

function Plane:secondStageTimer()

        self.scaleSize2 = playdate.timer.new(secondStageTime, 500, 50000, playdate.easingFunctions.inExpo)
        self.distance = playdate.timer.new(secondStageTime, 750, 0, playdate.easingFunctions.inExpo)

    
end

function Plane:getSide()
    
    return self.rx
end

function Plane:getUp()
    
    return self.ry
end





function Plane:incrementScale()
    if(self.scaleSize.value/1000 <.5) then
        self:setScale(self.scaleSize.value/1000)
    elseif(self.scaleSize.value/1000 >=.5) then
        if(self.scaleSize2 == nil) then 
             self:secondStageTimer()
        end
       self:setScale(self.scaleSize2.value/1000)
   end
    
end



function Plane:moveByAdjustment(x,y)
    x = x * (self.distance.value * math.sqrt(2)/1000)
    self:moveBy(x,y)
    
end

function Plane:setPosition(x, y)
    self:moveTo(x,y)
    self.hm:moveTo(x,y)
    
end



function Plane:damage(a)
    self.health = self.health - a
    self.hm:setVisible(true)
    self:checkHealth()
end

function Plane:checkHealth()
if(self.health < 0) then
    self:destroy()
end
end

function Plane:resetHMScale()
    self.hm:setVisible(false)
    

end

function Plane:tableCount()
    count = 0
    for k, v in pairs(a) do
        count +=1
    end
end


function Plane:destroy()
    
    if(self.dummyPlane ~= nil) then 
        for k, v in pairs(a) do
            if v == self.dummyPlane then
                
                table.remove(a, k)
                
                

                self.hm:setVisible(false)

                exp = explosion(self.rx, self.ry, self:getZIndex(), mapping(self:getScale(), .05, 2,.4,20))
           
                 
       
                expSound:play()
                anim:addAnimation(exp)
                --v:tableCount()
                --print("destroy//count:"..count.."//ID:"..v.ID)
                v:remove()
                
            end
        end
    end
    for k, v in pairs(a) do
        if v == self then
            
            table.remove(a, k)
           
            score = score + 1
            self.hm:setVisible(false)

            exp = explosion(self.rx, self.ry, self:getZIndex(), mapping(self:getScale(), .05, 2,.4,20))
           
            expSound:setVolume(mapping(self.radarDistance.value, 1000, 0, 0.15, 1))
       
            expSound:play()
            anim:addAnimation(exp)
            --self:tableCount()
            --print("destroy//count:"..count.."//ID:"..v.ID)
            self:remove()
            --self:destroy()
        end
    end
    
    
end
