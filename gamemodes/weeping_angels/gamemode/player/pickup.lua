--gamemode hooks
function GM:PlayerCanPickupItem(ply, item)
	if ply:Team() ~= TEAM_SURVIVOR then return false end
	
	print(ply, item)
	
	return true
end

function GM:PlayerCanPickupWeapon(ply, weapon) return self:PlayerTeamRunMethod(ply, "CanPickupWeapon", weapon) end

--wa_angel_weapon
--post
GM:PlayerTeamRegisterMethod(TEAM_ANGEL, "CanPickupWeapon", function(_ply, weapon) return weapon:GetClass() == "wa_angel_weapon" end)

GM:PlayerTeamRegisterMethod(TEAM_SURVIVOR, "CanPickupWeapon", function(_ply, weapon)
	if weapon:GetClass() ~= "wa_angel_weapon" then return true end
	
	return false
end)