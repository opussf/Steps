-- STEPSOptions @VERSION@


function STEPS.OptionsPanel_OnLoad(panel)
	panel.name = "Steps"
	-- INEEDOptionsFrame_Title:SetText(INEED_MSG_ADDONNAME.." "..INEED_MSG_VERSION)
	-- --panel.parent=""
	-- panel.okay = INEED.OptionsPanel_OKAY
	-- panel.cancel = INEED.OptionsPanel_Cancel
	-- --panel.default = FB.OptionsPanel_Default;
	-- panel.refresh = INEED.OptionsPanel_Refresh

	-- InterfaceOptions_AddCategory(panel)
	-- --InterfaceAddOnsList_Update();
	-- --FB.OptionsPanel_TrackPeriodSlider_OnLoad()
end

Steps.commantList["options"] = {
	["func"] = function() InterfaceOptionsFrame_OpenToCategory( STEPS_MSG_ADDONNAME ) end,
	["help"] = {"", "Open the options panel"},
}