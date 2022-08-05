--local tables
local frozen_classes = {prop_physics = true}
local maximum_pickup_mass = 45
local maximum_pickup_size = 80

--local functions
local function allow_prop_pickup(ply, entity)
	if entity.IsPlayerHolding and entity:IsPlayerHolding() then return false end --we do not want multiple players picking up the same prop
	if not frozen_classes[entity:GetClass()] then return false end --whitelist what entities can be picked up
	if ply:Team() ~= TEAM_SURVIVOR then return false end
	
	local physics = entity:GetPhysicsObject()
	
	--too heavy?
	if physics:IsValid() and physics:GetMass() > maximum_pickup_mass then return false end
	
	local minimum_bounds, maximum_bounds = entity:GetCollisionBounds()
	
	--too big?
	if minimum_bounds:Distance(maximum_bounds) > maximum_pickup_size then return false end
	
	return true
end

--gamemode hooks
function GM:AllowPlayerPickup(ply, entity, test_only)
	local allow = allow_prop_pickup(ply, entity)
	local weapon = ply:GetWeapon("wa_survivor_weapon")
	
	--they must be in pickup mode
	if not weapon:IsValid() then return false end
	if ply:GetActiveWeapon() ~= weapon or weapon:GetUsingFists() then return false end
	
	if test_only or CLIENT then return allow end
	
	local collision_group = entity:GetCollisionGroup()
	local hook_id = "PropPickup" .. entity:EntIndex()
	
	entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	entity:SetNWEntity("PropHolder", ply)
	weapon:PropPickup(entity)
	
	--watch the entity to call the PropDroped function
	hook.Add("Think", hook_id, function()
		if entity:IsValid() then
			if entity:IsPlayerHolding() then return end
			
			entity:SetCollisionGroup(collision_group)
			entity:SetNWEntity("PropHolder", NULL)
			hook.Run("PropDroped", ply, entity)
		end
	end)
	
	return allow
end

--globals
GM.PropFrozenClasses = frozen_classes