import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/frameTimer"
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
--commit to github
--thank you to helper on itch
--decrease click rate





--plane's actual location is stored in realX, realY
--plane's location in reference to the screan is adjustedX, adjustedY


--#CONSTS
local pd <const> = playdate
local gfx <const> = pd.graphics
local mgs <const> = pd.sound.sampleplayer.new("sounds/MG")
local cas <const> = pd.sound.sampleplayer.new("sounds/CannonExp")
local ape <const> = pd.sound.sampleplayer.new("sounds/AirplaneExp")
local click <const> = pd.sound.sampleplayer.new("sounds/Click")
local aps <const> = pd.sound.sample.new("sounds/AirplaneLoop")
local hitmarker <const> = gfx.image.new("images/HitMarker")
local beepSend <const> = pd.sound.sampleplayer.new("sounds/Beep")

local bkgd <const> = gfx.image.new("images/bkgd")
local bkgd2 <const> = bkgd:blurredImage(15, 5, gfx.image.kDitherTypeFloydSteinberg, true)
local bg = gfx.sprite.new(bkgd2)
local playerImage <const> = gfx.image.new("images/ui")
local ui <const> = gfx.sprite.new(playerImage)
local heightReticle <const> = gfx.image.new("images/HeightReticle")
local hr <const> = gfx.sprite.new(heightReticle)
local mgA <const> = gfx.image.new("images/mgActive")
local mg <const> = gfx.sprite.new(mgA)
local caA <const> = gfx.image.new("images/cannonActive")
local ca <const> = gfx.sprite.new(caA)
local endImage <const> = gfx.image.new("images/GameOver")
local image <const> = gfx.image.new("images/plane")
local startImage <const> = gfx.image.new("images/StartScreen")
local ss = gfx.sprite.new(startImage)


--#DATASTORE VARS//
local newHighScore = false
local storedData = {}
--1. highscore
--2. aimtypeD
--3. invertX
--4. invertY
--5. Crank Sensitivity
--6. D Pad Sensitivity

--#CONTROL MENU VARS//
local aimTypeD = false
local invertX = false
local invertY = false


--#GAME VARS//
local crankSoundx = 0
local crankSoundy = 0
local crankSensitivity = 1
local dPadSensitivity = 1
local crankLowBound = .1
local crankHighBound = 6
local dPadLowBound = .1
local dPadHighBound = 4
local gameOver = false
local xintensity = 1
local yintensity = .1
local shotDamage = 10
local rof = 29
local gunTimer = nil
local scale = 0.05
local loadingFlag = false
local score = 0


local animMain = animations()
local cannonMain = cannon()
local playerMain = player()
local pmMain = PlaneManager(playerMain, imageTableTest,beepSend, ape, aps, hitmarker)
local gunMain = gun()
local imageFrameTimer = pd.frameTimer.new(1)

local text <const> = gfx.font.new("font/Asheville-Sans-14-Bold")

local planeLimitMarker = 5;


local  imageTableTest <const> = {}


--override for timer, allows for pausing
function pd.timer:start()
	self._lastTime = nil
	self.paused = false
end

--#MENU VARS//
local option = 0
local lastMenu = 0
local menuNum = 0
local menu = pd.getSystemMenu()
local menuItem, error = menu:addMenuItem("Controls", function()
	if menuNum ~= 3 then
		lastMenu = menuNum
	end
	
	if(lastMenu == 0) then 
		ss:setVisible(false) 

	end

	if(lastMenu == 1) then
		pmMain:setAllVisibile(false)
		pmMain:setPlaneAudioPause(true)
		ui:setVisible(false)
		hr:setVisible(false)
		bg:setVisible(false)
		mg:setVisible(false)
		ca:setVisible(false)
		for k, v in pairs(pd.timer.allTimers()) do
			v:pause()
		end
	end

	if(lastMenu == 2) then gg:setVisible(false) end

	menuNum = 3 
	if aimTypeD then option = 1 else option = 0 end
	
end)



--#INITIALIZERS//

local function initialize()
	pd.setCrankSoundsDisabled(true)
	cas:setVolume(.8)
	click:setVolume(.6)

	--initailizes datastore or reads previous data
	if(pd.datastore.read(data) == nil) then
		storedData[1] = 0
		storedData[2] = false
		storedData[3] = false
		storedData[4] = false
		storedData[5] = false
		storedData[6] = false
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
			elseif(k==5)then
				crankSensitivity = testTable[k]
			elseif(k==6)then
				dPadSensitivity = testTable[k]
			end
			storedData[k] = testTable[k]
		end

	end
    menuNum = -1
end





function startInitialize()
	ss:moveTo(200,120)
	ss:add()
	ss:setZIndex(32767)
end

function scorePoint()
	score += 1

	if score == planeLimitMarker then
		planeLimitMarker += planeLimitMarker
		pmMain:increasePlaneLimit()
	end
end

function getSide()
	return playerMain:getSide()
end

function getUp()
	return playerMain:getUp()
end

--controls the rate of fire
local function resetGunTimer()
	gunTimer = pd.timer.new(rof,10, 0, pd.easingFunctions.linear)
end




function gameInitialize()
	gfx.setImageDrawMode(gfx.kDrawModeCopy)

	gameOver = false
	score = 0
	planeLimitMarker = 5
	animMain = animations()
	cannonMain = cannon()
	playerMain = player()

	pmMain = PlaneManager(playerMain, imageTableTest,beepSend, ape, aps, hitmarker)
	gunMain = gun()
	gunMain:add()

	bg.rx=1250
	bg.ry=240
	bg:moveTo(800,0)
	bg:setZIndex(0)
	bg:add()

	ui:moveTo(200,120)
	ui:add()
	ui:setZIndex(32766)

	hr:moveTo(111,227)
	hr:add()
	hr:setZIndex(32767)


	mg:moveTo(364,208)
	mg:add()
	mg:setVisible(false)
	mg:setZIndex(32767)

	ca:moveTo(36,208)
	ca:add()
	ca:setVisible(false)
	ca:setZIndex(32767)

	pmMain:spawnPlane()
	resetGunTimer()

	imageFrameTimer = pd.frameTimer.new(1)
	imageFrameTimer.timerEndedCallback = function(timer)
		resetFrameCount()
	end
end

function gameOverInitialize()
	gfx.sprite:removeAll()
	menuNum = 2
	gameOver = true
	cannonMain = nil
	gunMain = nil
	playerMain = nil
	animMain = nil

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




local function gunLocation(x,y)
--controls frequency of the crank click
	if(crankSoundx > 100) then 
		click:play()
		crankSoundx = 0
	end

	if(crankSoundy > 240) then 
		click:play()
		crankSoundy = 0
	end

	--moves assets according to where the gun is pointing
	local upcheck = playerMain:getUp() + (y * yintensity)

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
		if((pd.buttonIsPressed(pd.kButtonLeft) or pd.buttonIsPressed(pd.kButtonRight)) and 
		(pd.buttonIsPressed(pd.kButtonDown) == false and pd.buttonIsPressed(pd.kButtonUp) == false) and pd.getCrankChange(change) ~= 0) then
		
			gunLocation(pd.getCrankChange(change)*crankSensitivity, 0)
		elseif ((pd.buttonIsPressed(pd.kButtonDown) or pd.buttonIsPressed(pd.kButtonUp)) and 
		(pd.buttonIsPressed(pd.kButtonLeft) == false and pd.buttonIsPressed(pd.kButtonRight) == false) and pd.getCrankChange(change) ~= 0) then
		
			gunLocation(0, pd.getCrankChange(change)*crankSensitivity)
	
		end 
	else
		if (pd.buttonIsPressed(pd.kButtonLeft)and 
		(pd.buttonIsPressed(pd.kButtonDown) == false and pd.buttonIsPressed(pd.kButtonUp) == false)) then
			if(invertX) then gunLocation(-5*dPadSensitivity, 0) else gunLocation( 5*dPadSensitivity, 0)end
			
		elseif(pd.buttonIsPressed(pd.kButtonRight)and 
		(pd.buttonIsPressed(pd.kButtonDown) == false and pd.buttonIsPressed(pd.kButtonUp) == false)) then
		
			if(invertX) then gunLocation(5*dPadSensitivity, 0) else gunLocation(-5*dPadSensitivity, 0)end
	
		elseif (pd.buttonIsPressed(pd.kButtonDown)and 
		(pd.buttonIsPressed(pd.kButtonLeft) == false and pd.buttonIsPressed(pd.kButtonRight) == false)) then
			if(invertY) then gunLocation(0, -15*dPadSensitivity) else gunLocation(0, 15*dPadSensitivity)end
			
		elseif (pd.buttonIsPressed(pd.kButtonUp)and 
		(pd.buttonIsPressed(pd.kButtonLeft) == false and pd.buttonIsPressed(pd.kButtonRight) == false)) then
		
			if(invertY) then gunLocation(0, 15*dPadSensitivity) else gunLocation(0, -15*dPadSensitivity)end
		end
	
	end

	if(pd.buttonIsPressed(pd.kButtonA)) then 
		if(gunTimer.value  == 0 ) then
			gunMain:shoot() 
			mgs:play()
			resetGunTimer()
		end
	end

	if(pd.buttonIsPressed(pd.kButtonB)) then 
		if(cannonMain.flag==true)then
			cas:play()
		end
		cannonMain:shoot()
	end


end

function getPlaneSprite(sprieNum)

	return imageTableTest[sprieNum];
end



function uiSprites()

	if(pd.buttonIsPressed(pd.kButtonA)) then 
		mg:setVisible(true)
	else
		mg:setVisible(false)
	end

	if(pd.buttonIsPressed(pd.kButtonB) or cannonMain.flag == false) then 
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
    local output = (input-flb)/(fub-flb) * (lub-llb) + llb
    return output
end

function crankDockCheck()
	if(pd.isCrankDocked() and aimTypeD == false) then
		pd.ui.crankIndicator:start()
		pd.ui.crankIndicator:update()
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
	pd.timer.updateTimers()

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

	

end

function gameUpdate()
	pd.timer.updateTimers()

	gunMain:clear()
	pmMain:resetPlaneHMScale()
	playerControls()
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
				text:drawText("*New High Score*: " .. tostring(v).."", 130,120)
			else
				text:drawText("High Score: " .. tostring(v), 160,120)
			end
		end
	end

	text:drawText("Your Score: " .. tostring(score), 158,147)

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
	gfx.setImageDrawMode(gfx.kDrawModeCopy)

	if(invertX) then gfx.drawRect(324, 27, 22, 25) end
	if(invertY) then gfx.drawRect(353, 27, 22, 25) end

	gfx.drawText("⬅️", 143, 6)
	gfx.drawText("➡️", 212, 6)
	gfx.drawText("⬆️", 326, 6)
	gfx.drawText("⬇️", 354, 6)

	if(lastMenu == 1) then
		
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

	if option == 0 then
		gfx.drawText("🎣", 25, 169)
		gfx.fillRect(mapping(crankSensitivity, crankLowBound, crankHighBound, 138, 310), 177, 4, 16)
	else
		gfx.drawText("✛", 25, 169)
		gfx.fillRect(mapping(dPadSensitivity, dPadLowBound, dPadHighBound, 138, 310), 177, 4, 16)
	end
	text:drawText("Sensitivity: ", 50, 174)
	text:drawText("(Use       )", 318, 174)
	gfx.drawText("🎣", 358, 169)
	gfx.fillRect(138, 183, 172, 4)
	

	

	text:drawText("Press       to Confirm", 140, 210)
	gfx.drawText("         Ⓐ", 144, 210)

	if(pd.buttonJustPressed(pd.kButtonA))then
		if option == 0 then aimTypeD = false else aimTypeD = true end
		storedData[2] = aimTypeD
		storedData[3] = invertX
		storedData[4] = invertY
		storedData[5] = crankSensitivity
		storedData[6] = dPadSensitivity
		if(lastMenu == 0) then
			ss:setVisible(true)

		elseif(lastMenu == 1) then
			pmMain:setAllVisibile(true)
			ui:setVisible(true)
			bg:setVisible(true)
			hr:setVisible(true)
			pmMain:setPlaneAudioPause(false)
			if(cannonMain.flag == false) then 
				ca:setVisible(true)
			else
				ca:setVisible(false)
			end

			for k, v in pairs(pd.timer.allTimers()) do
				v:start()
			end
			
		elseif(lastMenu == 2) then
			gg:setVisible(true)
		end
		menuNum = lastMenu
		click:play()
		option = 0

		if(lastMenu == 1) then
			
			resetFrameCount()
		end
		
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
	if(pd.getCrankChange(change) ~= 0) then
		if pd.getCrankChange(change) < 0 then
			if option == 0 then
				if crankSensitivity > crankLowBound then
					crankSensitivity -= .05
				else
					crankSensitivity = crankLowBound
				end
			else
				if dPadSensitivity > dPadLowBound then
					dPadSensitivity -= .05
				else
					dPadSensitivity = dPadLowBound
				end
			end
			
			
		else
			if option == 0 then
				if crankSensitivity < crankHighBound then
					crankSensitivity += .05
				else
					crankSensitivity = crankHighBound
				end
			else
				if dPadSensitivity < dPadHighBound then
					dPadSensitivity += .05
				else
					dPadSensitivity = dPadHighBound
				end

			end
			
		end

		
	end

end



function resetFrameCount()
	--plane size testing snippet
	--[[if offsetNumNum < 22 then 
		offsetNumCounter += 1

		if offsetBool == true then
			offsetBool = false
			testnum += 1;
			p:setSprite(testnum)
			if offsetNumCounter > 14 then 
			   offsetNumNum+=1
			   offsetNumCounter = 0;
			end

		else
			offsetBool = true

		end

	else
		testnum += 1;
		p:setSprite(testnum)

	end

	imageFrameTimer = pd.frameTimer.new(1)
	imageFrameTimer.timerEndedCallback = function(timer)
		resetFrameCount()
	end ]]--
	
	
		
	if gameOver == false and menuNum==1 then
		imageFrameTimer = pd.frameTimer.new(1)
		imageFrameTimer.timerEndedCallback = function(timer)
			pmMain:advanceSprite()
			if gameOver == false and menuNum==1 then
				resetFrameCount()
			end
		end 
	end
end

function loading()
	gfx.sprite.update()
	text:drawText("Loading...", 165, 110)
	if(loadingFlag) then 
		
		for i = 1, 375 do
			
			
			if i < 345 then
				scale += 0.00072
				
				local scaledI <const> = image:scaledImage(scale)
				imageTableTest[i] = scaledI
				
				

				

			else
				
				scale =(0.3*10^(0.1*(i-345)))
				
				local scaledI <const> = image:scaledImage(scale)
				imageTableTest[i] = scaledI
				
				

				
			end
			
				
			
				
			
		
		end
		--menuNum = -2
		menuNum = 0
		startInitialize()

		--plane size testing snippet

		--[[p = imageTest(imageTableTest)
		p:moveTo(300, 50)
        p:add()
		p2 = imageTest(imageTableTest)
		p2:moveTo(100, 50)
        p2:add()
		--imageCountTimer = pd.timer.new(67, 0, 1, playdate.easingFunctions.linear)
		imageFrameTimer = pd.frameTimer.new(1)
		imageFrameTimer.timerEndedCallback = function(timer)
			resetFrameCount()
		end ]]--

		flip = true;
		
	end
	loadingFlag = true

	
	
	
end



function loading2()
	gfx.sprite.update()
	pd.timer.updateTimers()

	
	
	
	
	text:drawText("Loaded", 200, 160)
	if pd.buttonJustPressed(pd.kButtonDown) then
		testPlane:setImage(imageTableTest[testnum])
	end
	

	if pd.buttonJustPressed(pd.kButtonA) then
		menuNum = 0
		startInitialize()
	end
	
	text:drawText(scale, 200, 190)
	
	text:drawText(testnum, 200, 210)

end





function pd.update()
	gfx.sprite.update()
	pd.frameTimer.updateTimers()

	--pd.drawFPS(0,0)

	if(menuNum == 0) then
		startUpdate()
	elseif(menuNum == 2) then
		gameOverUpdate()
	elseif(menuNum == 3) then
		controlsUpdate()
	elseif(menuNum == 4) then
		optionsUpdate()
	elseif(menuNum == -1) then
		loading()
	elseif(menuNum == -2) then
	if(testnum<380) then
		loading2()
	else
		menuNum = 0
		startInitialize()
	end
		
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

function pd.gameWillTerminate()
	pd.datastore.write(storedData, data)
end