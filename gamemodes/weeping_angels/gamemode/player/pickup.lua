--gamemode hooks
function GM:PlayerCanPickupItem(ply, item)
	if ply:Team() ~= TEAM_SURVIVOR then return false end
	
	print(ply, item)
	
	return true
end

function GM:PlayerCanPickupWeapon(ply, weapon) return self:TeamRunMethod(ply, "CanPickupWeapon", weapon) end

--wa_angel_weapon
--post
GM:TeamRegisterMethod(TEAM_ANGEL, "CanPickupWeapon", function(_ply, weapon) return weapon:GetClass() == "wa_angel_weapon" end)

GM:TeamRegisterMethod(TEAM_SURVIVOR, "CanPickupWeapon", function(_ply, weapon)
	if weapon:GetClass() ~= "wa_angel_weapon" then return true end
	
	return false
end)