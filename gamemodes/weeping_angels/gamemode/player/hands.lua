--gamemode hooks
function GM:PlayerSetHandsModel(ply, entity)
	self.BaseClass:PlayerSetHandsModel(ply, entity)
	
	entity:SetMaterial(ply:Team() == TEAM_ANGEL and "models/props_canal/rock_riverbed01a" or "")
end