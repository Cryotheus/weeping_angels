SWEP.Author = "Cryotheum"
SWEP.CanHolster = true
SWEP.Contact = "Discord: Cryotheum#4096"
SWEP.Instructions = "Standard primary and secondary action, reload to use special action."
SWEP.PrintName = "#GMOD_ToolGun"
SWEP.Purpose = "Used to edit the map's configuration."
SWEP.ShootSound = "Airboat.FireGunRevDown"
SWEP.Spawnable = true
SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/c_toolgun.mdl")
SWEP.ViewModelFOV = 54
SWEP.WorldModel = Model("models/weapons/w_toolgun.mdl")

SWEP.Primary = {
	Ammo = "none",
	Automatic = false,
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
local tool_mask = bit.bor(CONTENTS_AUX, CONTENTS_DEBRIS, CONTENTS_GRATE, CONTENTS_MONSTER, CONTENTS_MOVEABLE, CONTENTS_SOLID, CONTENTS_WINDOW)

--swep functions
function SWEP:DoShootEffect(hit_position, hit_normal, entity, physics_bone)
	local owner = self:GetOwner()
	
	self:EmitSound(self.ShootSound)
	self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
	owner:SetAnimation(PLAYER_ATTACK1)
	
	if IsFirstTimePredicted() then return end
	
	do --indicator effect
		local indicator = EffectData()
		
		indicator:SetOrigin(hit_position)
		indicator:SetNormal(hit_normal)
		indicator:SetEntity(entity)
		indicator:SetAttachment(physics_bone)
		
		--localized from sandbox
		util.Effect("wa_selection_indicator", indicator)
	end
	
	do --tracer effect
		local tracer = EffectData()
		
		tracer:SetOrigin(hit_position)
		tracer:SetStart(owner:GetShootPos())
		tracer:SetAttachment(1)
		tracer:SetEntity(self)
		
		--from base gamemode
		util.Effect("ToolTracer", tracer)
	end
end

function SWEP:FireAnimationEvent(_position, _angles, event)
	if event == 21 then return true end --disables animation based muzzle event
	if event == 5003 then return true end --disable thirdperson muzzle flash
end

function SWEP:PrimaryAttack(action)
	local action = action or "Primary"
	local owner = self:GetOwner()
	local trace_settings = util.GetPlayerTrace(owner)
	
	trace_settings.mask = tool_mask
	
	local trace = util.TraceLine(trace_settings)
	
	if not trace.Hit then return end
	--if hook.Run("BuilderTool", self.Mode, action, trace) then self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone) end
	self:DoShootEffect(trace.HitPos, trace.HitNormal, trace.Entity, trace.PhysicsBone)
end

function SWEP:Reload()
	if not self:GetOwner():KeyPressed(IN_RELOAD) then return end --semi-auto reload 
	
	self:PrimaryAttack("Special")
end

function SWEP:SecondaryAttack() self:PrimaryAttack("Secondary") end

function SWEP:Think() self.Mode = self:GetOwner():GetInfo("wa_toolmode") end