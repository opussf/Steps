-- StepsOptions @VERSION@
function Steps.OptionsPanel_OnLoad( panel )
	panel.name = "Steps"
	StepsOptionsFrame_Title:SetText(STEPS_MSG_ADDONNAME.." v"..STEPS_MSG_VERSION)

	-- These NEED to be set
	panel.OnDefault = function() end
	panel.OnRefresh = function() end
	panel.OnCommit = Steps.OptionsPanel_OKAY
	panel.cancel = Steps.OptionsPanel_Cancel

	local category, layout = Settings.RegisterCanvasLayoutCategory( panel, panel.name )
	panel.category = category
	Settings.RegisterAddOnCategory(category)
end
function Steps.OptionsPanel_OKAY()
	-- Data was recorded, clear the temp
	Steps.oldValues = nil
end
function Steps.OptionsPanel_Cancel()
	-- reset to temp and update the UI
	if Steps.oldValues then
		for key,val in pairs(Steps.oldValues) do
			Steps_options[key] = val
		end
	end
	Steps.oldValues = nil
end
function Steps.OptionPanel_KeepOriginalValue( option )
	if Steps.oldValues then
		Steps.oldValues[option] = Steps.oldValues[option] or Steps_options[option]
	else
		Steps.oldValues={[option] = Steps_options[option]}
	end
end
function Steps.OptionsPanel_CheckButton_OnLoad( self, option, text )
	--FB.Print("CheckButton_OnLoad( "..option..", "..text.." ) -> "..(FB_options[option] and "checked" or "nil"));
	getglobal(self:GetName().."Text"):SetText(text)
	self:SetChecked(Steps_options[option])
end
-- OnClick for checkbuttons
function Steps.OptionsPanel_CheckButton_OnClick( self, option )
	Steps.OptionPanel_KeepOriginalValue( option )
	Steps_options[option] = self:GetChecked()
end

Steps.commandList["options"] = {
	["func"] = function() Settings.OpenToCategory( StepsOptionsFrame.category:GetID() ) end,
	["help"] = {"", "Open the options panel"},
}
