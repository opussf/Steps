#!/usr/bin/env lua

require "wowTest"

test.outFileName = "testOut.xml"

-- Figure out how to parse the XML here, until then....
INEED_SplashFrame = { ["Show"] = function() end,
		["AddMessage"] = function(msg) print( "SPLASHFRAME:", (msg or "")) end,
}
INEED_Frame = CreateFrame()
SendMailNameEditBox = CreateFontString("SendMailNameEditBox")
INEEDUIListFrame = CreateFrame()
INEEDUIListFrame_TitleText = INEEDUIListFrame.CreateFontString()

-- require the file to test
ParseTOC( "../src/Fitbit.toc" )

Fitbit_Frame = CreateFrame()
Fitbit_StepBar = CreateStatusBar()
Fitbit_StepBarText = CreateFrame()

-- addon setup
FITBIT.name = "testName"
FITBIT.realm = "testRealm"
FITBIT.faction = "Alliance"
dateStr = date("%Y%m%d")

function test.before()
	FITBIT.OnLoad()
	FITBIT.ADDON_LOADED()
	FITBIT.VARIABLES_LOADED()
	myLocale = "esES"
end
function test.after()
	Fitbit_log = {}
	Fitbit_data = {}
end
function test.test_playerStartsMoving()
	unitSpeeds.player = 7 -- 100% speed
	FITBIT.isMoving = nil
	FITBIT.OnUpdate()
	assertTrue( FITBIT.isMoving )
	assertEquals( 7, FITBIT.lastSpeed )
end
function test.test_playerMovingSameSpeed()
	unitSpeeds.player = 7
	FITBIT.isMoving = true
	FITBIT.OnUpdate()
	assertTrue( FITBIT.isMoving )
	assertEquals( 7, FITBIT.lastSpeed )
end
function test.test_playerChangesSpeed()
	unitSpeeds.player = 14
	FITBIT.isMoving = true
	FITBIT.lastSpeed = 7
	FITBIT.OnUpdate()
	assertTrue( FITBIT.isMoving )
	assertEquals( 14, FITBIT.lastSpeed )
end
function test.test_playerStops()
	unitSpeeds.player = 0
	FITBIT.isMoving = true
	FITBIT.lastSpeed = 7
	FITBIT.OnUpdate()
	assertFalse( FITBIT.isMoving )
	assertEquals( 0, FITBIT.lastSpeed )
end
function test.test_speed7()
	unitSpeeds.player = 7
	FITBIT.isMoving = true
	FITBIT.lastSpeed = 7
	FITBIT.lastUpdate = time() - 1
	FITBIT.OnUpdate()
	assertEquals( 2, Fitbit_data["testRealm"]["testPlayer"][dateStr].steps )
end
function test.test_speed12_5()
	unitSpeeds.player = 12.5
	FITBIT.isMoving = true
	FITBIT.lastSpeed = 12.5
	FITBIT.lastUpdate = time() - 1
	FITBIT.OnUpdate()
	assertEquals( 357, math.floor( Fitbit_data["testRealm"]["testPlayer"][dateStr].steps * 100) )
end
function test.test_speed14()
	unitSpeeds.player = 14
	FITBIT.isMoving = true
	FITBIT.lastSpeed = 14
	FITBIT.lastUpdate = time() - 1
	FITBIT.OnUpdate()
	assertEquals( 4, Fitbit_data["testRealm"]["testPlayer"][dateStr].steps )
end
function test.test_replace()
	unitSpeeds.player = 7
	FITBIT.isMoving = true
	FITBIT.lastSpeed = 7
	FITBIT.lastUpdate = time() - 1
	FITBIT.OnUpdate()
	assertEquals( "My steps today: 2", FITBIT.ReplaceMessage( "{fb}" ) )
end
function test.test_command()
	FITBIT.command()
end
function test.test_commandHelp()
	FITBIT.command( "help" )
end
function test.test_prune_removeDays()
	-- just remove old data
	oldDateStr = date( "%Y%m%d", time() - (92*86400) )
	Fitbit_data["testRealm"]["testPlayer"][oldDateStr] = {["steps"] = 500}
	Fitbit_data["testRealm"]["testPlayer"][date("%Y%m%d")] = {["steps"] = 100}
	Fitbit_data["testRealm"]["testPlayer"].steps = 600
	FITBIT.Prune()
	assertIsNil( Fitbit_data["testRealm"]["testPlayer"][oldDateStr] )
	assertEquals( 100, Fitbit_data["testRealm"]["testPlayer"][date("%Y%m%d")].steps )
end
function test.test_prune_removePlayer()
	oldDateStr = date( "%Y%m%d", time() - (95*86400) )
	Fitbit_data["testRealm"]["otherPlayer"] = {[oldDateStr] = {["steps"] = 500}, ["steps"] = 500}
	Fitbit_data["testRealm"]["otherPlayer"].steps = 500
	Fitbit_data["testRealm"]["testPlayer"] = {[date("%Y%m%d")] = {["steps"] = 100}, ["steps"] = 100}
	FITBIT.Prune()
	assertIsNil( Fitbit_data["testRealm"]["otherPlayer"] )
end
function test.test_prune_removeRealm()
	Fitbit_data["otherRealm"] = {}
	FITBIT.Prune()
	assertIsNil( Fitbit_data["otherRealm"] )
end

test.run()
