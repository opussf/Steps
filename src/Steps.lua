-- STEPS @VERSION@
STEPS_SLUG, STEPS = ...
STEPS_MSG_ADDONNAME = GetAddOnMetadata( STEPS_SLUG, "Title" )
STEPS_MSG_VERSION   = GetAddOnMetadata( STEPS_SLUG, "Version" )
STEPS_MSG_AUTHOR    = GetAddOnMetadata( STEPS_SLUG, "Author" )

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

Steps_data = {}
Steps_options = {}
STEPS.steps_per_second = 2/7  -- 2 steps at speed 7
STEPS.pruneDays = 91
STEPS.min = 0
STEPS.ave = 0
STEPS.max = 0
STEPS.commPrefix = "STEPS"

-- Setup
function STEPS.OnLoad()
	SLASH_STEPS1 = "/STEPS"
	SlashCmdList["STEPS"] = function(msg) STEPS.command(msg); end
	STEPS.lastSpeed = 0
	Steps_Frame:RegisterEvent( "ADDON_LOADED" )
	Steps_Frame:RegisterEvent( "VARIABLES_LOADED" )
	Steps_Frame:RegisterEvent( "LOADING_SCREEN_DISABLED" )
	Steps_Frame:RegisterEvent( "CHAT_MSG_ADDON" )
end
function STEPS.ADDON_LOADED()
	Steps_Frame:UnregisterEvent( "ADDON_LOADED" )
	STEPS.name = UnitName("player")
	STEPS.realm = GetRealmName()
	STEPS.InitChat()
end
function STEPS.VARIABLES_LOADED()
	-- Unregister the event for this method.
	Steps_Frame:UnregisterEvent( "VARIABLES_LOADED" )

	Steps_data[STEPS.realm] = Steps_data[STEPS.realm] or {}
	Steps_data[STEPS.realm][STEPS.name] = Steps_data[STEPS.realm][STEPS.name] or { ["steps"] = 0 }
	STEPS.mine = Steps_data[STEPS.realm][STEPS.name]
	STEPS.mine[date("%Y%m%d")] = STEPS.mine[date("%Y%m%d")] or { ["steps"] = 0 }
	STEPS.min, STEPS.ave, STEPS.max = STEPS.CalcMinAveMax()
	STEPS.Prune()
end
function STEPS.LOADING_SCREEN_DISABLED()
	if not C_ChatInfo.IsAddonMessagePrefixRegistered(STEPS.commPrefix) then
		C_ChatInfo.RegisterAddonMessagePrefix(STEPS.commPrefix)
	end

	if IsInGuild() then
		STEPS.addonMsg = STEPS.BuildAddonMessage()
		C_ChatInfo.SendAddonMessage( STEPS.commPrefix, STEPS.addonMsg, "GUILD" )
	end
end
function STEPS.CHAT_MSG_ADDON(...)
	self, prefix, message, distType, sender = ...
	if prefix == STEPS.commPrefix then
		STEPS.Print( "p:"..prefix.." m:"..message.." d:"..distType.." s:"..sender )
		STEPS.DecodeMessage( message )
	end
end
function STEPS.BuildAddonMessage( )
	STEPS.addonMsgTable = {}
	table.insert( STEPS.addonMsgTable, "v:"..STEPS_MSG_VERSION )
	table.insert( STEPS.addonMsgTable, "r:"..STEPS.realm )
	table.insert( STEPS.addonMsgTable, "n:"..STEPS.name )
	table.insert( STEPS.addonMsgTable, "s:"..STEPS.mine.steps )
	for _,dayStr in pairs({ date("%Y%m%d"), date("%Y%m%d", time()-86400) }) do
		if STEPS.mine[dayStr] then
			table.insert( STEPS.addonMsgTable, "t:"..dayStr.."<"..STEPS.mine[dayStr].steps )
		end
	end
	return table.concat( STEPS.addonMsgTable, "," )
end
STEPS.keyFunctions = {
	v = function(val)
		STEPS.importVersion = val
		if not STEPS.versionAlerted and val ~= "1.1" then
			STEPS.versionAlerted = true
			STEPS.Print("There is a new version available.")
		end
	end,
	r = function(val)
		STEPS.importRealm = val
	end,
	n = function(val)
		STEPS.importName = val
	end,
	s = function(val)
		if STEPS.importRealm and STEPS.importName then
			Steps_data[STEPS.importRealm] = Steps_data[STEPS.importRealm] or {}
			Steps_data[STEPS.importRealm][STEPS.importName] = Steps_data[STEPS.importRealm][STEPS.importName] or {}
			Steps_data[STEPS.importRealm][STEPS.importName].steps = tonumber(val)
			Steps_data[STEPS.importRealm][STEPS.importName].version = STEPS.importVersion
		end
	end,
	t = function(val)
		local loc, _, date, steps = string.find(val, "(.+)<(.+)")
		print(val..":"..date..">>"..steps)
		if loc and STEPS.importRealm and STEPS.importName then
			Steps_data[STEPS.importRealm] = Steps_data[STEPS.importRealm] or {}
			Steps_data[STEPS.importRealm][STEPS.importName] = Steps_data[STEPS.importRealm][STEPS.importName] or {}
			Steps_data[STEPS.importRealm][STEPS.importName][date] = { ["steps"] = steps }
		end
	end,
}
function STEPS.DecodeMessage( msgIn )
	for k,v in string.gmatch( msgIn, "(.):([^,]+)" ) do
		print(k.."-"..v)
		if STEPS.keyFunctions[k] then
			STEPS.keyFunctions[k](v)
		end
	end
	STEPS.importRealm, STEPS.importName = nil, nil
end

-- OnUpdate
function STEPS.OnUpdate()
	local nowTS = time()
	local dateStr = date("%Y%m%d")
	if not STEPS.mine[dateStr] then STEPS.mine[dateStr] = { ["steps"] = 0 } end
	if IsMounted() or IsFlying() then
		STEPS.isMoving = false
		STEPS.lastSpeed = 0
	else
		speed = GetUnitSpeed("player")
		if speed>0 and not STEPS.isMoving then
			STEPS.isMoving = true
			STEPS.lastSpeed = speed
		end
		if speed == 0 and STEPS.isMoving then
			STEPS.isMoving = false
			STEPS.lastSpeed = speed
		end
		if speed ~= STEPS.lastSpeed then
			STEPS.lastSpeed = speed
		end
		if nowTS ~= STEPS.lastUpdate then
			local newSteps = (STEPS.steps_per_second * speed)
			STEPS.mine.steps = STEPS.mine.steps + newSteps
			if not STEPS.mine[dateStr] then
				STEPS.min, STEPS.ave, STEPS.max = STEPS.CalcMinAveMax()
			end
			STEPS.mine[dateStr] = STEPS.mine[dateStr] or { ["steps"] = 0 }
			STEPS.mine[dateStr].steps = STEPS.mine[dateStr].steps + newSteps
		end
	end
	if nowTS ~= STEPS.lastUpdate then
		STEPS.max = math.floor( math.max( STEPS.max, STEPS.mine[dateStr].steps ) )
		Steps_StepBar_1:SetMinMaxValues( 0, STEPS.max )
		Steps_StepBar_2:SetMinMaxValues( 0, STEPS.max )
		if STEPS.mine[dateStr].steps > STEPS.ave then
			Steps_StepBar_1:SetValue( STEPS.ave )
			Steps_StepBar_1:SetStatusBarColor( 0, 0, 1, 1 )
			Steps_StepBar_2:SetValue( STEPS.mine[dateStr].steps )
			Steps_StepBar_2:SetStatusBarColor( 0.5, 0.5, 0, 1 )
		else
			Steps_StepBar_2:SetValue( STEPS.ave )
			Steps_StepBar_2:SetStatusBarColor( 0, 0, 1, 1 )
			Steps_StepBar_1:SetValue( STEPS.mine[dateStr].steps )
			Steps_StepBar_1:SetStatusBarColor( 0.5, 0.5, 0, 1 )
		end
		Steps_StepBar_1:Show()
		Steps_StepBar_2:Show()

		Steps_StepBarText:SetText( STEPS.L["Steps"]..": "..math.floor( STEPS.mine[dateStr].steps ).." ("..STEPS.ave..":"..STEPS.max..")" )
	end
	STEPS.lastUpdate = nowTS
end
function STEPS.CalcMinAveMax()
	-- returns: min, ave, max
	local min, ave, max
	local sum, count = 0, 0
	local dateStr = date("%Y%m%d")
	for date, struct in pairs( STEPS.mine ) do
		if date ~= "steps" and date ~= dateStr then
			dSteps = struct.steps
			min = min and math.min(min, dSteps) or dSteps
			max = max and math.max(max, dSteps) or dSteps
			count = count + 1
			sum = sum + dSteps
		end
	end
	ave = count > 0 and sum / count or 0
	return (min and math.floor(min) or 0),
		   (ave and math.floor(ave) or 0),
		   (max and math.floor(max) or 0)
end
-- Support
function STEPS.Prune()
	local pruneTS = time() - ( STEPS.pruneDays * 86400 )
	for r, _ in pairs( Steps_data ) do
		local ncount = 0
		for n, _ in pairs( Steps_data[r] ) do
			local kcount = 0
			for k, _ in pairs( Steps_data[r][n] ) do
				if string.len(k) == 8 then
					local y = strsub( k, 1, 4 )
					local m = strsub( k, 5, 6 )
					local d = strsub( k, 7, 8 )
					local kts = time{ year=y, month=m, day=d }
					if kts < pruneTS then
						Steps_data[r][n][k] = nil
					else
						kcount = kcount + 1
					end
				end
			end
			if kcount == 0 then
				Steps_data[r][n] = nil
			else
				ncount = ncount + 1
			end
		end
		if ncount == 0 then
			Steps_data[r] = nil
		end
	end
end
function STEPS.Print( msg, showName)
	-- print to the chat frame
	-- set showName to false to suppress the addon name printing
	if (showName == nil) or (showName) then
		msg = COLOR_PURPLE..STEPS_MSG_ADDONNAME.."> "..COLOR_END..msg
	end
	DEFAULT_CHAT_FRAME:AddMessage( msg )
end
function STEPS.parseCmd(msg)
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
function STEPS.command( msg )
	local cmd, param = STEPS.parseCmd(msg)
	if STEPS.CommandList[cmd] and STEPS.CommandList[cmd].alias then
		cmd = STEPS.CommandList[cmd].alias
	end
	local cmdFunc = STEPS.CommandList[cmd]
	if cmdFunc and cmdFunc.func then
		cmdFunc.func(param)
	else
		STEPS.PrintHelp()
	end
end
function STEPS.PrintHelp()
	STEPS.Print( string.format(STEPS.L["%s (%s) by %s"], STEPS_MSG_ADDONNAME, STEPS_MSG_VERSION, STEPS_MSG_AUTHOR ) )
	for cmd, info in pairs(STEPS.CommandList) do
		if info.help then
			local cmdStr = cmd
			for c2, i2 in pairs(STEPS.CommandList) do
				if i2.alias and i2.alias == cmd then
					cmdStr = string.format( "%s / %s", cmdStr, c2 )
				end
			end
			STEPS.Print(string.format("%s %s %s -> %s",
				SLASH_STEPS1, cmdStr, info.help[1], info.help[2]))
		end
	end
end
STEPS.CommandList = {
	[""] = {
		["help"] = {STEPS.L["{steps}"], STEPS.L["Send steps to any chat"]},
	},
	[STEPS.L["help"]] = {
		["func"] = STEPS.PrintHelp,
		["help"] = {"",STEPS.L["Print this help."]}
	},
}

--[[
https://wowwiki-archive.fandom.com/wiki/API_GetUnitSpeed
value = GetUnitSpeed("unit")

Player unit moving at 100% -- value = 7
Player unit moving at 175% -- value = 12.25
Player unit moving at 200% -- value = 14

]]
