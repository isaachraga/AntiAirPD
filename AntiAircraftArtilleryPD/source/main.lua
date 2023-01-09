import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/ui"
import "CoreLibs/animation"
import "planemanager"
import "gun"
import "player"
import "cannon"
import "explosion"
import "animations"

--#INFO//
--add a reset highscore function to start update, reset highscore, then comment out funtion
--rx = relative X
--dx = delta x


--#CONSTS
local pd <const> = playdate
local gfx <const> = pd.graphics


--#DATASTORE VARS//
local newHighScore = false
local storedData = {}
--1. highscore
--2. aimtypeD
--3. invertX
--4. invertY

--#CONTROL MENU VARS//
local aimTypeD = false
local invertX = false
local invertY = false


--#GAME VARS//
local crankSoundx = 0
local crankSoundy = 0
local gameOver = false
local xintensity = 1
local yintensity = .1
local shotDamage = 13
local rof = 29

--override for timer, allows for pausing
function playdate.timer:start()
	self._lastTime = nil
	self.paused = false
end

--#MENU VARS//
local option = 0
local lastMenu = 0
local menuNum = 0
local menu = pd.getSystemMenu()
local menuItem, error = menu:addMenuItem("Controls", function()
	lastMenu = menuNum
	if(lastMenu == 0) then 
		ss:setVisible(false) 

	end

	if(lastMenu == 1) then
	
		for k, v in pairs(playdate.timer.allTimers()) do
			v:pause()
		end
	end

	if(lastMenu == 2) then gg:setVisible(false) end

	menuNum = 3 
	if aimTypeD then option = 1 else option = 0 end
	
end)


--#INITIALIZERS//

local function initialize()
	menuNum = 0

	pd.setCrankSoundsDisabled(true)

	text = gfx.font.new("font/Asheville-Sans-14-Bold")

	mgs = pd.sound.sampleplayer.new("sounds/MG")
	cas = pd.sound.sampleplayer.new("sounds/CannonExp")
	cas:setVolume(.8)
	ape = pd.sound.sampleplayer.new("sounds/AirplaneExp")
	click = pd.sound.sampleplayer.new("sounds/Click")
	click:setVolume(.6)

	gunTimer = playdate.timer.new(0,0, 0, playdate.easingFunctions.linear)
	
	--initailizes datastore or reads previous data
	if(pd.datastore.read(data) == nil) then
		storedData[1] = 0
		storedData[2] = false
		storedData[3] = false
		storedData[4] = false
		pd.datastore.write(storedData, data)
	else
		testTable = pd.datastore.read(data)
		for k,v in pairs(testTable) do 
			if (k == 2) then 
				aimTypeD = testTable[k]
			elseif (k == 3) then
				invertX  = testTable[k]
			elseif (k == 4) then
				invertY = testTable[k]
			end
			storedData[k] = testTable[k]
		end

	end

	startInitialize()
end




function startInitialize()
	local startImage = gfx.image.new("images/StartScreen")
	ss = gfx.sprite.new(startImage)
	ss:moveTo(200,120)
	ss:add()
	ss:setZIndex(32767)
end



function gameInitialize()
	
	gfx.setImageDrawMode(gfx.kDrawModeCopy)

	gameOver = false
	score = 0
	animMain = animations()
	cannonMain = cannon()
	playerMain = player()
	pmMain = PlaneManager(playerMain)
	gunMain = gun()
	gunMain:add()

	--local bkgd = gfx.image.new("images/bkgd")
	bkgd = nil
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
	ui:setZIndex(32766)

	local heightReticle = gfx.image.new("images/HeightReticle")
	hr = gfx.sprite.new(heightReticle)
	hr:moveTo(111,227)
	--low 227 high 171
	hr:add()
	hr:setZIndex(32767)

	local mgA = gfx.image.new("images/mgActive")
	mg = gfx.sprite.new(mgA)
	mg:moveTo(364,208)
	mg:add()
	mg:setVisible(false)
	mg:setZIndex(32767)

	local caA = gfx.image.new("images/cannonActive")
	ca = gfx.sprite.new(caA)
	ca:moveTo(36,208)
	ca:add()
	ca:setVisible(false)
	ca:setZIndex(32767)

	pmMain:spawnPlane()
end

function gameOverInitialize()
	gfx.sprite:removeAll()
	gameOver = true
	cannonMain = nil
	gunMain = nil
	playerMain = nil
	pmMain = nil
	animMain = nil

	local endImage = gfx.image.new("images/GameOver")
	gg = gfx.sprite.new(endImage)
	gg:moveTo(200,120)
	gg:add()
	gg:setZIndex(32767)

	for k,v in pairs(pd.sound.playingSources()) do
        v:stop()
    end

    cas:play()

	--check for highscore
	testTable = pd.datastore.read(data)

	if(testTable[1] < score)then
		storedData[1] = score
		pd.datastore.write(storedData, data)
		newHighScore = true
				
	end
end

initialize()



--#GAME FUNCTIONS//

function getGameOver()
	return gameOver
end

--controls the rate of fire
local function resetGunTimer()
	gunTimer = playdate.timer.new(rof,10, 0, playdate.easingFunctions.linear)
end

local function gunLocation(x,y)
--controls frequency of the crank click
	if(crankSoundx > 70) then 
		click:play()
		crankSoundx = 0
	end

	if(crankSoundy > 210) then 
		click:play()
		crankSoundy = 0
	end

	--moves assets according to where the gun is pointing
	upcheck = playerMain:getUp() + (y * yintensity)
	sidecheck = playerMain:getSide() + (x * xintensity)

	if(upcheck <= 360 and upcheck >= 120 and x == 0) then 
		playerMain:setUp(playerMain:getUp() + (y * yintensity))
		pmMain:setPlanes(playerMain:getSide(), playerMain:getUp())
		animMain:moveAnimations((x * xintensity), (y * yintensity))
		cannonMain:moveShots((x * xintensity), (-y * yintensity))
		crankSoundy = crankSoundy + math.abs(y)
		setBG(playerMain:getSide(), playerMain:getUp())
	end

	if (playerMain:getSide() >= 1600) then 
		playerMain:setSide(0)
	
	elseif(playerMain:getSide() < 0) then
		playerMain:setSide(1599.999)
	
	elseif(y == 0) then 
	
		playerMain:setSide(playerMain:getSide() - (x * xintensity))
		pmMain:setPlanes(playerMain:getSide(), playerMain:getUp())
		animMain:moveAnimations((x * xintensity), (y * yintensity))
		cannonMain:moveShots((x * xintensity), (y * yintensity))
		crankSoundx = crankSoundx + math.abs(x)
		setBG(playerMain:getSide(), playerMain:getUp())
	end

end

function setBG(x, y)
	local xd = bg.rx - x -250
	local yd = bg.ry - y + 120 
	bg:moveTo(xd,yd)
end



local function playerControls()
	if(aimTypeD == false) then 
		if((playdate.buttonIsPressed(pd.kButtonLeft) or playdate.buttonIsPressed(pd.kButtonRight)) and 
		(playdate.buttonIsPressed(pd.kButtonDown) == false and playdate.buttonIsPressed(pd.kButtonUp) == false) and playdate.getCrankChange(change) ~= 0) then
		
			gunLocation(playdate.getCrankChange(change), 0)
		elseif ((playdate.buttonIsPressed(pd.kButtonDown) or playdate.buttonIsPressed(pd.kButtonUp)) and 
		(playdate.buttonIsPressed(pd.kButtonLeft) == false and playdate.buttonIsPressed(pd.kButtonRight) == false) and playdate.getCrankChange(change) ~= 0) then
		
			gunLocation(0, playdate.getCrankChange(change))
	
		end 
	else
		if (playdate.buttonIsPressed(pd.kButtonLeft)and 
		(playdate.buttonIsPressed(pd.kButtonDown) == false and playdate.buttonIsPressed(pd.kButtonUp) == false)) then
			if(invertX) then gunLocation(-5, 0) else gunLocation( 5, 0)end
			
		elseif(playdate.buttonIsPressed(pd.kButtonRight)and 
		(playdate.buttonIsPressed(pd.kButtonDown) == false and playdate.buttonIsPressed(pd.kButtonUp) == false)) then
		
			if(invertX) then gunLocation(5, 0) else gunLocation(-5, 0)end
	
		elseif (playdate.buttonIsPressed(pd.kButtonDown)and 
		(playdate.buttonIsPressed(pd.kButtonLeft) == false and playdate.buttonIsPressed(pd.kButtonRight) == false)) then
			if(invertY) then gunLocation(0, -15) else gunLocation(0, 15)end
			
		elseif (playdate.buttonIsPressed(pd.kButtonUp)and 
		(playdate.buttonIsPressed(pd.kButtonLeft) == false and playdate.buttonIsPressed(pd.kButtonRight) == false)) then
		
			if(invertY) then gunLocation(0, 15) else gunLocation(0, -15)end
		end
	
	end

	if(playdate.buttonIsPressed(playdate.kButtonA)) then 
		if(gunTimer.value  == 0 ) then
			gunMain:shoot() 
			mgs:play()
			resetGunTimer()
		end
	end

	if(playdate.buttonIsPressed(playdate.kButtonB)) then 
		if(cannonMain.flag==true)then
			cas:play()
		end
		cannonMain:shoot()
	end


end



function uiSprites()

	if(playdate.buttonIsPressed(playdate.kButtonA)) then 
		mg:setVisible(true)
	else
		mg:setVisible(false)
	end

	if(playdate.buttonIsPressed(playdate.kButtonB) or cannonMain.flag == false) then 
		ca:setVisible(true)
	else
		ca:setVisible(false)
	end

end


function shotCollisions()

	local collisions = gfx.sprite.allOverlappingSprites()

	for i = 1, #collisions do
			local collisionPair = collisions[i]
			local sprite1 = collisionPair[1]
			local sprite2 = collisionPair[2]

			if(sprite1:isa(Plane) and sprite2:isa(gun)) then
				sprite1:damage(shotDamage)
			elseif(sprite2:isa(Plane) and sprite1:isa(gun)) then
				sprite2:damage(shotDamage)
			end

			if(sprite1:isa(DummyPlane) and sprite2:isa(gun)) then
				sprite1:damage(shotDamage)
			elseif(sprite2:isa(DummyPlane) and sprite1:isa(gun)) then
				sprite2:damage(shotDamage)
			end

			if(sprite1:isa(Plane) and sprite2:isa(cannonShot)) then
				sprite1:destroy()
			elseif(sprite2:isa(Plane) and sprite1:isa(cannonShot)) then
				sprite2:destroy()
			end

	end
end

function heightRet()
	cyhr = mapping(playerMain:getUp(), 360, 120, 227, 171)
	hr:moveTo(111,cyhr)
end


function radar()
	local x1 = 291
	local y1 = 199
	local cx = x1+30*math.cos(mapping(playerMain:getSide()-200, 1600, 0, (2*math.pi), 0))
	local cy = y1+30*math.sin(mapping(playerMain:getSide()-200, 1600, 0, (2*math.pi), 0))
	gfx.drawLine(x1, y1, cx, cy)
	local cx2 = x1+30*math.cos(mapping(playerMain:getSide()+200, 1600, 0, (2*math.pi), 0))
	local cy2 = y1+30*math.sin(mapping(playerMain:getSide()+200, 1600, 0, (2*math.pi), 0))
	gfx.drawLine(x1, y1, cx2, cy2)

end

--handles all mapping functions(first lower bound, first uppper bound, last (etc.))
function mapping(input, flb, fub, llb, lub)
    output = (input-flb)/(fub-flb) * (lub-llb) + llb
    return output
end

function crankDockCheck()
	if(playdate.isCrankDocked() and aimTypeD == false) then
		playdate.ui.crankIndicator:start()
		playdate.ui.crankIndicator:update()
	end
end

function cannonCheck()
	if(cannonMain.cannonTimer.value == cannonMain.timerMax) then
		cannonMain.flag = true
	end
	if(cannonMain.cannonTimer.value > 1) then
		cannonMain:clear()
	end
end

function cannonUI()
	gfx.fillRect(52,mapping(cannonMain.cannonTimer.value, cannonMain.timerMax, 0, 193, 233),5,29)
end

function gameOverCheck()
	if (pmMain:gameOverCheck() == true and menuNum == 1) then
		menuNum = 2 
		gameOverInitialize()
	end
end

function drawScore()
	text:drawText(string.format("%06d", score), 171, 210)
end


--#UPDATE FUNCTIONS//

function startUpdate()
	playdate.timer.updateTimers()

   text:drawText("   Start", 293, 170)
   gfx.drawText("Ⓐ", 280, 170)
   text:drawText("   Controls", 283, 200)
   gfx.drawText("⊙", 270, 200)

	if(pd.buttonJustPressed(pd.kButtonA))then
		mgs:play()
		gameInitialize()
		ss:remove()
		menuNum = 1

	end

	--add a reset highscore function here before ship, then erase
	
	--if pd.buttonJustPressed(pd.kButtonB) then

	--end


end

function gameUpdate()
	playdate.timer.updateTimers()

	gunMain:clear()
	pmMain:resetPlaneHMScale()
	playerControls()
	pmMain:incrementScale()
	pmMain:setVolumes()
	pmMain:planeTrigger()
	shotCollisions()
	cannonCheck()
	animMain:playAnimations()
	uiSprites()
	drawScore()
	pmMain:radar()
	radar()
	heightRet()
	cannonUI()
	crankDockCheck()
	gameOverCheck()
end

function gameOverUpdate()
	gfx.setImageDrawMode(gfx.kDrawModeInverted)

	newtable = pd.datastore.read(data)
	
	for k,v in pairs(newtable) do
		if(k == 1) then
			if(newHighScore == true) then
				text:drawText("*New High Score*: " .. tostring(v).."", 135,120)
			else
				text:drawText("High Score: " .. tostring(v), 150,120)
			end
		end
	end

	text:drawText("Your Score: " .. tostring(score), 150,147)

	text:drawText("       Restart                             Controls", 68, 210)
	gfx.drawText("Ⓐ", 68, 210)
	gfx.drawText("⊙",244, 210)

		if(pd.buttonJustPressed(pd.kButtonA))then
			mgs:play()
			gg:remove()
			gameInitialize()
			newHighScore = false		
			menuNum = 1
		end
end


function controlsUpdate()

	if(invertX) then gfx.drawRect(324, 27, 22, 25) end
	if(invertY) then gfx.drawRect(353, 27, 22, 25) end

	gfx.drawText("⬅️", 143, 6)
	gfx.drawText("➡️", 212, 6)
	gfx.drawText("⬆️", 326, 6)
	gfx.drawText("⬇️", 354, 6)

	if(lastMenu == 1) then
		pmMain:setAllVisibile(false)
		ui:setVisible(false)
		hr:setVisible(false)
		bg:setVisible(false)
	end 
	text:drawText("Aim Control:", 25, 32)
	text:drawText("+", 147, 32)
	text:drawText("Invert:   X     Y  ", 272, 32)
	gfx.drawText("✛   🎣", 125, 32)
	gfx.drawText("✛", 210, 32)
		
	if(option == 0 ) then 
		gfx.drawRect(120, 29, 63, 27)
		text:drawText("(       OR       ) +      ================= Veritcal Aim", 25, 62)
		gfx.drawText("⬆️", 35, 62)
		gfx.drawText("➡️", 85, 62)
		gfx.drawText("🎣", 128, 62)
		text:drawText("(       OR       ) +      =============== Horizontal Aim", 25, 89)
		gfx.drawText("⬆️", 35, 89)
		gfx.drawText("➡️", 85, 89)
		gfx.drawText("🎣", 128, 89)
	else
		gfx.drawRect(206, 29, 27, 27)
		text:drawText("(       OR       ) ===================== Veritcal Aim", 25, 62)
		gfx.drawText("⬆️", 35, 62)
		gfx.drawText("➡️", 85, 62)
	
		text:drawText("(       OR       ) =================== Horizontal Aim", 25, 89)
		gfx.drawText("⬆️", 35, 89)
		gfx.drawText("➡️", 85, 89)
	end
	text:drawText("      ========================= Fire Machine Gun", 25, 116)
	gfx.drawText("Ⓐ", 25, 116)
	text:drawText("      ============================== Fire Cannon", 25, 143)
	gfx.drawText("Ⓑ", 25, 143)
	

	text:drawText("Press       to Confirm", 140, 210)
	gfx.drawText("         Ⓐ", 144, 210)

	if(pd.buttonJustPressed(pd.kButtonA))then
		if option == 0 then aimTypeD = false else aimTypeD = true end
		storedData[2] = aimTypeD
		storedData[3] = invertX
		storedData[4] = invertY
		if(lastMenu == 0) then
			ss:setVisible(true)

		elseif(lastMenu == 1) then
			pmMain:setAllVisibile(true)
			ui:setVisible(true)
			bg:setVisible(true)
			hr:setVisible(true)
			if(lastMenu == 1) then
				for k, v in pairs(playdate.timer.allTimers()) do
					v:start()
				end
			end
		elseif(lastMenu == 2) then
			gg:setVisible(true)
		end
		menuNum = lastMenu
		click:play()
		option = 0
	end

	if pd.buttonJustPressed(pd.kButtonLeft) then
			option = 0
			click:play()
	end

	if pd.buttonJustPressed(pd.kButtonRight) then
		option = 1
		click:play()
	end
	if pd.buttonJustPressed(pd.kButtonUp) then
		if(invertX) then invertX = false else invertX = true end
		click:play()
	end
	if pd.buttonJustPressed(pd.kButtonDown) then
		if(invertY) then invertY = false else invertY = true end
		click:play()
	end

end






function pd.update()
	gfx.sprite.update()

	if(menuNum == 0) then
		startUpdate()
	elseif(menuNum == 2) then
		gameOverUpdate()
	elseif(menuNum == 3) then
		controlsUpdate()
	elseif(menuNum == 4) then
		optionsUpdate()
	else
		gameUpdate()
	end

end

--#SYSTEM FUNCTIONS//

function pd.deviceWillSleep()
 pd.datastore.write(storedData, data)
end

function pd.deviceWillLock()
	pd.datastore.write(storedData, data)
end

function playdate.gameWillTerminate()
	pd.datastore.write(storedData, data)
end