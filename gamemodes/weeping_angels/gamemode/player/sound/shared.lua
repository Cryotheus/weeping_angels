--gamemode hooks
function GM:PlayerFootstep(ply, _position, _foot, _sound, _volume, _filter)
	if ply:Team() == TEAM_SURVIVOR and ply:GetSilentWalk() then return true end
end