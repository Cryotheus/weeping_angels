--locals
local player_meta = FindMetaTable("Player")
local duplex_insert = WEEPING_ANGELS._DuplexInsert
local duplex_remove = WEEPING_ANGELS._DuplexRemove
local team_retro = WEEPING_ANGELS.PlayerTeamRetro
local team_rosters = WEEPING_ANGELS.PlayerTeamRosters

--globals
player_meta.SetTeamX_WeepingAngels = player_meta.SetTeamX_WeepingAngels or player_meta.SetTeam

--gamemode hooks
function GM:PlayerChangedTeam(ply, old_team, new_team) end

--player meta functions
function player_meta:SetTeam(team_id)
	local team_class = team.GetClass(team_id)
	local old_team = team_retro[self] or self:Team()
	local old_roster = team_rosters[old_team]
	local player_class = team_class and team_class[1] or "player_default"
	
	--update roster
	if team_id ~= old_team then
		team_retro[self] = team_id
		
		if old_roster[self] then duplex_remove(old_roster, self) end
		
		duplex_insert(team_rosters[team_id], self)
	end
	
	if self:IsBot() then
		local bot_class = player_class .. "_bot"
		
		if player_manager.GetPlayerClasses()[bot_class] then player_class = bot_class end
	end
	
	player_manager.SetPlayerClass(self, player_class)
	
	--call the original function
	self:SetTeamX_WeepingAngels(team_id)
end

--hooks
hook.Add("PlayerDisconnected", "WeepingAngelsPlayerTeam", function(ply)
	duplex_remove(team_rosters[team_retro[ply]], ply)
	
	team_retro[ply] = nil
end)