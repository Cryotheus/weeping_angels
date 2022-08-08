--gamemode hooks
function GM:PlayerNoClip(ply, state)
	return self:PlayerTeamRunMethod(ply, "NoClip", state)
end

--post
GM:PlayerTeamRegisterMethod(TEAM_ANGEL, "NoClip", function(_ply, state) return not state end)
GM:PlayerTeamRegisterMethod(TEAM_BUILDER, "NoClip", function() return true end)
GM:PlayerTeamRegisterMethod(TEAM_SPECTATOR, "NoClip", function(_ply, state) return state end)
GM:PlayerTeamRegisterMethod(TEAM_SURVIVOR, "NoClip", function(_ply, state) return not state end)
GM:PlayerTeamRegisterMethod(TEAM_UNASSIGNED, "NoClip", function(_ply, state) return state end)