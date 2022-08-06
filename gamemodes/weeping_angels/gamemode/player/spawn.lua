--locals
local team_keys = {
	a = TEAM_ANGEL,
	angel = TEAM_ANGEL,
	human = TEAM_SURVIVOR,
	none = TEAM_UNASSIGNED,
	s = TEAM_SURVIVOR,
	spec = TEAM_SPECTATOR,
	spectator = TEAM_SPECTATOR,
	survivor = TEAM_SURVIVOR,
	u = TEAM_UNASSIGNED,
	unassigned = TEAM_UNASSIGNED,
	w = TEAM_ANGEL,
	weeping_angel = TEAM_ANGEL,
	weepingangel = TEAM_ANGEL
}

--gamemode functions
function GM:PlayerInitialSpawn(ply)
	--more?
	ply:SetTeam(TEAM_UNASSIGNED)
end

function GM:PlayerSetModel(ply) player_manager.RunClass(ply, "SetModel") end

function GM:PlayerSpawn(ply)
	local player_team = ply:Team()
	
	if player_team == TEAM_UNASSIGNED or player_team == TEAM_SPECTATOR then self:PlayerSpawnAsSpectator(ply)
	else
		ply:UnSpectate()
		ply:SetupHands()
		
		player_manager.OnPlayerSpawn(ply)
		player_manager.RunClass(ply, "Spawn")
		
		hook.Run("PlayerLoadout", ply)
		hook.Run("PlayerSetModel", ply)
	end
end

function GM:PlayerSpawnAsSpectator(ply)
	local player_team = ply:Team()
	
	ply:RemoveAllItems()
	ply:Spectate(OBS_MODE_ROAMING)
	
	if player_team == TEAM_UNASSIGNED or player_team == TEAM_SPECTATOR then return end
	
	ply:SetTeam(TEAM_SPECTATOR)
end

function GM:PlayerDeathThink(ply)
	if ply:Team() == TEAM_UNASSIGNED then
		player_manager.SetPlayerClass(ply, "player_survivor")
		ply:SetTeam(TEAM_SURVIVOR)
	end
	
	if ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then ply:Spawn() end
end

--hooks
hook.Add("Initialize", "WeepingAngels", function()
	team_keys = {
		a = TEAM_ANGEL,
		angel = TEAM_ANGEL,
		human = TEAM_SURVIVOR,
		none = TEAM_UNASSIGNED,
		s = TEAM_SURVIVOR,
		spec = TEAM_SPECTATOR,
		spectator = TEAM_SPECTATOR,
		survivor = TEAM_SURVIVOR,
		u = TEAM_UNASSIGNED,
		unassigned = TEAM_UNASSIGNED,
		w = TEAM_ANGEL,
		weeping_angel = TEAM_ANGEL,
		weepingangel = TEAM_ANGEL
	}
end)

--local functions
local function parse_team(text) return text and team_keys[string.lower(text)] or false end

local function set_team_via_parse(ply, target, text)
	local team_id = parse_team(text) or TEAM_SURVIVOR
		
	if team_id then
		ply:PrintMessage(HUD_PRINTCONSOLE, "Set the team of player " .. target:Nick() .. " to " .. team_id)
		target:SetTeam(team_id)
	else ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid team id! Use angel, spectator, survivor, or unassigned.") end
end

--commands
concommand.Add("wa_bot", function(ply, _command, arguments)
	local record = {}
	
	for index, ply in ipairs(player.GetAll()) do record[ply:EntIndex()] = true end
	
	local bot = player.CreateNextBot("Nextbot " .. (#record + 1))
	
	set_team_via_parse(ply, bot, arguments[1])
	
	bot:SetName("Vegetable " .. bot:EntIndex())
	bot:Spawn()
	bot:SetPos(ply:GetPos())
end)

concommand.Add("wa_spawn", function(ply, _command, arguments)
	local first_argument = arguments[1]
	
	if first_argument then set_team_via_parse(ply, ply, first_argument) end
	
	ply:Spawn()
end, nil, "")