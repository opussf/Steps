#!/usr/bin/env lua

require "wowTest"
--myLocale = "esMX"

test.outFileName = "testOut.xml"

-- require the file to test
ParseTOC( "../src/Steps.toc" )

-- Figure out how to parse the XML here, until then....
Steps_Frame = CreateFrame()
Steps_StepBar_1 = CreateStatusBar()
Steps_StepBar_2 = CreateStatusBar()
Steps_StepBarText = CreateFrame()
GameTooltip = FrameGameTooltip

-- addon setup
Steps.name = "testName"
Steps.realm = "Test Realm"
Steps.faction = "Alliance"
dateStr = date("%Y%m%d")
Steps.commPrefix = "Steps"
Steps_options.show = true

function test.before()
	Steps.OnLoad()
	Steps.ADDON_LOADED()
	Steps.VARIABLES_LOADED()
	Steps.LOADING_SCREEN_DISABLED()
end
function test.after()
	Steps_log = {}
	Steps_data = {}
	myParty = { ["group"] = nil, ["raid"] = nil, ["roster"] = {} }
end
function test.test_playerStartsMoving()
	unitSpeeds.player = 7 -- 100% speed
	Steps.isMoving = nil
	Steps.OnUpdate()
	assertTrue( Steps.isMoving )
	assertEquals( 7, Steps.lastSpeed )
end
function test.test_playerMovingSameSpeed()
	unitSpeeds.player = 7
	Steps.isMoving = true
	Steps.OnUpdate()
	assertTrue( Steps.isMoving )
	assertEquals( 7, Steps.lastSpeed )
end
function test.test_playerChangesSpeed()
	unitSpeeds.player = 14
	Steps.isMoving = true
	Steps.lastSpeed = 7
	Steps.OnUpdate()
	assertTrue( Steps.isMoving )
	assertEquals( 14, Steps.lastSpeed )
end
function test.test_playerStops()
	unitSpeeds.player = 0
	Steps.isMoving = true
	Steps.lastSpeed = 7
	Steps.OnUpdate()
	assertFalse( Steps.isMoving )
	assertEquals( 0, Steps.lastSpeed )
end
function test.test_speed7()
	unitSpeeds.player = 7
	Steps.isMoving = true
	Steps.lastSpeed = 7
	Steps.lastUpdate = time() - 1
	Steps.OnUpdate()
	assertEquals( 2, Steps_data["Test Realm"]["testPlayer"][dateStr].steps )
end
function test.test_speed12_5()
	unitSpeeds.player = 12.5
	Steps.isMoving = true
	Steps.lastSpeed = 12.5
	Steps.lastUpdate = time() - 1
	Steps.OnUpdate()
	assertEquals( 357, math.floor( Steps_data["Test Realm"]["testPlayer"][dateStr].steps * 100) )
end
function test.test_speed14()
	unitSpeeds.player = 14
	Steps.isMoving = true
	Steps.lastSpeed = 14
	Steps.lastUpdate = time() - 1
	Steps.OnUpdate()
	assertEquals( 4, Steps_data["Test Realm"]["testPlayer"][dateStr].steps )
end
function test.test_replace_single()
	unitSpeeds.player = 7
	Steps.isMoving = true
	Steps.lastSpeed = 7
	Steps.lastUpdate = time() - 1
	Steps.OnUpdate()
	assertEquals( "My steps today: 2", Steps.ReplaceMessage( "{step}" ) )
end
function test.test_replace_plural()
	unitSpeeds.player = 7
	Steps.isMoving = true
	Steps.lastSpeed = 7
	Steps.lastUpdate = time() - 1
	Steps.OnUpdate()
	assertEquals( "My steps today: 2", Steps.ReplaceMessage( "{steps}" ) )
end
function test.test_command()
	Steps.Command()
end
function test.test_commandHelp()
	Steps.Command( "help" )
end
function test.test_UI_Text()
	unitSpeeds.player = 7
	Steps.isMoving = true
	Steps.lastSpeed = 7
	Steps.lastUpdate = time() - 1
	Steps.OnUpdate()
	assertEquals( 'Steps: 2 (0:2)', Steps_StepBarText:GetText() )
end
function test.test_prune_removeDays()
	-- just remove old data
	oldDateStr = date( "%Y%m%d", time() - (92*86400) )
	Steps_data["Test Realm"]["testPlayer"][oldDateStr] = {["steps"] = 500}
	Steps_data["Test Realm"]["testPlayer"][date("%Y%m%d")] = {["steps"] = 100}
	Steps_data["Test Realm"]["testPlayer"].steps = 600
	Steps.Prune()
	assertIsNil( Steps_data["Test Realm"]["testPlayer"][oldDateStr] )
	assertEquals( 100, Steps_data["Test Realm"]["testPlayer"][date("%Y%m%d")].steps )
end
function test.test_prune_removePlayer()
	oldDateStr = date( "%Y%m%d", time() - (95*86400) )
	Steps_data["Test Realm"]["otherPlayer"] = {[oldDateStr] = {["steps"] = 500}, ["steps"] = 500}
	Steps_data["Test Realm"]["otherPlayer"].steps = 500
	Steps_data["Test Realm"]["testPlayer"] = {[date("%Y%m%d")] = {["steps"] = 100}, ["steps"] = 100}
	Steps.Prune()
	assertIsNil( Steps_data["Test Realm"]["otherPlayer"] )
end
function test.test_prune_removeRealm()
	Steps_data["otherRealm"] = {}
	Steps.Prune()
	assertIsNil( Steps_data["otherRealm"] )
end
function test.test_missing_key()
	unitSpeeds.player = 7
	Steps.isMoving = true
	Steps.lastSpeed = 7
	Steps.lastUpdate = time() - 1
	Steps.OnUpdate()
	Steps_data["Test Realm"]["testPlayer"][date("%Y%m%d")] = nil
	Steps.OnUpdate()
	assertEquals( 0, Steps_data["Test Realm"]["testPlayer"][date("%Y%m%d")].steps )
end
function test.prep_minavemax_data()
	for dayBack = 0,80 do
		dataDay = date( "%Y%m%d", time() - (dayBack * 86400) )
		Steps_data["Test Realm"]["testPlayer"][dataDay] = {["steps"] = dayBack*2000}
		Steps_data["Test Realm"]["testPlayer"].steps = Steps_data["Test Realm"]["testPlayer"].steps + dayBack
	end
end
function test.test_minavemax_min()
	test.prep_minavemax_data()
	min, ave, max = Steps.CalcMinAveMax()
	assertEquals( 2000, min )
end
function test.test_minavemax_ave()
	test.prep_minavemax_data()
	min, ave, max = Steps.CalcMinAveMax()
	assertEquals( 81000, ave )
end
function test.test_minavemax_max()
	test.prep_minavemax_data()
	min, ave, max = Steps.CalcMinAveMax()
	assertEquals( 160000, max )
end
function test.test_minavemax_min_withZeros()
	test.prep_minavemax_data()
	dataDay = date( "%Y%m%d", time() - (1 * 86400) )
	Steps_data["Test Realm"]["testPlayer"][dataDay] = {["steps"] = 0}
	min, ave, max = Steps.CalcMinAveMax()
	assertEquals( 4000, min )
end
function test.test_minavemax_ave_withZeros()
	test.prep_minavemax_data()
	dataDay = date( "%Y%m%d", time() - (1 * 86400) )
	Steps_data["Test Realm"]["testPlayer"][dataDay] = {["steps"] = 0}
	min, ave, max = Steps.CalcMinAveMax()
	assertEquals( 82000, ave )
end

--  SEND_ADDON_MESSAGES
function test.notest_send()
	test.prep_minavemax_data()
	Steps.LOADING_SCREEN_DISABLED()
	-- for i = 1,string.len(Steps.addonMsg) do
	-- 	print( string.format( "%s = 0x%x", string.sub( Steps.addonMsg, i, i ), string.byte( Steps.addonMsg, i ) ) )
	-- end
	assertTrue( string.len( Steps.addonMsg ) < 255, "Steps.addonMsg length ("..string.len( Steps.addonMsg )..") is 255 or more characters." )
	-- assertEquals( "@VERSION@|Test Realm|testPlayer|"..string.char(0x99)..string.char(0xa8), Steps.addonMsg )
	assertEquals( "@VERSION@|Test Realm|testPlayer|"..string.char(0x99)..string.char(0xa8).."|", string.sub( Steps.addonMsg, 1, 34 ) )
end
function test.notest_decode_steps_single()
	Steps.versionAlerted = nil
	Steps.CHAT_MSG_ADDON( {}, "Steps", "0.0|wonkRealm|wonkPlayer|"..string.char(0x87)..string.char(0xe1), "GUILD", "joeBob" )
	assertTrue( Steps_data["wonkRealm"]["wonkPlayer"] )
	assertEquals( 993, Steps_data["wonkRealm"]["wonkPlayer"].steps )
	assertEquals( "0.0", Steps_data["wonkRealm"]["wonkPlayer"].version )
	assertIsNil( Steps.importRealm )
	assertIsNil( Steps.importName )
	assertIsNil( Steps.versionAlerted )
end
function test.notest_decode_steps_sets_versionAlerted()
	Steps.versionAlerted = nil
	Steps.CHAT_MSG_ADDON( {}, "Steps", "0.1|wonkRealm|wonkPlayer|"..string.char(0x87)..string.char(0xe1), "GUILD", "joeBob" )
	assertEquals( 993, Steps_data["wonkRealm"]["wonkPlayer"].steps )
	assertEquals( "0.1", Steps_data["wonkRealm"]["wonkPlayer"].version )
	assertIsNil( Steps.importRealm )
	assertIsNil( Steps.importName )
	assertTrue( Steps.versionAlerted )
end
function test.test_decode_steps_with_history()
	Steps.versionAlerted = nil
	stepstoday = string.format("%s%s", select(2, Steps.toBytes(tonumber(date("%Y%m%d")))), select(2, Steps.toBytes(512)) )

	Steps.CHAT_MSG_ADDON( {}, "Steps", "0.1|wonkRealm|wonkPlayer|"..string.char(0x87)..string.char(0xe1).."|"..stepstoday, "GUILD", "joeBob" )
	assertEquals( 993, Steps_data["wonkRealm"]["wonkPlayer"].steps )
	assertEquals( "0.1", Steps_data["wonkRealm"]["wonkPlayer"].version )
	assertEquals( 512, Steps_data["wonkRealm"]["wonkPlayer"][date("%Y%m%d")].steps )
	assertIsNil( Steps.importRealm )
	assertIsNil( Steps.importName )
	assertTrue( Steps.versionAlerted )
end
function test.test_send_info_again()
	Steps_data = { wonkRealm = { wonkPlayer = { steps = 15, [date("%Y%m%d")] = { steps = 15 } } } }
	steps = select(2, Steps.toBytes(42))
	stepstoday = string.format("%s%s", select(2, Steps.toBytes(tonumber(date("%Y%m%d")))), steps )

	Steps.CHAT_MSG_ADDON( {}, "Steps", "0.1|wonkRealm|wonkPlayer|"..steps.."|"..stepstoday, "GUILD", "wonkPlayer-wonkRealm")
	assertEquals( 42, Steps_data["wonkRealm"]["wonkPlayer"].steps )
	assertEquals( 42, Steps_data["wonkRealm"]["wonkPlayer"][date("%Y%m%d")].steps )
end
function test.test_decode_steps_older_version()
	Steps.versionAlerted = nil
	Steps.CHAT_MSG_ADDON( {}, "Steps", "v:0.1,r:wonkRealm,n:wonkPlayer,s:42,t:"..date("%Y%m%d").."<42", "GUILD", "wonkPlayer-wonkRealm")
	assertEquals( 42, Steps_data["wonkRealm"]["wonkPlayer"].steps )
	assertEquals( 42, Steps_data["wonkRealm"]["wonkPlayer"][date("%Y%m%d")].steps )
end
function test.test_send_info_timezones()
	GameTooltip.name = "mousename"
	Steps_data = { mouserealm = { mousename = { steps = 15,
			[date("%Y%m%d", time()+86400)] = { steps = 6 },
			[date("%Y%m%d", time())] = { steps = 5 },
			[date("%Y%m%d", time()-86400)] = { steps = 4 },
	} } }
	Steps.TooltipSetUnit( )
	assertEquals( "Steps today: 6 total: 15", GameTooltip.line )
end
-- Version tests
function test.test_version_to_str_tag_2()
	assertEquals( 10200, Steps.VersionStrToVal( "1.2" ) )
end
function test.test_version_to_str_tag_3()
	assertEquals( 20304, Steps.VersionStrToVal( "2.3.4" ) )
end
function test.test_version_to_str_offtag_branch()
	assertEquals( 10100, Steps.VersionStrToVal( "1.1-version" ) )
end
function test.test_version_to_str_offtag_branch_commits()
	assertEquals( 10100, Steps.VersionStrToVal( "1.1-6-g0526e5e-develop" ) )
end
function test.test_version_replacestr()
	assertEquals( 0, Steps.VersionStrToVal( "@VERSION@" ) )
end
-- Post
function test.test_get_postString()
	assertEquals( "My steps today: 0", Steps.GetPostString() )
end
function test.test_post_say()
	chatLog = {}
	Steps.Command( "say" )
	assertEquals( "SAY", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_yell()
	chatLog = {}
	Steps.Command( "yell" )
	assertEquals( "YELL", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_guild()
	chatLog = {}
	Steps.Command( "guild" )
	assertEquals( "GUILD", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_party()
	myParty.party = true
	Steps.Command( "party" )
	assertEquals( "PARTY", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_party2()
	myParty.party = true
	Steps.Command( "instance" )
	assertEquals( "PARTY", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_instance()
	myParty.instance = true
	Steps.Command( "instance" )
	assertEquals( "INSTANCE_CHAT", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_raid()
	myParty.raid = true
	Steps.Command( "raid" )
	assertEquals( "RAID", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_whisper()
	Steps.Command( "whisper otherPlayer" )
	assertEquals( "WHISPER", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
-- function test.test_denormalize_01()
-- 	assertEquals( "Aerie Peak", Steps.DeNormalizeRealm( "AeriePeak") )
-- 	assertEquals( "Sisters of Elune", Steps.DeNormalizeRealm( "SistersofElune") )
-- 	assertEquals( "The Forgotten Coast", Steps.DeNormalizeRealm( "TheForgottenCoast" ) )
-- end
test.run()
