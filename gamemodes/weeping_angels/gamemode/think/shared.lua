--locals
local team_rosters = WEEPING_ANGELS.PlayerTeamRosters

--gamemode hooks
function GM:ThinkShared(cur_time)
	local angels = team_rosters[TEAM_ANGEL]
	local removals
	local survivors = team_rosters[TEAM_SURVIVOR]
	
	--call think methods for both teams of players
	for angel_index, ply in ipairs(angels) do
		if ply:IsValid() then self:ThinkAngel(ply, cur_time, survivors, angels)
		elseif removals then table.insert(removals, ply)
		else removals = {ply} end
	end
	
	for survivor_index, ply in ipairs(survivors) do
		if ply:IsValid() then self:ThinkSurvivor(ply, cur_time, survivors, angels)
		elseif removals then table.insert(removals, ply)
		else removals = {ply} end
	end
	
	if removals then --in the very rare case we have invalid players, remove them from the roster
		local removal_function = hook.GetTable().PlayerDisconnected.WeepingAngelsPlayerTeam
		
		for index, invalid in ipairs(removals) do removal_function(invalid) end
	end
end