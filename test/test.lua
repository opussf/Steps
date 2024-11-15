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

test.run()
