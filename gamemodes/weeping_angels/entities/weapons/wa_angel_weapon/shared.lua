SWEP.Author = "Cryotheum"
SWEP.DrawAmmo = false
SWEP.PrintName = "Neck Snappers"
SWEP.Purpose = "Kill survivors with the primary fire, toggle night vision with the reload."
SWEP.Slot = 0
SWEP.SlotPos = 0
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
SWEP.ViewModelFOV = 54
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
	Automatic = false,
	Ammo = "none",
}

--locals
local input_classes = {func_breakable_surf = "Shatter"}
local trace_output = {}
local trace_settings = {mask = MASK_SHOT_HULL, output = trace_output}

--local tables
local hold_types = {
	"duel",
	"fist",
	"knife",
	"magic",
	"melee2"
}

local hold_type_count = #hold_types

--swep functions
function SWEP:Deploy()
	if self.PreviouslyDeployed then return end
	
	local owner = self:GetOwner()
	local view_model = owner:GetViewModel()
	
	self.PreviouslyDeployed = true
	
	self:PlayAnimation("seq_admire", view_model)
	--view_model:SetMaterial("models/props_canal/rock_riverbed01a")
end

function SWEP:Initialize()
	self:SetAttackRange(46)
	self:SetHoldType("normal")
end

function SWEP:PlayAnimation(name, view_model, speed)
	local view_model = view_model or self:GetOwner():GetViewModel()
	
	view_model:SendViewModelMatchingSequence(view_model:LookupSequence(name))
	
	if speed then view_model:SetPlaybackRate(speed) end
end

function SWEP:PrimaryAttack()
	local animate = false
	local owner = self:GetOwner()
	
	if owner:GetFrozen() or true then return end
	
	local range = self.AttackDistance + math.min(owner:GetVelocity():Length2D() ^ 1.2 * 0.01, 90)
	local shooting_position = owner:GetShootPos()
	local shooting_target = shooting_position + owner:GetAimVector() * range
	self.PrimaryAttacking = true
	
	owner:LagCompensation(true)
	
	trace_settings.endpos = shooting_target
	trace_settings.filter =  WEEPING_ANGELS.PlayerTeamRosters[TEAM_ANGEL]
	trace_settings.start = shooting_position
	
	util.TraceLine(trace_settings)
	
	local trace_entity = trace_output.Entity
	
	--try a more lenient trace
	if not IsValid(trace_entity) then
		trace_settings.maxs = self.AttackMaximums
		trace_settings.mins = self.AttackMinimums
		
		util.TraceHull(trace_settings)
		
		trace_entity = trace_output.Entity
	end
	
	if IsValid(trace_entity) then
		if trace_entity:IsPlayer() then
			animate = true
			
			if SERVER then trace_entity:Kill() end
		else
			local fire_input = input_classes[trace_entity:GetClass()]
			
			if fire_input then
				animate = true
				
				if SERVER then trace_entity:Fire(fire_input) end
			elseif trace_entity:Health() > 0 then
				animate = true
				
				if SERVER then
					local damage = DamageInfo()
					
					damage:SetAttacker(owner)
					damage:SetDamage(250)
					damage:SetDamageForce(vector_origin)
					damage:SetInflictor(self)
					
					SuppressHostEvents(NULL)
					trace_entity:TakeDamageInfo(damage)
					SuppressHostEvents(owner)
				end
			end
		end
	end
	
	owner:LagCompensation(false)
	
	if animate then owner:SetAnimation(PLAYER_ATTACK1) end
end

function SWEP:Reload() end

function SWEP:SecondaryAttack()
	--TODO, if owner is out of sight, let them teleport
end

function SWEP:SetAttackRange(range, size)
	local size = size or 14
	local size_vector = Vector(size, size, size * 0.8)
	
	self.AttackDistance = range
	self.AttackMaximums = size_vector
	self.AttackMinimums = -size_vector
end

function SWEP:SetupDataTables() self:NetworkVar("Bool", 0, "Attacking") end

function SWEP:Think()
	local primary_attacking = self.PrimaryAttacking
	
	if primary_attacking ~= self.PrimaryAttackingPrevious then
		self.PrimaryAttackingPrevious = primary_attacking
		
		self:SetAttacking(primary_attacking)
		self:SetHoldType(primary_attacking and hold_types[math.random(hold_type_count)] or "normal")
	end
	
	self.PrimaryAttacking = false
end