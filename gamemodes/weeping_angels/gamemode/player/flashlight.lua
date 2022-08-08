--gamemode hooks
function GM:PlayerSwitchFlashlight(ply, enabled)
	if self:PlayerTeamIsObserver(ply) then return not enabled end
	
	return self:PlayerTeamRunMethod(ply, "SwitchFlashlight", enabled)
end

--post
GM:PlayerTeamRegisterMethod(TEAM_ANGEL, "SwitchFlashlight", function(_ply, state) return not state end)
GM:PlayerTeamRegisterMethod(TEAM_BUILDER, "SwitchFlashlight", function(_ply, state) print("hi!") return true end)

GM:PlayerTeamRegisterMethod(TEAM_SURVIVOR, "SwitchFlashlight", function(_ply, state)
	--TODO: smell event!
	
	return true
end)