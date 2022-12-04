import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"
--import "CoreLibs/frameTimer"
import "CoreLibs/crank"
import "CoreLibs/ui"
import "CoreLibs/animation"
import "planemanager"
import "gun"
import "player"
import "cannon"
import "explosion"
import "animations"



local pd <const> = playdate
local gfx <const> = pd.graphics
anim = animations()


local xintensity = 1
local yintensity = .1


local menu = 0







--plane scalemax 10 min .05

local planeScale = 1

local function resetTimer()

	timer = playdate.timer.new(30000,0, 10000, playdate.easingFunctions.inExpo)
end

local function initialize()
	cannon = cannon()
	gun = gun()
	player = player(200, 360)
	pm = PlaneManager(timer, player, score)
	menu = 0
	startInitialize()
end

function startInitialize()
	local startImage = gfx.image.new("images/StartScreen")
	ss = gfx.sprite.new(startImage)
	ss:moveTo(200,120)
	ss:add()
	ss:setZIndex(32767)



--data store for score
	
	--start = true
	--gameOver = false
end

--*****transition back into game is a little glitchy

function gameOverInitialize()
	gfx.sprite:removeAll()
	--anim:removeAllAnimations()
	pm:removeAllPlanes()
	resetTimer()
	
end

function gameInitialize()
	e = {}
	score = 0
	--*****reset not working
	--cannon = cannon()
	cannon:add()

    --gun = gun()
	gun:add()

	--player = player(200, 360)

	--pm = PlaneManager(timer, player, score)
	pm:add()
	pm:spawnPlane(timer, 1000)
	

	local bkgd = gfx.image.new("images/bkgd")
	bg = gfx.sprite.new(bkgd)
	bg.rx=1250
	bg.ry=240
	
	bg:moveTo(800,0)
	bg:setZIndex(0)
	bg:add()


	

    local playerImage = gfx.image.new("images/ui")
	ui = gfx.sprite.new(playerImage)
	ui:moveTo(200,120)
	ui:add()
	ui:setZIndex(32767)

	local heightReticle = gfx.image.new("images/HeightReticle")
	hr = gfx.sprite.new(heightReticle)
	hr:moveTo(111,227)
	--low 227 high 171
	hr:add()
	hr:setZIndex(32767)

	resetTimer()

end



initialize()





local function gunLocation(x,y)


upcheck = player:getUp() + (y * yintensity)
sidecheck = player:getSide() + (x * xintensity)

if(upcheck <= 360 and upcheck >= 120 and x == 0) then 
	player:setUp(player:getUp() + (y * yintensity))
	pm:setPlanes(player:getSide(), player:getUp())
	cannon:setShots((x * xintensity), (y * yintensity))
	--background not moving correctly
	setBG(player:getSide(), player:getUp())
end
if (player:getSide() >= 1600) then 
	player:setSide(0)
	
elseif(player:getSide() < 0) then
	player:setSide(1599.999)
	
elseif(y == 0) then 
	player:setSide(player:getSide() - (x * xintensity))
	pm:setPlanes(player:getSide(), player:getUp())
	cannon:setShots((x * xintensity), (y * yintensity))
		--background not moving correctly
	setBG(player:getSide(), player:getUp())
end

end

function setBG(x, y)
	local xd = bg.rx - x -250
	
	local yd = bg.ry - y + 120 
	
	bg:moveTo(xd,yd)
end



local function playerControls()
	
	if((playdate.buttonIsPressed(playdate.kButtonLeft) or playdate.buttonIsPressed(playdate.kButtonRight)) and 
	(playdate.buttonIsPressed(playdate.kButtonDown) == false and playdate.buttonIsPressed(playdate.kButtonUp) == false) and playdate.getCrankChange(change) ~= 0) then
		
		gunLocation(playdate.getCrankChange(change), 0)
	elseif ((playdate.buttonIsPressed(playdate.kButtonDown) or playdate.buttonIsPressed(playdate.kButtonUp)) and 
	(playdate.buttonIsPressed(playdate.kButtonLeft) == false and playdate.buttonIsPressed(playdate.kButtonRight) == false) and playdate.getCrankChange(change) ~= 0) then
		
		gunLocation(0, playdate.getCrankChange(change))
	
	end

	if(playdate.buttonIsPressed(playdate.kButtonA)) then 
		gun:shoot() 

		
	end

	if(playdate.buttonIsPressed(playdate.kButtonB)) then 
		cannon:shoot()
	end


end



function uiSprites()
	if(playdate.buttonIsPressed(playdate.kButtonA)) then 

		gfx.fillCircleAtPoint(364,208,13)
	end

	if(playdate.buttonIsPressed(playdate.kButtonB)) then 

		gfx.fillCircleAtPoint(36,208,13)
	end
end


function shotCollisions()
	local collisions = gfx.sprite.allOverlappingSprites()

	for i = 1, #collisions do
			local collisionPair = collisions[i]
			local sprite1 = collisionPair[1]
			local sprite2 = collisionPair[2]
			-- do something with the colliding sprites
			if(sprite1:isa(Plane) and sprite2:isa(gun)) then
				sprite1:damage(5)
			elseif(sprite2:isa(Plane) and sprite1:isa(gun)) then
				sprite2:damage(5)
			end

			if(sprite1:isa(Plane) and sprite2:isa(cannonShot)) then
				sprite1:destroy()
			elseif(sprite2:isa(Plane) and sprite1:isa(cannonShot)) then
				sprite2:destroy()
			end

	end
end

function heightRet()
cyhr = mapping(player:getUp(), 360, 120, 227, 171)
hr:moveTo(111,cyhr)
end


function radar()
	local x1 = 291
	local y1 = 199
	local cx = x1+30*math.cos(mapping(player:getSide()-200, 1600, 0, (2*math.pi), 0))
	local cy = y1+30*math.sin(mapping(player:getSide()-200, 1600, 0, (2*math.pi), 0))
	gfx.drawLine(x1, y1, cx, cy)
	local cx2 = x1+30*math.cos(mapping(player:getSide()+200, 1600, 0, (2*math.pi), 0))
	local cy2 = y1+30*math.sin(mapping(player:getSide()+200, 1600, 0, (2*math.pi), 0))
	gfx.drawLine(x1, y1, cx2, cy2)
	
	
end

function mapping(input, flb, fub, llb, lub)
    output = (input-flb)/(fub-flb) * (lub-llb) + llb
    return output
end

function crankDock()
	if(playdate.isCrankDocked()) then
		playdate.ui.crankIndicator:start()
		playdate.ui.crankIndicator:update()
	end

end

function cannonCheck()
	if(cannon.cannonTimer.value == cannon.timerMax) then
		cannon.flag = true
	end
	if(cannon.cannonTimer.value > 1) then
		cannon:clear()
	end
end

function cannonUI()
	gfx.fillRect(52,mapping(cannon.cannonTimer.value, 5, 0, 193, 233),5,29)
end

function gameOverCheck()
	if (pm:gameOverCheck() == true and menu == 1) then
		menu = 2 
	
		gameOverInitialize()
		
	end
end

function startUpdate()
	gfx.sprite.update()
	--gfx.drawText("hello there", 172, 210)

	if pd.buttonJustPressed(pd.kButtonA) then
		gameInitialize()
		ss:remove()
		menu = 1
	end

end

function gameOverUpdate()
	gfx.sprite.update()
	gfx.fillRect(0,0,400,240)
	if pd.buttonJustPressed(pd.kButtonA) then
		gameInitialize()
		menu = 1 
		
		
		
	end

end




function gameUpdate()

	playdate.timer.updateTimers()
	--playdate.frameTimer.updateTimers()

	gameOverCheck()

	playerControls()
	pm:incrementScale()
	pm:planeTrigger()
	shotCollisions()

	gfx.sprite.update()
	cannonCheck()
	anim:playAnimations()

	uiSprites()
	gfx.drawText(string.format("%06d", score), 172, 210)

	gun:clear()
	pm:resetPlaneHMScale()
	pm:radar()
	radar()
	heightRet()
	cannonUI()

	--gfx.fillRect(52,193,5,29)
	--gfx.fillRect(52,223,5,29)
	
	--gfx.drawText(math.floor(frameTimer.value/1000), 0,0)
	--gfx.drawText(player:getUp(), 0,20)
	--gfx.drawText(bg.y, 0,0)
	--gfx.drawText(player:getSide(), 70,20)
	--gfx.drawText(cannon.cannonTimer.value, 70,0)
	crankDock()
    
end

function pd.update()
	if(menu == 0) then
		startUpdate()
	elseif(menu == 2) then
		gameOverUpdate()
	else
		gameUpdate()
	end

end