LUAGUI_NAME = "1fmBeepHack"
LUAGUI_AUTH = "deathofall84"
LUAGUI_DESC = "Removes low health beeping noise, works up to max health of 41"

local posDebugString = 0x3EB158

local function importVars(file)
	if not pcall(require, file) then
		local errorString = "\n\n!!!!!!!! IMPORT ERROR !!!!!!!!\n\n"
		local msg = ""
		local slashIdx = string.find(file, "/")
		if slashIdx then
			msg = string.format("%s.lua missing, get it from the Github!", string.sub(file, slashIdx + 1, #file))
		else
			msg = string.format("%s.lua missing, get it from the Github!", file)
		end
		ConsolePrint(string.format("%s%s%s", errorString, msg, errorString))
	end
end

function _OnInit()
	if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
		ConsolePrint("KH1 detected, running script")
		if ReadByte(posDebugString) == 0x58 then
			importVars("EpicGamesGlobal")
		elseif ReadByte(posDebugString - 0x1020) == 0x58 then
			importVars("EpicGamesJP")
		else
			importVars("SteamGlobal") -- Global and JP version addresses are shared
			if ReadByte(posDebugString - 0xE40) ~= 0x58 then -- Steam JP specific changes
				beepHack = beepHack - 0x280
			end
		end
		WriteByte(beepHack, 1)
	else
		ConsolePrint("KH1 not detected, not running script")
	end
end

function _OnFrame()
end