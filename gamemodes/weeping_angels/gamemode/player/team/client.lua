--locals
local duplex_insert = WEEPING_ANGELS._DuplexInsert
local duplex_remove = WEEPING_ANGELS._DuplexRemove
local local_player = LocalPlayer()
local team_retro = WEEPING_ANGELS.PlayerTeamRetro
local team_rosters = WEEPING_ANGELS.PlayerTeamRosters

--globals
WEEPING_ANGELS.PlayerTeamRetro = team_retro

--gamemode functions
function GM:ThinkTeams()
	for index, ply in ipairs(player.GetAll()) do
		local player_team = ply:Team()
		local retro_team = team_retro[ply]
		
		if retro_team ~= player_team then
			--update the recorded team
			team_retro[ply] = player_team
			
			--now its networked!
			--won't be exactly like the server, and will probably get called less than it should but that's fine
			hook.Run("PlayerChangedTeam", ply, retro_team, player_team)
		end
	end
end

--gamemode hooks
function GM:LocalPlayerChangedTeam(_old_team, _new_team) end

function GM:PlayerChangedTeam(ply, old_team, new_team)
	duplex_insert(team_rosters[new_team], ply)
	
	if old_team then duplex_remove(team_rosters[old_team], ply) end
	if local_player == ply then hook.Run("LocalPlayerChangedTeam", old_team, new_team) end
end

--hooks
hook.Add("InitPostEntity", "WeepingAngelsPlayerTeam", function() local_player = LocalPlayer() end)

hook.Add("PlayerDisconnected", "WeepingAngelsPlayerTeam", function(ply)
	duplex_remove(team_rosters[team_retro[ply]], ply)
	team_retro[ply] = nil
end)