STEPS_SLUG, Steps = ...

Steps.MineBars = {}
Steps.HistBars = {}

function Steps.ShowTrend()
	if StepsUI_Frame:IsVisible() then
		StepsUI_Frame:Hide()
		return
	end
	StepsUI_Frame:Show()

	if Steps.AssureBars( 7 ) < 7 then
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
		Steps.Print( outStr )
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

function Steps.AssureBars( barsNeeded )
	local count = #Steps.MineBars
	if( not InCombatLockdown() and barsNeeded > count  ) then
		Steps.Print( "I need "..barsNeeded.."/"..count.." bars." )
		for i = count+1, barsNeeded do
			Steps.Print( "Creating bar# "..i )
			local newBar = CreateFrame( "StatusBar", "Steps_MineBar"..i, StepsUI_Frame, "Steps_TrendBarTemplate" )  --template can be last parameter
			newBar:SetFrameStrata( "LOW" )
			if( i == 1 ) then
				newBar:SetPoint( "TOPLEFT", "StepsUI_Frame", "TOPLEFT" )
			else
				newBar:SetPoint( "TOPLEFT", Steps.MineBars[i-1], "TOPRIGHT" )
			end
			Steps.MineBars[i] = newBar
			newBar = CreateFrame( "StatusBar", "Steps_HistBar"..i, StepsUI_Frame, "Steps_TrendBarTemplate" )
			newBar:SetFrameStrata( "LOW" )
			if( i == 1 ) then
				newBar:SetPoint( "TOPLEFT", "StepsUI_Frame", "TOPLEFT" )
			else
				newBar:SetPoint( "TOPLEFT", Steps.HistBars[i-1], "TOPRIGHT" )
			end
			Stes.HistBars[i] = newBar
		end
	end
	return max( count, barsNeeded )
end