import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics

class('animations').extends(gfx.sprite)

local ani = {}
local aniC = {}

function animations:addAnimation(e)
    table.insert(ani, e)
end

function animations:addAnimationC(e)
    table.insert(aniC, e)
end


function animations:playAnimations()

        for k, v in pairs(ani) do
            v:explode()
        end
    

 
        for k2, v2 in pairs(aniC) do
            v2:explodeCannon()
        end
        


    
end

function animations:moveAnimations(x,y)
    for k, v in pairs(aniC) do
        v:screenPositionCannon(x,y)
    end
end

function animations:removeAnimation(e)
    for k, v in pairs(ani) do
        if(v == e) then
            table.remove(ani, k)
        end 
    end

    for k, v in pairs(aniC) do
        if(v == e) then
            table.remove(aniC, k)
        end 
    end

    
end







function animations:removeAllAnimations()
    for k, v in pairs(ani) do
            table.remove(ani, k)
    end
    for k, v in pairs(aniC) do
        table.remove(aniC, k)
end
end
