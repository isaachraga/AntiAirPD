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
local highscore = {}

local option = 0

test = 50
knum1= 0
knum2 = 0
lastMenu = 0


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

	
if(pd.datastore.read(data) == nil) then
	table.insert(highscore, 0)
	pd.datastore.write(highscore, data)

	


end
	
	--gfx.drawText(tostring(pd.datastore.read(data)), 0,0)



--data store for score
	

end

--*****transition back into game is a little glitchy

function gameOverInitialize()
	gfx.sprite:removeAll()
	--anim:removeAllAnimations()
	pm:removeAllPlanes()
	resetTimer()
	local endImage = gfx.image.new("images/GameOver")
	gg = gfx.sprite.new(endImage)
	gg:moveTo(200,120)
	gg:add()
	gg:setZIndex(32767)


	testTable = pd.datastore.read(data)
	for k,v in pairs(testTable) do
		--start of table
		if(k == 1)then
			if(v < score)then
				table.insert(highscore, score)
				pd.datastore.write(highscore, data)
				
			end

		end
		
	end
	
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
	gfx.drawText("Start", 35, 210)
	gfx.drawText("Controls", 125, 210)
	gfx.drawText("Options", 235, 210)
	gfx.drawText("Exit", 335, 210)
	

	if(option == 0) then
		gfx.drawRect(30, 205, 49, 27)
		if(pd.buttonJustPressed(pd.kButtonA))then
			gameInitialize()
			ss:remove()
			menu = 1
		end
		
	elseif(option == 1) then
		gfx.drawRect(120, 205, 72, 27)
		if(pd.buttonJustPressed(pd.kButtonA))then
			ss:setVisible(false)
			
			lastMenu = menu
			menu = 3
		end


	elseif(option == 2) then
		gfx.drawRect(230, 205, 64, 27)
		--options

	elseif(option == 3) then
		gfx.drawRect(330, 205, 37, 27)
		--exit

	end

	if pd.buttonJustPressed(pd.kButtonRight) then
		if(option == 3) then 
			option = 0
		else
		option += 1
		end
	end
	if pd.buttonJustPressed(pd.kButtonLeft) then
		if(option == 0) then 
			option = 3
		else
		option -= 1
		end
	end
	

	
	if pd.buttonJustPressed(pd.kButtonB) then
		
		pd.datastore.delete(data)
	end

end

function gameOverUpdate()
	gfx.sprite.update()
	--gfx.fillRect(0,0,400,240)

	newtable = pd.datastore.read(data)
	for k,v in pairs(newtable) do
		gfx.drawText("High Score: " .. tostring(v), 150,120)
	end
	

	gfx.drawText("Restart", 35, 210)
	gfx.drawText("Controls", 125, 210)
	gfx.drawText("Options", 235, 210)
	gfx.drawText("Exit", 335, 210)
	

	if(option == 0) then
		gfx.drawRect(30, 205, 72, 27)
		if(pd.buttonJustPressed(pd.kButtonA))then
			gg:remove()
			gameInitialize()
			
			menu = 1
		end
		
	elseif(option == 1) then
		gfx.drawRect(120, 205, 72, 27)
		if(pd.buttonJustPressed(pd.kButtonA))then
			gg:setVisible(false)
			
			lastMenu = menu
			menu = 3
		end

	elseif(option == 2) then
		gfx.drawRect(230, 205, 64, 27)
		--options

	elseif(option == 3) then
		gfx.drawRect(330, 205, 37, 27)
		--exit

	end

	if pd.buttonJustPressed(pd.kButtonRight) then
		if(option == 3) then 
			option = 0
		else
		option += 1
		end
	end
	if pd.buttonJustPressed(pd.kButtonLeft) then
		if(option == 0) then 
			option = 3
		else
		option -= 1
		end
	end

end


function controlsUpdate()
	gfx.drawText("(Up OR Down) + Crank ====== Veritcal Aim", 25, 35)
	gfx.drawText("(Left OR Right) + Crank ==== Horizontal Aim", 25, 62)
	gfx.drawText("A ========================= Fire Machine Gun", 25, 89)
	gfx.drawText("B ========================= Fire Cannon", 25, 116)

	gfx.drawText("PRESS B TO RETURN", 140, 210)

	if(pd.buttonJustPressed(pd.kButtonB))then
		if(lastMenu == 0) then
			ss:setVisible(true)
		elseif(lastMenu == 2) then
			gg:setVisible(true)
		end
		menu = lastMenu
	end

end

function optionsUpdate()
	
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
	crankDock()
    
end

function pd.update()
	gfx.sprite.update()
	if(menu == 0) then
		startUpdate()
	elseif(menu == 2) then
		gameOverUpdate()
	elseif(menu == 3) then
		controlsUpdate()
	elseif(menu == 4) then
		gameOverUpdate()
	else
		gameUpdate()
	end

end