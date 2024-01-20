# Features

## Options

[ ] Show the UI
[ ] Lock the UI from moving
[ ] Reset the UI Location
[ ] Chat - enable {STEPS} integration
[ ] Post - default channel?


## post

Add an option to post to channels without the chat integration.

## targetDropdown

https://wowpedia.fandom.com/wiki/Using_UIDropDownMenu


## Communication


At least send version info




C_ChatInfo.SendAddonMessage()
prefix, text, channel, target = ...

https://wowpedia.fandom.com/wiki/API_C_ChatInfo.SendAddonMessage

function AddonMessageRate.CHAT_MSG_ADDON( ... )
	self, prefix, message, distType, sender = ...

if not C_ChatInfo.IsAddonMessagePrefixRegistered(commPrefix) then
			C_ChatInfo.RegisterAddonMessagePrefix(commPrefix)
		end


