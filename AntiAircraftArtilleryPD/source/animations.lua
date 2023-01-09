import "CoreLibs/graphics"
local pd <const> = playdate
local gfx <const> = pd.graphics

class('animations').extends(gfx.sprite)

local ani = {}
local aniC = {}

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

function addAnimation(e)
    table.insert(ani, e)
end


function addAnimationC(e)
    table.insert(aniC, e)
end

function removeAnim(e)
    for k, v in pairs(ani) do
        if(v == e) then
            table.remove(ani, k)
            return
        end 
    end

    for k2, v2 in pairs(aniC) do
        if(v2 == e) then
            table.remove(aniC, k2)
            return
        end
    end
end









