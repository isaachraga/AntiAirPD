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
import "testOBJ"



local pd <const> = playdate
local gfx <const> = pd.graphics
anim = animations()
local highscore = {}
local storedData = {}
--1. highscore
--2. aimtypeD
--3. invertX
--4. invertY

local option = 0



aimTypeD = false
invertX = false
invertY = false

test = 50
knum1= 0
knum2 = 0
lastMenu = 0
crankSoundx = 0
crankSoundy = 0
noFlashing = false

local newHighScore = false


local xintensity = 1
local yintensity = .1


local menu = 0

shotDamage = 13

function playdate.timer:start()
	self._lastTime = nil
	self.paused = false
end



--plane scalemax 10 min .05

local planeScale = 1

local function resetTimer()

	timer = playdate.timer.new(30000,0, 10000, playdate.easingFunctions.inExpo)
end
local function resetGunTimer()

	gunTimer = playdate.timer.new(29,10, 0, playdate.easingFunctions.linear)
end



local menu = pd.getSystemMenu()

local menuItem, error = menu:addMenuItem("Controls", function()
	lastMenu = menu
	if(lastMenu == 0) then 
		ss:setVisible(false) 
		sstanim:setVisible(false)
	end

	if(lastMenu == 1) then
		for key, value in pairs(playdate.timer.allTimers()) do
			value:pause()
		end
	end

	if(lastMenu == 2) then gg:setVisible(false) end

	menu = 3 
	if aimTypeD then option = 1 else option = 0 end
	
end)



local function initialize()
	
	

	menu = 0
	pd.setCrankSoundsDisabled(true)
	mgs = pd.sound.sampleplayer.new("sounds/MG")
	cas = pd.sound.sampleplayer.new("sounds/CannonExp")
	aps = pd.sound.sampleplayer.new("sounds/AirplaneExp")
	click = pd.sound.sampleplayer.new("sounds/Click")
	gunTimer = playdate.timer.new(0,0, 0, playdate.easingFunctions.linear)
	if(pd.getReduceFlashing()) then 
		noFlashing = true
	end




	ssframeTimer = playdate.timer.new(480,1000, 11000)
    sst = gfx.imagetable.new("images/StartScreen")
	sstanim = gfx.sprite.new(sst:getImage(1))
	sstanim:add()
	--testTimer = playdate.timer.new(50000,0, 50, playdate.easingFunctions.linear)
	
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
	
	local startImage = gfx.image.new("images/SSText")
	ss = gfx.sprite.new(startImage)
	ss:moveTo(315,120)
	ss:add()
	ss:setZIndex(32767)

	
	--print("start///")
end



function gameOverInitialize()
	
	gfx.sprite:removeAll()
	cannonMain = nil
	gunMain = nil
	playerMain = nil
	pm = nil
	--anim:removeAllAnimations()
	--pm:removeAllPlanes()
	--pm:remove()
	resetTimer()
	local endImage = gfx.image.new("images/GameOver")
	gg = gfx.sprite.new(endImage)
	gg:moveTo(200,120)
	gg:add()
	gg:setZIndex(32767)
	aps:play()


	testTable = pd.datastore.read(data)
	
	if(testTable[1] < score)then
		storedData[1] = score
		pd.datastore.write(storedData, data)
		newHighScore = true
				
	end

		
		

	--print("gameover///")
end

function gameInitialize()
	--print("game///")
	gfx.setImageDrawMode(gfx.kDrawModeCopy)
	e = {}
	score = 0
	--print(score.."score")

	

	
	
	
	cannonMain = cannon()
	--cannon:add()
	cannonMain:initTimer()

	gunMain = gun()
	gunMain:add()

	playerMain = player(200, 360)
	playerMain:setSide(200)
	playerMain:setUp(360)


	pm = PlaneManager(timer, playerMain, score)
	--pm:add()
	pm:removeAllPlanes()
	pm:spawnPlane(timer, 1000)
	

	local bkgd = gfx.image.new("images/bkgd")
	--local bkgd = nil
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

	


	resetTimer()
	

end



initialize()

local function fakeSoundTrack()

end



local function gunLocation(x,y)

	
	if(crankSoundx > 70) then 
		click:play()
		crankSoundx = 0
	end
	
	if(crankSoundy > 210) then 
		click:play()
		crankSoundy = 0
	end

	upcheck = playerMain:getUp() + (y * yintensity)
	sidecheck = playerMain:getSide() + (x * xintensity)

	if(upcheck <= 360 and upcheck >= 120 and x == 0) then 
		playerMain:setUp(playerMain:getUp() + (y * yintensity))
		pm:setPlanes(playerMain:getSide(), playerMain:getUp())
		--cannonMain:setShots((x * xintensity), (y * yintensity))
		anim:moveAnimations((x * xintensity), (y * yintensity))
		crankSoundy = crankSoundy + math.abs(y)
		setBG(playerMain:getSide(), playerMain:getUp())
	end
	if (playerMain:getSide() >= 1600) then 
		playerMain:setSide(0)
	
	elseif(playerMain:getSide() < 0) then
		playerMain:setSide(1599.999)
	
	elseif(y == 0) then 
	
		playerMain:setSide(playerMain:getSide() - (x * xintensity))
		pm:setPlanes(playerMain:getSide(), playerMain:getUp())
		--cannonMain:setShots((x * xintensity), (y * yintensity))
		anim:moveAnimations((x * xintensity), (y * yintensity))
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
			-- do something with the colliding sprites
			if(sprite1:isa(Plane) and sprite2:isa(gun)) then
				sprite1:damage(shotDamage)
			elseif(sprite2:isa(Plane) and sprite1:isa(gun)) then
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

function mapping(input, flb, fub, llb, lub)
    output = (input-flb)/(fub-flb) * (lub-llb) + llb
    return output
end

function crankDock()
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
	gfx.fillRect(52,mapping(cannonMain.cannonTimer.value, 5, 0, 193, 233),5,29)
end

function gameOverCheck()
	if (pm:gameOverCheck() == true and menu == 1) then
		menu = 2 
	
		gameOverInitialize()
		
	end
end

function startUpdate()
	playdate.timer.updateTimers()
	fakeSoundTrack()

	if((ssframeTimer.value/1000) < 11) then
        --self.exp:getImage(math.floor(self.frameTimer.value/1000)):drawScaled(self:screenPositionX(), self:screenPositionY(),10)
        sstanim:setImage(sst:getImage(math.floor(ssframeTimer.value/1000)))
        sstanim:moveTo(200,120)
       
        
    else
		ssframeTimer = playdate.timer.new(480,1000, 11000)
        
    end
	gfx.drawText("Ⓐ Start", 280, 170)
	gfx.drawText("⊙ Controls", 270, 200)

	if(pd.buttonJustPressed(pd.kButtonA))then
		mgs:play()
		gameInitialize()
		ss:remove()
		sstanim:remove()
		menu = 1
	end

	if pd.buttonJustPressed(pd.kButtonB) then
		--.3 min, 15 max
		exp = explosion(200, 120, 32767,30)
        anim:addAnimationC(exp)
	end
	anim:playAnimations()

end

function gameOverUpdate()

	newtable = pd.datastore.read(data)
	gfx.setImageDrawMode(gfx.kDrawModeInverted)
	for k,v in pairs(newtable) do
		if(k == 1) then
			if(newHighScore == true) then
				gfx.drawText("!!!  New High Score: " .. tostring(v).."  !!!", 120,120)
			else
				gfx.drawText("High Score: " .. tostring(v), 150,120)
			end
		end
	end

	gfx.drawText("Your Score: " .. tostring(score), 150,147)

	gfx.drawText("Ⓐ Restart                 ⊙ Controls", 80, 210)

		if(pd.buttonJustPressed(pd.kButtonA))then
			mgs:play()
			gg:remove()
			gameInitialize()
			newHighScore = false		
			menu = 1
		end
end


function controlsUpdate()

	if(invertX) then gfx.drawRect(327, 27, 22, 25) end
	if(invertY) then gfx.drawRect(356, 27, 22, 25) end

		gfx.drawText("                           ⬅️       ➡️                   ⬆️ ⬇️", 25, 6)


	if(lastMenu == 1) then
		pm:setAllVisibile(false)
		ui:setVisible(false)
		hr:setVisible(false)
	end 
		gfx.drawText("Aim Control:      ✛+🎣    ✛       Invert:   X    Y  ", 25, 32)
		
	if(option == 0 ) then 
		gfx.drawRect(140, 29, 58, 27)
		gfx.drawText("(⬆️ OR ⬇️) + 🎣 ================= Veritcal Aim", 25, 62)
		gfx.drawText("(⬅️ OR ➡️) + 🎣 =============== Horizontal Aim", 25, 89)
	else
		gfx.drawRect(212, 29, 26, 27)
		gfx.drawText("(⬆️ OR ⬇️) ====================== Veritcal Aim", 25, 62)
		gfx.drawText("(⬅️ OR ➡️) ==================== Horizontal Aim", 25, 89)
	end
		gfx.drawText("Ⓐ ========================= Fire Machine Gun", 25, 116)
		gfx.drawText("Ⓑ ============================== Fire Cannon", 25, 143)
	

	gfx.drawText("Press Ⓐ to Confirm", 140, 210)

	if(pd.buttonJustPressed(pd.kButtonA))then
		if option == 0 then aimTypeD = false else aimTypeD = true end
		storedData[2] = aimTypeD
		storedData[3] = invertX
		storedData[4] = invertY
		if(lastMenu == 0) then
			ss:setVisible(true)
			sstanim:setVisible(true)
		elseif(lastMenu == 1) then
			pm:setAllVisibile(true)
			ui:setVisible(true)
			hr:setVisible(true)
			if(lastMenu == 1) then
				for key, value in pairs(playdate.timer.allTimers()) do
					value:start()
					--print(value.value .. "value")
				end
			end
		elseif(lastMenu == 2) then
			gg:setVisible(true)
		end
		menu = lastMenu
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

function drawScore()
	gfx.drawText(string.format("%06d", score), 172, 210)
end


function gameUpdate()
	playdate.timer.updateTimers()

	gunMain:clear()
	pm:resetPlaneHMScale()
	
	playerControls()
	pm:incrementScale()
	pm:planeTrigger()
	shotCollisions()
	cannonCheck()
	anim:playAnimations()
	--anim:moveAnimations()
	uiSprites()
	drawScore()
	pm:radar()
	radar()
	heightRet()
	cannonUI()
	crankDock()
	gameOverCheck()
    


end

function pd.update()
	gfx.sprite.update()

	--
	

	if(menu == 0) then
		startUpdate()
	elseif(menu == 2) then
		gameOverUpdate()
	elseif(menu == 3) then
		controlsUpdate()
	elseif(menu == 4) then
		optionsUpdate()
	else
		gameUpdate()
	end

end

function pd.deviceWillSleep()
--collect and store score, pm
 pd.datastore.write(storedData, data)
end

function pd.deviceWillLock()
	pd.datastore.write(storedData, data)
end

function playdate.gameWillTerminate()
	pd.datastore.write(storedData, data)
end