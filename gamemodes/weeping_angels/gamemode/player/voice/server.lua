--gamemode hooks
function GM:PlayerCanHearPlayersVoice(listener, talker)
	--if you're talking to youself... I don't know why this is called without voice loopback
	if listener == talker then return true, false end
	
	local listener_team = listener:Team()
	
	--deafen unassigned and 
	if listener_team == TEAM_UNASSIGNED  then return false, false end
	
	local talker_team = talker:Team()
	
	if talker_team == TEAM_UNASSIGNED then return false, false end --mute
	if listener_team == TEAM_SPECTATOR then return true, false end --omniscient
	
	--global between angels, spatial with survivors
	if listener_team == TEAM_ANGEL then return talker_team == TEAM_ANGEL or talker_team == TEAM_SURVIVOR, talker_team == TEAM_SURVIVOR end
	
	--global between survivors, spatial if shifting
	--clutists can hear angels in spatial only
	if listener_team == TEAM_SURVIVOR then
		if talker_team == TEAM_ANGEL and listener:GetIsCultist() then return true, true end
		
		return talker_team == TEAM_SURVIVOR, talker:GetLocalChatting()
	end
	
	ErrorNoHaltWithStack(
		"No voice returns, blocking the poor bstrd's voice chat.",
		listener,
		talker,
		IsValid(listener) and listener:Team() or "invalid listener",
		IsValid(talker) and talker:Team() or "invalid talker"
	)
	
	return false, false
end