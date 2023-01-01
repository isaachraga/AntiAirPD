import "CoreLibs/object"

local pd <const> = playdate
local gfx <const> = pd.graphics






class('testOBJ').extends()

function testOBJ:init()
    testOBJ.super.init(self)
    variable = 2

end
function testOBJ:varChange()
   
    variable = 3

end

