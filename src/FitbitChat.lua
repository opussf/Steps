-- RFChat.lua

function FITBIT.InitChat()
	FITBIT.OriginalSendChatMessage = SendChatMessage
	SendChatMessage = FITBIT.SendChatMessage
	FITBIT.OriginalBNSendWhisper = BNSendWhisper
	BNSendWhisper = FITBIT.BNSendWhisper
end
function FITBIT.ReplaceMessage( msgIn )
	-- search for and replace {FB}
	--print( "msgIn: "..msgIn )
	msgNew = nil
	local tokenStart, tokenEnd, fortuneIdx, useLotto = strfind( msgIn, "{[fF][bB]}" )
	if tokenStart then
		--print( "tokenStart: "..tokenStart )
		--print( "tokenEnd: "..tokenEnd )
		--print( "index: "..index )
		local dateStr = date("%Y%m%d")
		local stepsStr = "My steps today: "..math.floor( FITBIT.mine[dateStr].steps or "0" )
		msgNew = string.sub( msgIn, 1, tokenStart-1 )..
				stepsStr..
				string.sub( msgIn, tokenEnd+1 )
	end
	return( ( msgNew or msgIn ) )
end
function FITBIT.SendChatMessage( msgIn, system, language, channel )
	FITBIT.OriginalSendChatMessage( FITBIT.ReplaceMessage( msgIn ), system, language, channel )
end
function FITBIT.BNSendWhisper( id, msgIn )
	FITBIT.OriginalBNSendWhisper( id, FITBIT.ReplaceMessage( msgIn ) )
end

-- RF.CommandList[""] = {
-- 		["help"] = {"{RF<nnn><L>}","Send to any chat. <nnn> fortune to post. <L> append lotto numbers"},
-- 	}
