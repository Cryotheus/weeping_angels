--gamemode hooks
function GM:PlayerCanPickupItem(ply, _item)
	if ply:Team() ~= TEAM_SURVIVOR then return false end
	
	return true
end

function GM:PlayerCanPickupWeapon(ply, weapon) return self:PlayerTeamRunMethod(ply, "CanPickupWeapon", weapon) end

--wa_angel_weapon
--post
GM:PlayerTeamRegisterMethod(TEAM_ANGEL, "CanPickupWeapon", function(_ply, weapon) return weapon:GetClass() == "wa_angel_weapon" end)
GM:PlayerTeamRegisterMethod(TEAM_BUILDER, "CanPickupWeapon", function() return true end)
GM:PlayerTeamRegisterMethod(TEAM_SURVIVOR, "CanPickupWeapon", function(_ply, weapon) return weapon:GetClass() ~= "wa_angel_weapon" end)