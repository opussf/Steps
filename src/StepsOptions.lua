-- STEPSOptions @VERSION@
function STEPS.OptionsPanel_OnLoad( panel )
	panel.name = "Steps"
	STEPSOptionsFrame_Title:SetText(STEPS_MSG_ADDONNAME.." "..STEPS_MSG_VERSION)
	panel.okay = STEPS.OptionsPanel_OKAY
	panel.cancel = STEPS.OptionsPanel_Cancel
	-- panel.refresh = INEED.OptionsPanel_Refresh

	InterfaceOptions_AddCategory(panel)
end

-- function INEED.OptionsPanel_Reset()
-- 	-- Called from Addon_Loaded
-- 	INEED.OptionsPanel_Refresh()
-- end
function STEPS.OptionsPanel_OKAY()
	-- Data was recorded, clear the temp
	STEPS.oldValues = nil
end
function STEPS.OptionsPanel_Cancel()
	-- reset to temp and update the UI
	if STEPS.oldValues then
		for key,val in pairs(STEPS.oldValues) do
			Steps_options[key] = val
		end
	end
	STEPS.oldValues = nil
end


function STEPS.OptionPanel_KeepOriginalValue( option )
	if STEPS.oldValues then
		STEPS.oldValues[option] = STEPS.oldValues[option] or Steps_options[option]
	else
		STEPS.oldValues={[option] = Steps_options[option]}
	end
end

function STEPS.OptionsPanel_CheckButton_OnLoad( self, option, text )
	--FB.Print("CheckButton_OnLoad( "..option..", "..text.." ) -> "..(FB_options[option] and "checked" or "nil"));
	getglobal(self:GetName().."Text"):SetText(text)
	self:SetChecked(Steps_options[option])
end
-- OnClick for checkbuttons
function STEPS.OptionsPanel_CheckButton_OnClick( self, option )
	STEPS.OptionPanel_KeepOriginalValue( option )
	Steps_options[option] = self:GetChecked()
end


-- Steps_options = {
-- 	["show"] = false,
-- 	["enableChat"] = false,
-- 	["unlocked"] = false,
-- }



STEPS.commandList["options"] = {
	["func"] = function() InterfaceOptionsFrame_OpenToCategory( STEPS_MSG_ADDONNAME ) end,
	["help"] = {"", "Open the options panel"},
}