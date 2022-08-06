--locals
local performance_cap = 1024
local threshold = 512

--gamemode hooks
function GM:GetFallDamage(ply, speed) return self:PlayerTeamRunMethod(ply, "Fall", speed) end

function GM:PlayerDamageFallInjury(ply, status)
	self:PlayerPenalizeJump(ply, "PlayerDamageFall", status and 0.7 or nil)
	self:PlayerPenalizeSpeed(ply, "PlayerDamageFall", status and 0.5 or nil)
end

function GM:ThinkSurvivorFall(ply, cur_time)
	if not ply.GetInjuredTime then return end
	
	local injured_status = (ply:GetInjuredTime() or 0) > cur_time
	
	if ply:GetInjured() == injured_status then return end
	
	ply:SetInjured(injured_status)
	hook.Run("PlayerDamageFallInjury", ply, injured_status)
end

--post
GM:PlayerTeamRegisterMethod(TEAM_ANGEL, "Fall", function(ply, speed)
	if speed < threshold then return end
	
	local speed = math.Clamp(speed - 512, 0, performance_cap)
	
	ply:EmitSound(
		"physics/concrete/concrete_block_impact_hard" .. math.random(3) .. ".wav",
		math.Remap(speed, 0, performance_cap, 60, 80), --level
		120 - math.Remap(speed, 0, performance_cap, 0, 40), --pitch
		math.Remap(speed, 0, performance_cap, 0.3, 1) --volume
	)
end)

GM:PlayerTeamRegisterMethod(TEAM_SURVIVOR, "Fall", function(ply, speed)
	if speed < threshold then return end
	
	local injured_time = CurTime() + math.min((speed - threshold) / 32, 12)
	
	if ply:GetInjuredTime() > injured_time then return end
	
	ply:SetInjuredTime(injured_time)
end)