--gamemode hooks
function GM:PlayerSwitchFlashlight(ply, enabled)
	local player_team = ply:Team()
	
	if player_team == TEAM_SURVIVOR then
		--TODO: smell event!
		return true
	elseif player_team == TEAM_ANGEL then ply:ToggleFullbright() end
	
	return not enabled
end