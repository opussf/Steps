-- FITBIT @VERSION@
FITBIT_SLUG, FITBIT = ...
FITBIT_MSG_ADDONNAME = GetAddOnMetadata( FITBIT_SLUG, "Title" )
FITBIT_MSG_VERSION   = GetAddOnMetadata( FITBIT_SLUG, "Version" )
FITBIT_MSG_AUTHOR    = GetAddOnMetadata( FITBIT_SLUG, "Author" )

-- Colours
COLOR_RED = "|cffff0000"
COLOR_GREEN = "|cff00ff00"
COLOR_BLUE = "|cff0000ff"
COLOR_PURPLE = "|cff700090"
COLOR_YELLOW = "|cffffff00"
COLOR_ORANGE = "|cffff6d00"
COLOR_GREY = "|cff808080"
COLOR_GOLD = "|cffcfb52b"
COLOR_NEON_BLUE = "|cff4d4dff"
COLOR_END = "|r"

Fitbit_data = {}
Fitbit_options = {}
--Fitbit_log = {}
FITBIT.steps_per_second = 2/7  -- 2 steps at speed 7
FITBIT.pruneDays = 91

-- Setup
function FITBIT.OnLoad()
	SLASH_FITBIT1 = "/FITBIT"
	SlashCmdList["FITBIT"] = function(msg) FITBIT.command(msg); end
	FITBIT.lastSpeed = 0
	Fitbit_Frame:RegisterEvent( "ADDON_LOADED" )
	Fitbit_Frame:RegisterEvent( "VARIABLES_LOADED" )
end
function FITBIT.ADDON_LOADED()
	Fitbit_Frame:UnregisterEvent( "ADDON_LOADED" )
	FITBIT.name = UnitName("player")
	FITBIT.realm = GetRealmName()
	FITBIT.InitChat()
end
function FITBIT.VARIABLES_LOADED()
	-- Unregister the event for this method.
	Fitbit_Frame:UnregisterEvent( "VARIABLES_LOADED" )

	Fitbit_data[FITBIT.realm] = Fitbit_data[FITBIT.realm] or {}
	Fitbit_data[FITBIT.realm][FITBIT.name] = Fitbit_data[FITBIT.realm][FITBIT.name] or { ["steps"] = 0 }
	FITBIT.mine = Fitbit_data[FITBIT.realm][FITBIT.name]
	FITBIT.mine[date("%Y%m%d")] = FITBIT.mine[date("%Y%m%d")] or { ["steps"] = 0 }
	FITBIT.Prune()
end

-- OnUpdate
function FITBIT.OnUpdate()
	local nowTS = time()
	local dateStr = date("%Y%m%d")
	if not FITBIT.mine[dateStr] then FITBIT.mine[dateStr] = { ["steps"] = 0 } end
	if IsMounted() or IsFlying() then
		FITBIT.isMoving = false
		--Fitbit_log[nowTS] = "mounted / flying"
		FITBIT.lastSpeed = 0
	else
		speed = GetUnitSpeed("player")
		if speed>0 and not FITBIT.isMoving then
			FITBIT.isMoving = true
			--Fitbit_log[nowTS] = speed
			FITBIT.lastSpeed = speed
		end
		if speed == 0 and FITBIT.isMoving then
			FITBIT.isMoving = false
			--Fitbit_log[nowTS] = speed
			FITBIT.lastSpeed = speed
		end
		if speed ~= FITBIT.lastSpeed then
			--Fitbit_log[nowTS] = speed
			FITBIT.lastSpeed = speed
		end
		if nowTS ~= FITBIT.lastUpdate then
			local newSteps = (FITBIT.steps_per_second * speed)
			FITBIT.mine.steps = FITBIT.mine.steps + newSteps
			FITBIT.mine[dateStr] = FITBIT.mine[dateStr] or { ["steps"] = 0 }
			FITBIT.mine[dateStr].steps = FITBIT.mine[dateStr].steps + newSteps
		end
	end
	if nowTS ~= FITBIT.lastUpdate then
		Fitbit_StepBar:Show()
		Fitbit_StepBarText:SetText( FITBIT.L["Steps"]..": "..math.floor( FITBIT.mine[dateStr].steps ) )
	end
	-- if nowTS % 10 == 0 and not FITBIT.printed then
	-- 	print( "Steps: "..math.floor( FITBIT.mine[dateStr].steps ) )
	-- 	FITBIT.printed = true
	-- elseif nowTS % 10 ~= 0 then
	-- 	FITBIT.printed = nil
	-- end
	FITBIT.lastUpdate = nowTS
end

-- Support
function FITBIT.Prune()
	local nowTS = time()
	for r, _ in pairs( Fitbit_data ) do
		local ncount = 0
		for n, _ in pairs( Fitbit_data[r] ) do
			local kcount = 0
			for k, _ in pairs( Fitbit_data[r][n] ) do
				if k ~= "steps" then
					local y = strsub( k, 1, 4 )
					local m = strsub( k, 5, 6 )
					local d = strsub( k, 7, 8 )
					local kts = time{year=y, month=m, day=d}
					if kts < nowTS - ( FITBIT.pruneDays * 86400 ) then
						Fitbit_data[r][n][k] = nil
					else
						kcount = kcount + 1
					end
				end
			end
			if kcount == 0 then
				Fitbit_data[r][n] = nil
			else
				ncount = ncount + 1
			end
		end
		if ncount == 0 then
			Fitbit_data[r] = nil
		end
	end
end
function FITBIT.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_PURPLE..FITBIT_MSG_ADDONNAME.."> "..COLOR_END..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end
function FITBIT.parseCmd(msg)
	if msg then
		msg = string.lower(msg)
		local a,b,c = strfind(msg, "(%S+)")  --contiguous string of non-space characters
		if a then
			-- c is the matched string, strsub is everything after that, skipping the space
			return c, strsub(msg, b+2)
		else
			return ""
		end
	end
end
function FITBIT.command( msg )
	local cmd, param = FITBIT.parseCmd(msg)
	if FITBIT.CommandList[cmd] and FITBIT.CommandList[cmd].alias then
		cmd = FITBIT.CommandList[cmd].alias
	end
	local cmdFunc = FITBIT.CommandList[cmd]
	if cmdFunc and cmdFunc.func then
		cmdFunc.func(param)
	else
		FITBIT.PrintHelp()
	end
end
function FITBIT.PrintHelp()
	--FITBIT.Print( string.format( "%s (%s) by %s", FITBIT_MSG_ADDONNAME, FITBIT_MSG_VERSION, FITBIT_MSG_AUTHOR ) )
	FITBIT.Print( string.format(FITBIT.L["%s (%s) by %s"], FITBIT_MSG_ADDONNAME, FITBIT_MSG_VERSION, FITBIT_MSG_AUTHOR ) )
	for cmd, info in pairs(FITBIT.CommandList) do
		if info.help then
			local cmdStr = cmd
			for c2, i2 in pairs(FITBIT.CommandList) do
				if i2.alias and i2.alias == cmd then
					cmdStr = string.format( "%s / %s", cmdStr, c2 )
				end
			end
			FITBIT.Print(string.format("%s %s %s -> %s",
				SLASH_FITBIT1, cmdStr, info.help[1], info.help[2]))
		end
	end
end
FITBIT.CommandList = {
	[""] = {
		["help"] = {"{FB}",FITBIT.L["Send steps to any chat"]},
	},
	[FITBIT.L["help"]] = {
		["func"] = FITBIT.PrintHelp,
		["help"] = {"",FITBIT.L["Print this help."]}
	},
}

--[[
https://wowwiki-archive.fandom.com/wiki/API_GetUnitSpeed
value = GetUnitSpeed("unit")

Player unit moving at 100% -- value = 7
Player unit moving at 175% -- value = 12.25
Player unit moving at 200% -- value = 14

]]
