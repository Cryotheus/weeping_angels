--locals
local player_meta = FindMetaTable("Player")
local duplex_insert = WEEPING_ANGELS._DuplexInsert
local duplex_remove = WEEPING_ANGELS._DuplexRemove
local team_rosters = WEEPING_ANGELS.PlayerTeamRosters

player_meta.SetTeamX_WeepingAngels = player_meta.SetTeamX_WeepingAngels or player_meta.SetTeam

--player meta functions
function player_meta:SetTeam(team_id)
	local team_class = team.GetClass(team_id)
	local old_team = self:Team()
	local old_roster = team_rosters[old_team]
	
	--update roster
	if team_id ~= old_team then
		if old_roster[self] then duplex_remove(old_roster, self) end
		
		duplex_insert(team_rosters[team_id], self)
	end
	
	--if there is a player class, set the player to it or default to player_default
	player_manager.SetPlayerClass(self, team_class and team_class[1] or "player_default")
	
	--call the original function
	self:SetTeamX_WeepingAngels(team_id)
end

--hooks
hook.Add("PlayerDisconnected", "WeepingAngelsPlayerTeam", function(ply) duplex_remove(team_rosters[ply:Team()], ply) end)