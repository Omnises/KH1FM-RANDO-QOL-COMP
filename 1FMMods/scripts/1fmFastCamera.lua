LUAGUI_NAME = "1fmFastCamera"
LUAGUI_AUTH = "denhonator (edited by deathofall84)"
LUAGUI_DESC = "Speeds up camera movement and camera centering"

local centerSpeed = 2
local overallSpeed = 1.2
local overallSpeedV = 1.2
local accelerationSpeed = 0.001
local accelerationSpeedV = 0.0014
local deaccelerationSpeedV = -0.001
local deaccelerationSpeed = -0.0016
local lastSpeedH = 0
local lastSpeedV = 0
local canExecute = false
local offset = 0x0
local speedOffset = 0x0

local curSpeedV = 0x25387D0
local curSpeedH = 0x25387D4
local cameraInputH = 0x2341360
local cameraInputV = 0x2341364
local cameraCenter = 0x2538A34
local speed = 0x507AAC

local menuOpen = 0x232E900
local posDebugString = 0x3EB158

-----
-- need to check these
local snap = 0x1DD299 + 0x4310
local accelHack = 0x1E2924 + 0x4310
local deaccelHack = 0x1E291B + 0x4310

function _OnInit()
	if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
		canExecute = true
		ConsolePrint("KH1 detected, running script")
		if ReadByte(posDebugString) ~= 0x58 and ReadByte(posDebugString-0x1020) == 0x58 then
			ConsolePrint("JP EG detected, setting offsets")
			offset = 0x1000
			speedOffset = 0xF5C
		end
		curSpeedV = curSpeedV - offset
		curSpeedH = curSpeedH - offset
		cameraInputH = cameraInputH - offset
		cameraInputV = cameraInputV - offset
		cameraCenter = cameraCenter - offset
		speed = speed - offset
		menuOpen = menuOpen - offset
	else
		ConsolePrint("KH1 not detected, not running script")
	end

	-- if canExecute then
		-- -- Enables instant camera centering
		-- if ReadInt(snap) == 0x0215EFBF then
			-- WriteInt(snap, 0x02357487)
		-- end
		-- -- Changes it to read acceleration values from elsewhere
		-- --WriteInt(accelHack, 0x0020563C)
		-- --WriteInt(deaccelHack, 0x00205645)
	-- end
end

function _OnFrame()
	if canExecute and ReadByte(menuOpen) == 0 then
		local currentSpeedH = ReadFloat(curSpeedH)
		local currentSpeedV = ReadFloat(curSpeedV)
		local difH = currentSpeedH - lastSpeedH
		local difV = currentSpeedV - lastSpeedV
		
		if ReadFloat(cameraCenter) > 1 then
			WriteFloat(cameraCenter, ReadFloat(cameraCenter)-centerSpeed)
		end
		
		if math.abs(ReadFloat(speed)) == 1.0 then -- This way it works for inverted camera
			WriteFloat(speed, ReadFloat(speed) * overallSpeed)
			WriteFloat(speed-4, ReadFloat(speed-4) * overallSpeedV)
		end
		
		if ReadFloat(curSpeedH) ~= 0 then
			if math.abs(ReadFloat(cameraInputH)) > 0.05 then
				WriteFloat(curSpeedH, math.min(math.max(currentSpeedH + ReadFloat(cameraInputH) * accelerationSpeed, -0.44), 0.44))
			else
				WriteFloat(curSpeedH, currentSpeedH * (1.0 - deaccelerationSpeed * 10))
			end
		end
		if ReadFloat(curSpeedV) ~= 0 then
			if math.abs(ReadFloat(cameraInputV)) > 0.05 then
				WriteFloat(curSpeedV, math.min(math.max(currentSpeedV - ReadFloat(cameraInputV) * accelerationSpeedV, -0.44), 0.44))
			else
				WriteFloat(curSpeedV, currentSpeedV * (1.0 - deaccelerationSpeedV * 10))
			end
		end
		lastSpeedH = currentSpeedH
		lastSpeedV = currentSpeedV
	end
end