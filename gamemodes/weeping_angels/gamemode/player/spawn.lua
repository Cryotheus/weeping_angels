--locals
local huge = math.huge
local not_huge = -math.huge
local player_bounds_buffer = Vector(2, 2, 1)
local player_bounds_buffer_z = player_bounds_buffer.z
local player_bounds_buffer_z_quarter = player_bounds_buffer_z * 0.25
local player_hull = Vector(32, 32, 72) + player_bounds_buffer
local player_hull_height = Vector(0, 0, player_hull.z)
local player_hull_planar = Vector(player_hull.x, player_hull.y, 0)
local player_hull_planar_half = player_hull_planar * 0.5
local setup_spawns_trace = {}

--lcoal tables
local team_keys = {
	a = TEAM_ANGEL,
	angel = TEAM_ANGEL,
	b = TEAM_BUILDER,
	build = TEAM_BUILDER,
	builder = TEAM_BUILDER,
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

local setup_spawns_trace_settings = {
	mask = MASK_PLAYERSOLID,
	output = setup_spawns_trace
}

--local function
local function get_area_bounds(area)
	local maximum_x, minimum_x = not_huge, huge
	local maximum_y, minimum_y = not_huge, huge
	local maximum_z, minimum_z = not_huge, huge
	
	for corner_id = 0, 3 do
		local corner_position = area:GetCorner(corner_id)
		local x, y, z = corner_position:Unpack()
		
		maximum_x, minimum_x = math.max(maximum_x, x), math.min(minimum_x, x)
		maximum_y, minimum_y = math.max(maximum_y, y), math.min(minimum_y, y)
		maximum_z, minimum_z = math.max(maximum_z, z), math.min(minimum_z, z)
	end
	
	return Vector(minimum_x, minimum_y, minimum_z), Vector(maximum_x, maximum_y, maximum_z)
end

local function test_area(area)
	local minimums, maximums = get_area_bounds(area)
	
	--too much slope
	if maximums.z - minimums.z > 4 then return end
	
	--too small of an area
	if maximums - minimums < player_hull then return end
	
	local maximum_z = maximums.z
	local calculated_center = (maximums + minimums) * 0.5
	calculated_center.z = maximum_z + 1
	setup_spawns_trace_settings.endpos = calculated_center + player_hull_height
	setup_spawns_trace_settings.maxs = Vector(maximums.x, maximums.y, 0)
	setup_spawns_trace_settings.mins = Vector(minimums.x, minimums.y, 0)
	setup_spawns_trace_settings.startpos = calculated_center
	
	util.TraceHull(setup_spawns_trace_settings)
	
	--obstructed
	if setup_spawns_trace.Hit then return end
	
	return true
end

--gamemode function
function GM:PlayerSpawnChoosePosition()
	local area = self.PlayerSpawnAreas[math.random(self.PlayerSpawnAreaCount)]
	local areas_connected = area:GetAdjacentAreas()
	local minimums, maximums = get_area_bounds(area)
	local record_connected_area
	local record_connected_area_size = 0
	local safe_minimums, safe_maximums = minimums + player_hull_planar_half, maximums - player_hull_planar_half
	local safe_spawn = VectorRand(safe_minimums, safe_maximums)
	
	--find the largest connected area
	for index, connected_area in ipairs(areas_connected) do
		local size = (connected_area:GetSizeX() ^ 2 + connected_area:GetSizeY() ^ 2) ^ 0.5
		
		if size > record_connected_area_size then
			record_connected_area = connected_area
			record_connected_area_size = size
		end
	end
	
	--build a nicer angle to look at
	local nice_angles = record_connected_area and (record_connected_area:GetClosestPointOnArea(safe_spawn) - safe_spawn):Angle() or Angle(0, math.random() * 360 - 180, 0)
	nice_angles.p = 0
	
	--move the player up so they don't get stuck in the ground
	safe_spawn.z = maximums.z + player_bounds_buffer_z_quarter
	
	return safe_spawn, nice_angles
end

function GM:PlayerSpawnSetupSpawns()
	local spawn_areas = self.PlayerSpawnAreas or {}
	
	table.Empty(spawn_areas)
	
	for index, area in pairs(navmesh.GetAllNavAreas()) do if test_area(area) then table.insert(spawn_areas, area) end end
	
	self.PlayerSpawnAreaCount = #spawn_areas
	self.PlayerSpawnAreas = spawn_areas
end

--gamemode hooks
function GM:IsSpawnpointSuitable() return false end

function GM:PlayerDeathThink(ply)
	if ply:Team() == TEAM_UNASSIGNED then
		player_manager.SetPlayerClass(ply, "player_survivor")
		ply:SetTeam(TEAM_SURVIVOR)
	end
	
	if ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then ply:Spawn() end
end

function GM:PlayerInitialSpawn(ply)
	--more?
	ply:SetTeam(TEAM_UNASSIGNED)
end

function GM:PlayerSelectSpawn(ply)
	if navmesh.IsGenerating() then
		self:MessageConsole("Rejecting player spawn as the navmesh is generating.")
		
		return
	end
	
	if not navmesh.IsLoaded() then
		--spit out an error and give up
		self:MessageConsoleError("Map " .. game.GetMap() .. " does not have a loaded navmesh! A navmesh is ", self.ColorErrorDark, "REQUIRED",  self.ColorError, " to player this gamemode.")
		self:MessageConsole("Attempting to load a navemesh...")
		
		navmesh.Load()
		
		if not navmesh.IsLoaded() then
			self:MessageConsoleError("Failed second attempt to load a navmesh!")
			self:MessageConsoleError("Generating a navmesh...")
			
			--navmesh.BeginGeneration()
			
			self:MessageConsoleError("Navmesh BeginGeneration call has completed, sit tight!")
			
			return
		end
	end
	
	if not self.PlayerSpawnAreas or table.IsEmpty(self.PlayerSpawnAreas) then self:PlayerSpawnSetupSpawns() end
	
	ply.OverrideSpawnPosition, ply.OverrideSpawnAngles = self:PlayerSpawnChoosePosition()
end

function GM:PlayerSetModel(ply) player_manager.RunClass(ply, "SetModel") end

function GM:PlayerSpawn(ply)
	local player_team = ply:Team()
	local spawn_angles = ply.OverrideSpawnAngles
	local spawn_position = ply.OverrideSpawnPosition
	
	if player_team == TEAM_UNASSIGNED or player_team == TEAM_SPECTATOR then self:PlayerSpawnAsSpectator(ply)
	else
		ply:UnSpectate()
		ply:SetupHands()
		
		player_manager.OnPlayerSpawn(ply)
		player_manager.RunClass(ply, "Spawn")
		
		hook.Run("PlayerLoadout", ply)
		hook.Run("PlayerSetModel", ply)
	end
	
	if spawn_angles then
		ply.OverrideSpawnAngles = nil
		
		ply:SetEyeAngles(spawn_angles)
	end
	
	if spawn_position then
		ply.OverrideSpawnPosition = nil
		
		ply:SetPos(spawn_position)
	end
end

function GM:PlayerSpawnAsSpectator(ply)
	local player_team = ply:Team()
	
	ply:RemoveAllItems()
	ply:Spectate(OBS_MODE_ROAMING)
	
	if player_team == TEAM_UNASSIGNED or player_team == TEAM_SPECTATOR then return end
	
	ply:SetTeam(TEAM_SPECTATOR)
end

--hooks
hook.Remove("Initialize", "WeepingAngels")

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