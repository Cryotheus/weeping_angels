SWEP.Author = "Cryotheum"
SWEP.DrawAmmo = false
SWEP.PrintName = "#GMOD_Fists"
SWEP.Purpose = "Reload to holster for picking up props."
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.WorldModel = ""

SWEP.Primary = {
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = true,
	Ammo = "none"
}

SWEP.Secondary = {
	ClipSize = -1,
	DefaultClip = -1,
	Automatic = true,
	Ammo = "none"
}

--locals
local phys_pushscale = GetConVar("phys_pushscale")
local sound_impact = "Flesh.ImpactHard"
local sound_swing = "WeaponFrag.Throw"
local trace_output = {}
local trace_settings = {mask = MASK_SHOT_HULL, output = trace_output}

local punch_sequences = {
	[384] = "fists_right",
	[385] = "fists_left"
}

--swep functions
function SWEP:DealDamage()
	local owner = self:GetOwner()
	local animation = self:GetSequenceName(owner:GetViewModel():GetSequence())
	local shooting_position = owner:GetShootPos()
	local shooting_target = shooting_position + owner:GetAimVector() * self.HitDistance
	
	owner:LagCompensation(true)
	
	trace_settings.endpos = shooting_target
	trace_settings.filter = owner
	trace_settings.start = shooting_position
	
	util.TraceLine(trace_settings)
	
	local hit_sound = sound_impact
	local trace_entity = trace_output.Entity
	
	--try a more lenient trace
	if not IsValid(trace_entity) then
		trace_settings.maxs = self.HitMaximums
		trace_settings.mins = self.HitMinimums
		
		util.TraceHull(trace_settings)
		
		trace_entity = trace_output.Entity
	end
	
	if IsValid(trace_entity) then
		local is_player = trace_entity:IsPlayer()
		local physics = trace_entity:GetPhysicsObject()
		local scale = phys_pushscale:GetFloat() * 10000
		
		if is_player and trace_entity:Team() == TEAM_ANGEL then
			hit_sound = "Concrete.BulletImpact"
			self.AdmireFists = true
			
			GAMEMODE:PlayerSpeak(owner, "PainfulPunch")
		end
		
		if SERVER and (is_player or trace_entity:Health() > 0) then
			local damage = DamageInfo()
			local side_scale = animation == "fists_left" and 0.5 or -0.5
			
			damage:SetAttacker(owner)
			damage:SetDamage(25)
			damage:SetDamageForce((owner:GetRight() * side_scale + owner:GetForward()) * scale)
			damage:SetInflictor(self)
			
			SuppressHostEvents(NULL)
			trace_entity:TakeDamageInfo(damage)
			SuppressHostEvents(owner)
		end
		
		if IsValid(physics) then physics:ApplyForceOffset(owner:GetAimVector() * 200 * physics:GetMass() ^ 0.75, trace_output.HitPos) end
	end
	
	--if we hit anything, play the sound
	if trace_output.Hit then self:EmitSound(hit_sound) end
	
	owner:LagCompensation(false)
end

function SWEP:Deploy()
	local view_model = self:GetOwner():GetViewModel()
	local speed = 2
	local next_fire = CurTime() + view_model:SequenceDuration() / speed
	
	if not self.HasBeenDeployed then
		self.HasBeenDeployed = true
		
		self:SetUsingFists(false)
	end
	
	self:SetNextPrimaryFire(next_fire)
	self:SetNextReload(next_fire)
	self:SetNextSecondaryFire(next_fire)
	
	if self:GetUsingFists() then
		self:PlayAnimation("fists_draw", view_model, speed)
		self:UpdateNextIdle()
	else
		self:PlayAnimation("ref", view_model, speed)
		self:SetNextIdle(0)
	end
	
	return true
end

function SWEP:Holster()
	self:SetNextMeleeAttack(0)
	
	return true
end

function SWEP:Initialize()
	self.SwingSpeed = 0.2
	self.SwingDelay = 0.9
	
	--more?
	self:SetHoldType(self:GetUsingFists() and "fist" or "normal")
	self:SetSwingRange(48)
end

function SWEP:OnDrop() self:Remove() end

function SWEP:PlayAnimation(name, view_model, speed)
	local view_model = view_model or self:GetOwner():GetViewModel()
	
	self:SetAnimationStart(CurTime())
	view_model:SendViewModelMatchingSequence(view_model:LookupSequence(name))
	
	if speed then view_model:SetPlaybackRate(speed) end
	if name ~= "seq_admire" then self.AdmireSpeak = false end
end

function SWEP:PrimaryAttack() if self:GetUsingFists() then return self:ThrowPunch() end end

function SWEP:Reload()
	if not self:GetOwner():KeyPressed(IN_RELOAD) then return end --semi-auto reload 
	
	local cur_time = CurTime()
	
	if cur_time < self:GetNextReload() then return end
	
	self:SetNextReload(cur_time + 0.5)
	
	if self:GetUsingFists() then
		self:PlayAnimation("fists_holster")
		self:SetHoldType("normal")
		self:SetUsingFists(false)
		
		if self.AdmireFists then return self:UpdateNextIdle() end
		
		self:SetNextIdle(0)
		
		return
	end
	
	local held_prop = self.HeldProp
	
	if IsValid(held_prop) then DropEntityIfHeld(held_prop) end
	
	self:PlayAnimation("fists_draw", nil, 2)
	self:SetHoldType("fist")
	self:SetUsingFists(true)
	self:UpdateNextIdle()
end

function SWEP:SecondaryAttack() self:PrimaryAttack() end

function SWEP:SetSwingRange(range, size)
	local size = size or 10
	local size_vector = Vector(size, size, size * 0.8)
	
	self.HitDistance = range
	self.HitMaximums = size_vector
	self.HitMinimums = -size_vector
end

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "UsingFists")
	self:NetworkVar("Float", 0, "NextMeleeAttack")
	self:NetworkVar("Float", 1, "NextIdle")
	self:NetworkVar("Float", 2, "NextReload")
	self:NetworkVar("Float", 3, "AnimationStart")
end

function SWEP:Think()
	local cur_time = CurTime()
	local melee_time = self:GetNextMeleeAttack()
	local idle_time = self:GetNextIdle()
	
	if self.AdmireSpeak and cur_time - self:GetAnimationStart() > 1 then
		self.AdmireSpeak = false
		
		GAMEMODE:PlayerSpeak(self:GetOwner(), "AdmireBloodyFists")
	end
	
	if idle_time > 0 and cur_time > idle_time then
		if self:GetUsingFists() then
			self:PlayAnimation("fists_idle_0" .. math.random(2))
			self:UpdateNextIdle()
		else
			if self.AdmireFists then
				self.AdmireFists = false
				self.AdmireSpeak = true
				
				self:PlayAnimation("seq_admire")
			else self:PlayAnimation("fists_holster") end
			
			self:SetNextIdle(0)
			
			return 
		end
	end
	
	if melee_time > 0 and cur_time > melee_time then
		self:DealDamage()
		self:SetNextMeleeAttack(0)
	end
end

function SWEP:ThrowPunch()
	local cur_time = CurTime()
	local owner = self:GetOwner()
	local swing_delay = self.SwingDelay + cur_time
	
	--can't figure out a way to choose which fist to swing for the owner's animation
	owner:SetAnimation(PLAYER_ATTACK1)
	
	--instead of letting the player choose which fist to punch with
	--lets just sync the viewmodel to the owner's animation
	for layer_id = 0, 7 do
		local sequence_id = owner:GetLayerSequence(layer_id)
		local punch_sequence = punch_sequences[sequence_id]
		
		if punch_sequence then
			self:PlayAnimation(punch_sequence, owner:GetViewModel())
			
			break
		end
	end
	
	self:EmitSound(sound_swing)
	self:UpdateNextIdle()
	self:SetNextMeleeAttack(cur_time + self.SwingSpeed)
	self:SetNextPrimaryFire(swing_delay)
	self:SetNextSecondaryFire(swing_delay)
end

function SWEP:UpdateNextIdle()
	local view_model = self:GetOwner():GetViewModel()
	
	self:SetNextIdle(CurTime() + view_model:SequenceDuration() / view_model:GetPlaybackRate())
end