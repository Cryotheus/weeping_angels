SWEP.Author = "Cryotheum"
SWEP.CanDamageFrozenWeepingAngel = true
SWEP.DrawAmmo = false
SWEP.PrintName = "Angel Exterminator X2000"
SWEP.Purpose = "Focus primary fire on an angel to obliterate them."
SWEP.RenderGroup = RENDERGROUP_BOTH
SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_superphyscannon.mdl")
SWEP.ViewModelFOV = 54
SWEP.WorldModel = Model("models/weapons/w_physics.mdl")

SWEP.Primary = {
	Ammo = "none",
	Automatic = true,
	ClipSize = -1,
	DefaultClip = -1
}

SWEP.Secondary = {
	Ammo = "none",
	Automatic = false,
	ClipSize = -1,
	DefaultClip = -1
}

--locals
local charge_time = 2
local minimum_dotting = -1
local range = 128
local release_range = 156
local trace_output = {}
local trace_settings = {mask = MASK_SHOT_HULL, output = trace_output}
local weapon_color = Vector(5, 0.6, 0.3)

--swep functions
function SWEP:DamageAngel(angel, attacker)
	local damage = DamageInfo()
	
	damage:SetAttacker(attacker)
	damage:SetDamage(400)
	damage:SetDamageForce(vector_origin)
	damage:SetDamageType(DMG_PLASMA)
	damage:SetInflictor(self)
	damage:SetDamagePosition(angel:GetPos())
	damage:SetReportedPosition(angel:GetPos())
	
	--angel:TakeDamageInfo(damage)
end

function SWEP:Deploy()
	local owner = self:GetOwner()
	local speed = 1
	local view_model = owner:GetViewModel()
	
	local next_fire = CurTime() + view_model:SequenceDuration() / speed
	
	owner:SetWeaponColor(weapon_color)
	self:PlayAnimation("draw", view_model, speed)
	self:SetNextPrimaryFire(next_fire)
	self:SetNextSecondaryFire(math.huge)
	self:SetSkin(1)
	self:UpdateNextIdle()
	
	return true
end

function SWEP:Holster()
	self:SetAttackStart(0)
	
	return true
end

function SWEP:Initialize()
	--more?
	self:SetHoldType("physgun")
end

function SWEP:OnDrop() self:Remove() end

function SWEP:OnRemove()
	local angel = self:GetAngel()
	local owner = self:GetOwner()
	
	if owner:IsValid() then GAMEMODE:PlayerPenalizeSpeed(owner, "AngelExterminator") end
	if angel:IsValid() then GAMEMODE:PlayerAngelFreeze(angel, "Exterminator", false) end
end

function SWEP:PlayAnimation(name, view_model, speed)
	local view_model = view_model or self:GetOwner():GetViewModel()
	
	self:SetAnimationStart(CurTime())
	view_model:SendViewModelMatchingSequence(view_model:LookupSequence(name))
	
	if speed then view_model:SetPlaybackRate(speed) end
end

function SWEP:PrimaryAttack()
	local owner = self:GetOwner()
	local shooting_position = owner:GetShootPos()
	local shooting_target = shooting_position + owner:GetAimVector() * range
	local angel = self:GetAngel()
	
	owner:LagCompensation(true)
	
	if angel:IsValid() then
		local distance = angel:GetPos():Distance(owner:GetPos())
		local dotting = (angel:GetShootPos() - shooting_position):GetNormalized():Dot(owner:GetAimVector())
		
		if distance > release_range or dotting < minimum_dotting then
			self:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav", 90, 90, 1, CHAN_WEAPON)
		else
			local cur_time = CurTime()
			local start_attack = self:GetAttackStart()
			local shoot_time = cur_time - start_attack
			self.PrimaryAttacking = true
			
			if shoot_time > charge_time then
				if self:GetCharged() then
					if SERVER and cur_time > self.NextDamageTime then
						self:DamageAngel(angel, owner)
						
						self.NextDamageTime = cur_time + 0.5
					end
				else
					self.NextDamageTime = cur_time
					
					self:EmitSound("beams/beamstart5.wav", 100, 110, 1, CHAN_WEAPON)
					self:SetCharged(true)
					self:SetNextIdle(cur_time)
					self:SetProngs(1)
				end
			else self:SetProngs((shoot_time / charge_time) ^ 3) end
		end
	else
		trace_settings.endpos = shooting_target
		trace_settings.filter = WEEPING_ANGELS.PlayerTeamRosters[TEAM_SURVIVOR]
		trace_settings.start = shooting_position
		
		util.TraceLine(trace_settings)
		
		angel = trace_output.Entity
		
		if angel:IsValid() and angel:IsPlayer() and angel:Team() == TEAM_ANGEL then
			self.PrimaryAttacking = true
			self.WasPrimaryAttacking = true
			
			self:StartCharge(angel, owner)
		end
	end
	
	owner:LagCompensation(false)
end

function SWEP:SetProngs(fraction)
	self:SetPoseParameter("active", fraction)
	self:GetOwner():GetViewModel():SetPoseParameter("active", fraction)
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Attacking")
	self:NetworkVar("Bool", 1, "Charged")
	self:NetworkVar("Entity", 0, "Angel")
	self:NetworkVar("Float", 0, "AttackStart")
	self:NetworkVar("Float", 1, "NextIdle")
	self:NetworkVar("Float", 2, "AnimationStart")
end

function SWEP:StartCharge(angel, owner)
	local cur_time = CurTime()
	
	GAMEMODE:PlayerAngelFreeze(angel, "Exterminator", true)
	GAMEMODE:PlayerPenalizeSpeed(owner, "AngelExterminator", 0.25)
	self:EmitSound("ambient/machines/thumper_startup1.wav", 100, 110, 1, CHAN_WEAPON)
	self:SetAngel(angel)
	self:SetAttacking(true)
	self:SetAttackStart(cur_time)
	self:SetCharged(false)
	self:SetNextIdle(cur_time)
end

function SWEP:Think()
	local cur_time = CurTime()
	
	if self.PrimaryAttacking then self.PrimaryAttacking = false
	elseif self.WasPrimaryAttacking then
		local angel = self:GetAngel()
		
		self.WasPrimaryAttacking = false
		
		if angel:IsValid() then GAMEMODE:PlayerAngelFreeze(angel, "Exterminator", false) end
		
		GAMEMODE:PlayerPenalizeSpeed(self:GetOwner(), "AngelExterminator")
		self:SetAngel(NULL)
		self:SetAttacking(false)
		self:SetCharged(false)
		self:SetNextIdle(cur_time)
		self:SetProngs(0)
	end
	
	self:ThinkIdleAnimations(cur_time)
end

function SWEP:ThinkIdleAnimations(cur_time)
	local idle_time = self:GetNextIdle()
	
	if idle_time > 0 and cur_time > idle_time then
		if self:GetAttacking() then self:PlayAnimation("charge_up", nil, self:GetCharged() and 4 or 1)
		else self:PlayAnimation(math.random(2) == 1 and "idle" or "hold_idle", nil, 0.1) end
		
		self:UpdateNextIdle()
	end
end

function SWEP:UpdateNextIdle()
	local view_model = self:GetOwner():GetViewModel()
	
	self:SetNextIdle(CurTime() + view_model:SequenceDuration() / view_model:GetPlaybackRate())
end