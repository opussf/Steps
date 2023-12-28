At least send version info




C_ChatInfo.SendAddonMessage()
prefix, text, channel, target = ...

https://wowpedia.fandom.com/wiki/API_C_ChatInfo.SendAddonMessage

function AddonMessageRate.CHAT_MSG_ADDON( ... )
	self, prefix, message, distType, sender = ...

if not C_ChatInfo.IsAddonMessagePrefixRegistered(commPrefix) then
			C_ChatInfo.RegisterAddonMessagePrefix(commPrefix)
		end


