--locals
local empty_function = function() end
local next_regen_time = 0
local regen_delay = 3
local regen_interval = 0.1

--gamemode hooks
function GM:OnDamagedByExplosion() end --prevents tinnitus
function GM:PlayerShouldTakeDamage(ply, attacker) return self:PlayerTeamRunMethod(ply, "ShouldTakeDamage", attacker) end

function GM:ThinkDamage(cur_time)
	if cur_time > next_regen_time then
		self.ThinkSurvivorDamage = self.ThinkSurvivorDamageHeal
		
		next_regen_time = cur_time + regen_interval
	else self.ThinkSurvivorDamage = empty_function end
end

function GM:ThinkSurvivorDamageHeal(ply, cur_time)
	local max_health = ply:GetMaxHealth()
	local health = ply:Health()
	
	if max_health == 100 and ply:IsBot() then max_health = 99 end
	if health < max_health and cur_time - (ply:GetLastDamaged() or 0) > regen_delay then ply:SetHealth(health + 1) end
end

--post
GM:PlayerTeamRegisterMethod(TEAM_ANGEL, "ShouldTakeDamage", function(ply, attacker)
	if not attacker:IsPlayer() then return false end
	
	local attacker_team = attacker:Team()
	local attacker_weapon = attacker:GetWeapon("wa_angel_exterminator")
	
	if attacker_team == TEAM_ANGEL then return false end
	if attacker_weapon:IsValid() and attacker_weapon:GetAngel() == ply then return true end
	if ply:GetFrozen() then return false end
	
	return true
end)

GM:PlayerTeamRegisterMethod(TEAM_SURVIVOR, "ShouldTakeDamage", function(ply)
	ply:SetLastDamaged(CurTime())
	
	return true
end)