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

function test.before()
	FITBIT.OnLoad()
	FITBIT.VARIABLES_LOADED()
end
function test.after()
	Fitbit_log = {}
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


end


test.run()
