--locals
local epsilon = GM.Epsilon or 1.175494e-38 --not getting cached?
local jump_penalties_record = WEEPING_ANGELS.PlayerJumpPenaltiesRecord or {}
local jump_penalties_registry = WEEPING_ANGELS.PlayerJumpPenaltiesRegistry or {}
local jump_powers = WEEPING_ANGELS.PlayerPenalizeJumps or {}
local player_meta = FindMetaTable("Player")
local speed_penalties_record = WEEPING_ANGELS.PlayerPenalizePenaltiesRecord or {}
local speed_penalties_registry = WEEPING_ANGELS.PlayerPenalizePenaltiesRegistry or {}
local speed_climbs = WEEPING_ANGELS.PlayerPenalizeClimbs or {}
local speed_runs = WEEPING_ANGELS.PlayerPenalizeRuns or {}
local speed_slow_walks = WEEPING_ANGELS.PlayerPenalizeSlowWalks or {}
local speed_walks = WEEPING_ANGELS.PlayerPenalizeWalks or {}

--globals
player_meta.SetJumpPowerX_WeepingAngels = player_meta.SetJumpPowerX_WeepingAngels or player_meta.SetJumpPower
player_meta.SetLadderClimbSpeedX_WeepingAngels = player_meta.SetLadderClimbSpeedX_WeepingAngels or player_meta.SetLadderClimbSpeed
player_meta.SetRunSpeedX_WeepingAngels = player_meta.SetRunSpeedX_WeepingAngels or player_meta.SetRunSpeed
player_meta.SetSlowWalkSpeedX_WeepingAngels = player_meta.SetSlowWalkSpeedX_WeepingAngels or player_meta.SetSlowWalkSpeed
player_meta.SetWalkSpeedX_WeepingAngels = player_meta.SetWalkSpeedX_WeepingAngels or player_meta.SetWalkSpeed
WEEPING_ANGELS.PlayerJumpPenaltiesRecord = jump_penalties_record
WEEPING_ANGELS.PlayerJumpPenaltiesRegistry = jump_penalties_registry
WEEPING_ANGELS.PlayerPenalizePenaltiesRecord = speed_penalties_record
WEEPING_ANGELS.PlayerPenalizePenaltiesRegistry = speed_penalties_registry
WEEPING_ANGELS.PlayerPenalizeClimbs = speed_climbs
WEEPING_ANGELS.PlayerPenalizeJumps = jump_powers
WEEPING_ANGELS.PlayerPenalizeRuns = speed_runs
WEEPING_ANGELS.PlayerPenalizeSlowWalks = speed_slow_walks
WEEPING_ANGELS.PlayerPenalizeWalks = speed_walks

--gamemode functions
function GM:PlayerPenalizeJump(ply, key, multiplier)
	local last_record = jump_penalties_record[ply] or 1
	local record = 1
	local registry = jump_penalties_registry[ply]
	
	--create the entry in the registry
	if registry then registry[key] = multiplier
	else registry = {[key] = multiplier} end
	
	--find the lowest record
	for key, penalty in pairs(registry) do record = math.min(record, penalty) end
	
	if last_record == record then return end
	
	jump_penalties_record[ply] = record
	
	--ply:SetJumpPower()
end

function GM:PlayerPenalizeSpeed(ply, key, multiplier)
	local last_record = speed_penalties_record[ply] or 1
	local record = 1
	local registry = speed_penalties_registry[ply]
	
	--create the entry in the registry
	if registry then registry[key] = multiplier and multiplier ~= 1 and math.max(multiplier, epsilon) or nil
	else registry = {[key] = multiplier and multiplier ~= 1 and math.max(multiplier, epsilon) or nil} end
	
	--find the lowest record
	for key, penalty in pairs(registry) do record = math.min(record, penalty) end
	
	if last_record == record then return end
	
	speed_penalties_record[ply] = record
	
	--update the player's speeds
	--ply:SetLadderClimbSpeed()
	--ply:SetRunSpeed()
	--ply:SetWalkSpeed()
end

--player meta functions
--[[
function player_meta:SetJumpPower(power)
	local penalty = jump_penalties_record[self] or 1
	local power = power or jump_powers[self] or self:GetJumpPower()
	jump_powers[self] = power
	
	self:SetJumpPowerX_WeepingAngels(penalty * power)
end

function player_meta:SetLadderClimbSpeed(speed)
	local penalty = speed_penalties_record[self] or 1
	local speed = speed or speed_climbs[self] or self:GetLadderClimbSpeed()
	speed_climbs[self] = speed
	
	self:SetLadderClimbSpeedX_WeepingAngels(penalty * speed)
end

function player_meta:SetRunSpeed(speed)
	local penalty = speed_penalties_record[self] or 1
	local speed = speed or speed_runs[self] or self:GetRunSpeed()
	speed_runs[self] = speed
	speed = penalty * speed
	
	if self:Team() == TEAM_SURVIVOR then
		self:SetWalkSpeedX_WeepingAngels(speed)
		self:SetRunSpeedX_WeepingAngels(speed)
		
		return
	end
	
	self:SetSlowWalkSpeedX_WeepingAngels(speed)
end

function player_meta:SetSlowWalkSpeed(speed)
	local penalty = speed_penalties_record[self] or 1
	local speed = speed or speed_slow_walks[self] or self:GetSlowWalkSpeed()
	speed_slow_walks[self] = speed
	
	self:SetLadderClimbSpeedX_WeepingAngels(penalty * speed)
end

function player_meta:SetWalkSpeed(speed)
	local penalty = speed_penalties_record[self] or 1
	local speed = speed or speed_walks[self] or self:GetWalkSpeed()
	speed_walks[self] = speed
	speed = penalty * speed
	
	if self:Team() == TEAM_SURVIVOR then
		self:SetWalkSpeedX_WeepingAngels(speed)
		self:SetRunSpeedX_WeepingAngels(speed)
		
		return
	end
	
	self:SetWalkSpeedX_WeepingAngels(speed)
end
]]
--hooks
hook.Add("PlayerDisconnected", "WeepingAngelsPlayerPenalize", function(ply)
	jump_penalties_record[ply] = nil
	jump_penalties_registry[ply] = nil
	jump_powers[ply] = nil
	speed_climbs[ply] = nil
	speed_penalties_record[ply] = nil
	speed_penalties_registry[ply] = nil
	speed_runs[ply] = nil
	speed_slow_walks[ply] = nil
	speed_walks[ply] = nil
end)