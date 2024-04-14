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
STEPS.name = "testName"
STEPS.realm = "testRealm"
STEPS.faction = "Alliance"
dateStr = date("%Y%m%d")
STEPS.commPrefix = "STEPS"
Steps_options.show = true

function test.before()
	STEPS.OnLoad()
	STEPS.ADDON_LOADED()
	STEPS.VARIABLES_LOADED()
	STEPS.LOADING_SCREEN_DISABLED()
end
function test.after()
	Steps_log = {}
	Steps_data = {}
	myParty = { ["group"] = nil, ["raid"] = nil, ["roster"] = {} }
end
function test.test_playerStartsMoving()
	unitSpeeds.player = 7 -- 100% speed
	STEPS.isMoving = nil
	STEPS.OnUpdate()
	assertTrue( STEPS.isMoving )
	assertEquals( 7, STEPS.lastSpeed )
end
function test.test_playerMovingSameSpeed()
	unitSpeeds.player = 7
	STEPS.isMoving = true
	STEPS.OnUpdate()
	assertTrue( STEPS.isMoving )
	assertEquals( 7, STEPS.lastSpeed )
end
function test.test_playerChangesSpeed()
	unitSpeeds.player = 14
	STEPS.isMoving = true
	STEPS.lastSpeed = 7
	STEPS.OnUpdate()
	assertTrue( STEPS.isMoving )
	assertEquals( 14, STEPS.lastSpeed )
end
function test.test_playerStops()
	unitSpeeds.player = 0
	STEPS.isMoving = true
	STEPS.lastSpeed = 7
	STEPS.OnUpdate()
	assertFalse( STEPS.isMoving )
	assertEquals( 0, STEPS.lastSpeed )
end
function test.test_speed7()
	unitSpeeds.player = 7
	STEPS.isMoving = true
	STEPS.lastSpeed = 7
	STEPS.lastUpdate = time() - 1
	STEPS.OnUpdate()
	assertEquals( 2, Steps_data["testRealm"]["testPlayer"][dateStr].steps )
end
function test.test_speed12_5()
	unitSpeeds.player = 12.5
	STEPS.isMoving = true
	STEPS.lastSpeed = 12.5
	STEPS.lastUpdate = time() - 1
	STEPS.OnUpdate()
	assertEquals( 357, math.floor( Steps_data["testRealm"]["testPlayer"][dateStr].steps * 100) )
end
function test.test_speed14()
	unitSpeeds.player = 14
	STEPS.isMoving = true
	STEPS.lastSpeed = 14
	STEPS.lastUpdate = time() - 1
	STEPS.OnUpdate()
	assertEquals( 4, Steps_data["testRealm"]["testPlayer"][dateStr].steps )
end
function test.test_replace_single()
	unitSpeeds.player = 7
	STEPS.isMoving = true
	STEPS.lastSpeed = 7
	STEPS.lastUpdate = time() - 1
	STEPS.OnUpdate()
	assertEquals( "My steps today: 2", STEPS.ReplaceMessage( "{step}" ) )
end
function test.test_replace_plural()
	unitSpeeds.player = 7
	STEPS.isMoving = true
	STEPS.lastSpeed = 7
	STEPS.lastUpdate = time() - 1
	STEPS.OnUpdate()
	assertEquals( "My steps today: 2", STEPS.ReplaceMessage( "{steps}" ) )
end
function test.test_command()
	STEPS.Command()
end
function test.test_commandHelp()
	STEPS.Command( "help" )
end
function test.test_UI_Text()
	unitSpeeds.player = 7
	STEPS.isMoving = true
	STEPS.lastSpeed = 7
	STEPS.lastUpdate = time() - 1
	STEPS.OnUpdate()
	assertEquals( 'Steps: 2 (0:2)', Steps_StepBarText:GetText() )
end
function test.test_prune_removeDays()
	-- just remove old data
	oldDateStr = date( "%Y%m%d", time() - (92*86400) )
	Steps_data["testRealm"]["testPlayer"][oldDateStr] = {["steps"] = 500}
	Steps_data["testRealm"]["testPlayer"][date("%Y%m%d")] = {["steps"] = 100}
	Steps_data["testRealm"]["testPlayer"].steps = 600
	STEPS.Prune()
	assertIsNil( Steps_data["testRealm"]["testPlayer"][oldDateStr] )
	assertEquals( 100, Steps_data["testRealm"]["testPlayer"][date("%Y%m%d")].steps )
end
function test.test_prune_removePlayer()
	oldDateStr = date( "%Y%m%d", time() - (95*86400) )
	Steps_data["testRealm"]["otherPlayer"] = {[oldDateStr] = {["steps"] = 500}, ["steps"] = 500}
	Steps_data["testRealm"]["otherPlayer"].steps = 500
	Steps_data["testRealm"]["testPlayer"] = {[date("%Y%m%d")] = {["steps"] = 100}, ["steps"] = 100}
	STEPS.Prune()
	assertIsNil( Steps_data["testRealm"]["otherPlayer"] )
end
function test.test_prune_removeRealm()
	Steps_data["otherRealm"] = {}
	STEPS.Prune()
	assertIsNil( Steps_data["otherRealm"] )
end
function test.test_missing_key()
	unitSpeeds.player = 7
	STEPS.isMoving = true
	STEPS.lastSpeed = 7
	STEPS.lastUpdate = time() - 1
	STEPS.OnUpdate()
	Steps_data["testRealm"]["testPlayer"][date("%Y%m%d")] = nil
	STEPS.OnUpdate()
	assertEquals( 0, Steps_data["testRealm"]["testPlayer"][date("%Y%m%d")].steps )
end
function test.prep_minavemax_data()
	for dayBack = 0,80 do
		dataDay = date( "%Y%m%d", time() - (dayBack * 86400) )
		Steps_data["testRealm"]["testPlayer"][dataDay] = {["steps"] = dayBack*2000}
		Steps_data["testRealm"]["testPlayer"].steps = Steps_data["testRealm"]["testPlayer"].steps + dayBack
	end
end
function test.test_minavemax_min()
	test.prep_minavemax_data()
	min, ave, max = STEPS.CalcMinAveMax()
	assertEquals( 2000, min )
end
function test.test_minavemax_ave()
	test.prep_minavemax_data()
	min, ave, max = STEPS.CalcMinAveMax()
	assertEquals( 81000, ave )
end
function test.test_minavemax_max()
	test.prep_minavemax_data()
	min, ave, max = STEPS.CalcMinAveMax()
	assertEquals( 160000, max )
end
function test.test_minavemax_min_withZeros()
	test.prep_minavemax_data()
	dataDay = date( "%Y%m%d", time() - (1 * 86400) )
	Steps_data["testRealm"]["testPlayer"][dataDay] = {["steps"] = 0}
	min, ave, max = STEPS.CalcMinAveMax()
	assertEquals( 4000, min )
end
function test.test_minavemax_ave_withZeros()
	test.prep_minavemax_data()
	dataDay = date( "%Y%m%d", time() - (1 * 86400) )
	Steps_data["testRealm"]["testPlayer"][dataDay] = {["steps"] = 0}
	min, ave, max = STEPS.CalcMinAveMax()
	assertEquals( 82000, ave )
end

--  SEND_ADDON_MESSAGES
function test.notest_send()
	test.prep_minavemax_data()
	STEPS.LOADING_SCREEN_DISABLED()
	-- for i = 1,string.len(STEPS.addonMsg) do
	-- 	print( string.format( "%s = 0x%x", string.sub( STEPS.addonMsg, i, i ), string.byte( STEPS.addonMsg, i ) ) )
	-- end
	assertTrue( string.len( STEPS.addonMsg ) < 255, "STEPS.addonMsg length ("..string.len( STEPS.addonMsg )..") is 255 or more characters." )
	-- assertEquals( "@VERSION@|testRealm|testPlayer|"..string.char(0x99)..string.char(0xa8), STEPS.addonMsg )
	assertEquals( "@VERSION@|testRealm|testPlayer|"..string.char(0x99)..string.char(0xa8).."|", string.sub( STEPS.addonMsg, 1, 34 ) )
end
function test.notest_decode_steps_single()
	STEPS.versionAlerted = nil
	STEPS.CHAT_MSG_ADDON( {}, "STEPS", "0.0|wonkRealm|wonkPlayer|"..string.char(0x87)..string.char(0xe1), "GUILD", "joeBob" )
	assertTrue( Steps_data["wonkRealm"]["wonkPlayer"] )
	assertEquals( 993, Steps_data["wonkRealm"]["wonkPlayer"].steps )
	assertEquals( "0.0", Steps_data["wonkRealm"]["wonkPlayer"].version )
	assertIsNil( STEPS.importRealm )
	assertIsNil( STEPS.importName )
	assertIsNil( STEPS.versionAlerted )
end
function test.notest_decode_steps_sets_versionAlerted()
	STEPS.versionAlerted = nil
	STEPS.CHAT_MSG_ADDON( {}, "STEPS", "0.1|wonkRealm|wonkPlayer|"..string.char(0x87)..string.char(0xe1), "GUILD", "joeBob" )
	assertEquals( 993, Steps_data["wonkRealm"]["wonkPlayer"].steps )
	assertEquals( "0.1", Steps_data["wonkRealm"]["wonkPlayer"].version )
	assertIsNil( STEPS.importRealm )
	assertIsNil( STEPS.importName )
	assertTrue( STEPS.versionAlerted )
end
function test.test_decode_steps_with_history()
	STEPS.versionAlerted = nil
	stepstoday = string.format("%s%s", select(2, STEPS.toBytes(tonumber(date("%Y%m%d")))), select(2, STEPS.toBytes(512)) )

	STEPS.CHAT_MSG_ADDON( {}, "STEPS", "0.1|wonkRealm|wonkPlayer|"..string.char(0x87)..string.char(0xe1).."|"..stepstoday, "GUILD", "joeBob" )
	assertEquals( 993, Steps_data["wonkRealm"]["wonkPlayer"].steps )
	assertEquals( "0.1", Steps_data["wonkRealm"]["wonkPlayer"].version )
	assertEquals( 512, Steps_data["wonkRealm"]["wonkPlayer"][date("%Y%m%d")].steps )
	assertIsNil( STEPS.importRealm )
	assertIsNil( STEPS.importName )
	assertTrue( STEPS.versionAlerted )
end
function test.test_send_info_again()
	Steps_data = { wonkRealm = { wonkPlayer = { steps = 15, [date("%Y%m%d")] = { steps = 15 } } } }
	steps = select(2, STEPS.toBytes(42))
	stepstoday = string.format("%s%s", select(2, STEPS.toBytes(tonumber(date("%Y%m%d")))), steps )

	STEPS.CHAT_MSG_ADDON( {}, "STEPS", "0.1|wonkRealm|wonkPlayer|"..steps.."|"..stepstoday, "GUILD", "wonkPlayer-wonkRealm")
	assertEquals( 42, Steps_data["wonkRealm"]["wonkPlayer"].steps )
	assertEquals( 42, Steps_data["wonkRealm"]["wonkPlayer"][date("%Y%m%d")].steps )
end
function test.test_decode_steps_older_version()
	STEPS.versionAlerted = nil
	STEPS.CHAT_MSG_ADDON( {}, "STEPS", "v:0.1,r:wonkRealm,n:wonkPlayer,s:42,t:"..date("%Y%m%d").."<42", "GUILD", "wonkPlayer-wonkRealm")
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
	STEPS.TooltipSetUnit( )
	assertEquals( "Steps today: 6 total: 15", GameTooltip.line )
end
-- Version tests
function test.test_version_to_str_tag_2()
	assertEquals( 10200, STEPS.VersionStrToVal( "1.2" ) )
end
function test.test_version_to_str_tag_3()
	assertEquals( 20304, STEPS.VersionStrToVal( "2.3.4" ) )
end
function test.test_version_to_str_offtag_branch()
	assertEquals( 10100, STEPS.VersionStrToVal( "1.1-version" ) )
end
function test.test_version_to_str_offtag_branch_commits()
	assertEquals( 10100, STEPS.VersionStrToVal( "1.1-6-g0526e5e-develop" ) )
end
function test.test_version_replacestr()
	assertEquals( 0, STEPS.VersionStrToVal( "@VERSION@" ) )
end
-- Post
function test.test_get_postString()
	assertEquals( "My steps today: 0", STEPS.GetPostString() )
end
function test.test_post_say()
	chatLog = {}
	STEPS.Command( "say" )
	assertEquals( "SAY", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_yell()
	chatLog = {}
	STEPS.Command( "yell" )
	assertEquals( "YELL", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_guild()
	chatLog = {}
	STEPS.Command( "guild" )
	assertEquals( "GUILD", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_party()
	myParty.party = true
	STEPS.Command( "party" )
	assertEquals( "PARTY", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_party2()
	myParty.party = true
	STEPS.Command( "instance" )
	assertEquals( "PARTY", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_instance()
	myParty.instance = true
	STEPS.Command( "instance" )
	assertEquals( "INSTANCE_CHAT", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_raid()
	myParty.raid = true
	STEPS.Command( "raid" )
	assertEquals( "RAID", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
function test.test_post_whisper()
	STEPS.Command( "whisper otherPlayer" )
	assertEquals( "WHISPER", chatLog[#chatLog].chatType )
	assertEquals( "My steps today: 0", chatLog[#chatLog].msg )
end
test.run()
