#!/usr/bin/env lua

require "wowTest"
--myLocale = "esMX"

test.outFileName = "testOut.xml"

-- require the file to test
ParseTOC( "../src/Steps.toc" )

-- Figure out how to parse the XML here, until then....
Steps_Frame = CreateFrame()
Steps_StepBar = CreateStatusBar()
Steps_StepBarText = CreateFrame()

-- addon setup
STEPS.name = "testName"
STEPS.realm = "testRealm"
STEPS.faction = "Alliance"
dateStr = date("%Y%m%d")

function test.before()
	STEPS.OnLoad()
	STEPS.ADDON_LOADED()
	STEPS.VARIABLES_LOADED()
end
function test.after()
	Steps_log = {}
	Steps_data = {}
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
	STEPS.command()
end
function test.test_commandHelp()
	STEPS.command( "help" )
end
function test.test_UI_Text()
	unitSpeeds.player = 7
	STEPS.isMoving = true
	STEPS.lastSpeed = 7
	STEPS.lastUpdate = time() - 1
	STEPS.OnUpdate()
	assertEquals( 'Steps: 2', Steps_StepBarText:GetText() )
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

test.run()
