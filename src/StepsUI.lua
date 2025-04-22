STEPS_SLUG, Steps = ...

Steps.UIBars = {}

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
	for dayBack=0, 6 do
		dayStr = date( "%Y%m%d", time() - (dayBack*86400) )
		outStr = "Looking at: "..dayStr.." dayBack:"..dayBack
		if Steps.mine[dayStr] then
			local steps = math.floor( Steps.mine[dayStr].steps )
			barMax = max( barMax, steps )
			outStr = outStr .. " "..steps.."/"..barMax
		end
		Steps.Print( outStr )
	end
	for dayBack = 0, 6 do
		dayStr = date( "%Y%m%d", time() - (dayBack*86400) )
		local steps = Steps.mine[dayStr] and math.floor( Steps.mine[dayStr].steps ) or 0
		Steps.UIBars[7-dayBack]:SetMinMaxValues( 0, barMax )
		Steps.UIBars[7-dayBack]:SetValue( steps )
	end
end

function Steps.AssureBars( barsNeeded )
	local count = #Steps.UIBars
	if( not InCombatLockdown() and barsNeeded > count  ) then
		Steps.Print( "I need "..barsNeeded.."/"..count.." bars." )
		for i = count+1, barsNeeded do
			Steps.Print( "Creating bar# "..i )
			local newBar = CreateFrame( "StatusBar", "Steps_Bar"..i, StepsUI_Frame, "Steps_TrendBarTemplate" )  --template can be last parameter
			newBar:SetFrameStrata( "LOW" )
			if( i == 1 ) then
				newBar:SetPoint( "TOPLEFT", "StepsUI_Frame", "TOPLEFT" )
			else
				newBar:SetPoint( "TOPLEFT", Steps.UIBars[i-1], "TOPRIGHT" )
			end
			Steps.UIBars[i] = newBar
		end
	end
	return max( count, barsNeeded )
end