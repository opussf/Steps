STEPS_SLUG, Steps = ...

Steps.MineBars = {}
Steps.HistBars = {}
Steps.XAxis = {}

function Steps.ShowTrend()
	if StepsUI_Frame:IsVisible() then
		StepsUI_Frame:Hide()
		return
	end
	StepsUI_Frame:Show()

	Steps.ShowWeek()
end
function Steps.ShowWeek()
	if Steps.AssureBars( 7, 30 ) < 7 then
		StepsUI_Frame:Hide()
		return
	end
	local dayList = {}
	for dayBack = 1, 7 do
		table.insert( dayList, date( "%a", time() + (dayBack*86400) ) )
	end
	if Steps.AssureXAxis( 7, dayList ) < 7 then
		StepsUI_Frame:Hide()
		return
	end

	local barMax = 0
	local barData = {}    -- [%Y%m%d] = {mine, total}

	for dayBack=0, 6 do
		dayStr = date( "%Y%m%d", time() - (dayBack*86400) )
		outStr = "Looking at: "..dayStr.." dayBack:"..dayBack
		barData[dayStr] = {0,0}
		for r,ra in pairs( Steps_data ) do
			for n, na in pairs( ra ) do
				if na[dayStr] then
					barData[dayStr][2] = barData[dayStr][2] + na[dayStr].steps
					barMax = max( barMax, barData[dayStr][2] )
				end
			end
		end
		if Steps.mine[dayStr] then
			local steps = math.floor( Steps.mine[dayStr].steps )
			barMax = max( barMax, steps )
			barData[dayStr][1] = steps
			outStr = outStr .. " "..steps.."/"..barMax
		end
		if Steps.debug then Steps.Print( outStr ) end
	end
	for dayBack = 0, 6 do
		dayStr = date( "%Y%m%d", time() - (dayBack*86400) )
		local steps = math.floor( barData[dayStr][1] )
		Steps.MineBars[7-dayBack]:SetMinMaxValues( 0, barMax )
		Steps.MineBars[7-dayBack]:SetValue( math.floor( barData[dayStr][1] ) )
		Steps.HistBars[7-dayBack]:SetMinMaxValues( 0, barMax )
		Steps.HistBars[7-dayBack]:SetValue( math.floor( barData[dayStr][2] ) )
	end
end
function Steps.Show2Week()
	if Steps.AssureBars( 14, 15 ) < 7 then
		StepsUI_Frame:Hide()
		return
	end
	local dayList = {}
	for dayBack = 1, 14, 2 do
		table.insert( dayList, date( "%a", time() + (dayBack*86400) ) )
	end
	if Steps.AssureXAxis( 7, dayList ) < 7 then
		StepsUI_Frame:Hide()
		return
	end

	local barMax = 0
	local barData = {}    -- [%Y%m%d] = {mine, total}

	for dayBack = 0, 13 do
		dayStr = date( "%Y%m%d", time() - (dayBack*86400) )
		outStr = "Looking at: "..dayStr.." dayBack:"..dayBack
		barData[dayStr] = {0,0}
		for r,ra in pairs( Steps_data ) do
			for n, na in pairs( ra ) do
				if na[dayStr] then
					barData[dayStr][2] = barData[dayStr][2] + na[dayStr].steps
					barMax = max( barMax, barData[dayStr][2] )
				end
			end
		end
		if Steps.mine[dayStr] then
			local steps = math.floor( Steps.mine[dayStr].steps )
			barMax = max( barMax, steps )
			barData[dayStr][1] = steps
			outStr = outStr .. " "..steps.."/"..barMax
		end
		if Steps.debug then Steps.Print( outStr ) end
	end
	for dayBack = 0, 13 do
		dayStr = date( "%Y%m%d", time() - (dayBack*86400) )
		local steps = math.floor( barData[dayStr][1] )
		Steps.MineBars[14-dayBack]:SetMinMaxValues( 0, barMax )
		Steps.MineBars[14-dayBack]:SetValue( math.floor( barData[dayStr][1] ) )
		Steps.HistBars[14-dayBack]:SetMinMaxValues( 0, barMax )
		Steps.HistBars[14-dayBack]:SetValue( math.floor( barData[dayStr][2] ) )
	end


end
function Steps.AssureBars( barsNeeded, width )
	width = width or 30
	local count = #Steps.MineBars
	if( not InCombatLockdown() and barsNeeded > count  ) then
		if Steps.debug then Steps.Print( "I need "..barsNeeded.."/"..count.." bars." ) end
		for i = count+1, barsNeeded do
			if Steps.debug then Steps.Print( "Creating bar# "..i ) end
			local newBar = CreateFrame( "StatusBar", "Steps_MineBar"..i, StepsUI_BarFrame, "Steps_TrendBarTemplate" )  --template can be last parameter
			newBar:SetFrameStrata( "MEDIUM" )
			newBar:SetStatusBarColor( unpack( Steps.stepsColor ) )  -- Should be the gold color
			if( i == 1 ) then
				newBar:SetPoint( "TOPLEFT", "StepsUI_BarFrame", "TOPLEFT" )
			else
				newBar:SetPoint( "TOPLEFT", Steps.MineBars[i-1], "TOPRIGHT" )
			end
			Steps.MineBars[i] = newBar
			newBar = CreateFrame( "StatusBar", "Steps_HistBar"..i, StepsUI_BarFrame, "Steps_TrendBarTemplate" )
			newBar:SetFrameStrata( "LOW" )
			if( i == 1 ) then
				newBar:SetPoint( "TOPLEFT", "StepsUI_BarFrame", "TOPLEFT" )
			else
				newBar:SetPoint( "TOPLEFT", Steps.HistBars[i-1], "TOPRIGHT" )
			end
			Steps.HistBars[i] = newBar
		end
	end
	for i = 1, barsNeeded do
		Steps.MineBars[i]:Show()
		Steps.MineBars[i]:SetWidth( width )
		Steps.HistBars[i]:Show()
		Steps.HistBars[i]:SetWidth( width )
	end
	for i = barsNeeded+1, count do
		Steps.MineBars[i]:Hide()
		Steps.HistBars[i]:Hide()
	end
	return max( count, barsNeeded )
end
function Steps.AssureXAxis( needed, labels )
	local count = #Steps.XAxis
	if( not InCombatLockdown() and needed > count ) then
		if Steps.debug then Steps.Print( "I need "..needed.."/"..count.." XAxis." ) end
		local dayIndex = 1
		for i = count+1, needed do
			if Steps.debug then Steps.Print( "Creating XAxis# "..i ) end
			local newButton = CreateFrame( "Button", "Steps_XAxis"..i, StepsUI_Frame, "Steps_XAxisButtonTemplate" )
			newButton:SetSize( 30, 20 )
			if( i == 1 ) then
				newButton:SetPoint( "BOTTOMLEFT", "StepsUI_Frame", "BOTTOMLEFT" )
			else
				newButton:SetPoint( "BOTTOMLEFT", Steps.XAxis[i-1], "BOTTOMRIGHT" )
			end
			newButton:SetText( labels[dayIndex] )
			dayIndex = dayIndex + 1
			Steps.XAxis[i] = newButton
		end
	end
	for i = 1, needed do
		Steps.XAxis[i]:SetText( labels[i] )
		Steps.XAxis[i]:Show()
	end
	for i = needed+1, count do
		Steps.XAxis[i]:Hide()
	end
	return max( count, needed )
end