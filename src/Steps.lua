-- Steps @VERSION@
Steps_SLUG, Steps   = ...
Steps_MSG_ADDONNAME = C_AddOns.GetAddOnMetadata( Steps_SLUG, "Title" )
Steps_MSG_VERSION   = C_AddOns.GetAddOnMetadata( Steps_SLUG, "Version" )
Steps_MSG_AUTHOR    = C_AddOns.GetAddOnMetadata( Steps_SLUG, "Author" )

-- Colours
COLOR_RED = "|cffff0000"
COLOR_GREEN = "|cff00ff00"
COLOR_BLUE = "|cff0000ff"
COLOR_PURPLE = "|cff700090"
COLOR_YELLOW = "|cffffff00"
COLOR_ORANGE = "|cffff6d00"
COLOR_GREY = "|cff808080"
COLOR_GOLD = "|cffcfb52b"
COLOR_NEON_BLUE = "|cff4d4dff"
COLOR_END = "|r"

Steps_data = {}
Steps_options = {}
Steps.steps_per_second = 2/7  -- 2 steps at speed 7
Steps.pruneDays = 91
Steps.min = 0
Steps.ave = 0
Steps.max = 0
Steps.commPrefix = "STEPS"
Steps.stepsColor = { 0.73, 0.52, 0.18, 1 }
