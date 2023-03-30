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

-- addon setup
FITBIT.name = "testName"
FITBIT.realm = "testRealm"
FITBIT.faction = "Alliance"

function test.before()
	FITBIT.OnLoad()
end
function test.after()
	--INEED_data = {}
	--INEED_account = {}
	--INEED_currency = {}
	--INEED.othersNeed = nil  -- this is for global tracking
end

test.run()
