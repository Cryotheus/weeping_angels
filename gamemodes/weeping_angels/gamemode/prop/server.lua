--locals
local freeze_queue = {}
local frozen_classes = GM.PropFrozenClasses
local exempt_from_freeze = WEEPING_ANGELS.PropsExemptFromFreeze or {}

local function do_freeze()
	local freezing_index = 1
	local limit = 0.01
	
	hook.Add("Think", "WeepingAngelsProp", function()
		local prop
		local start_time = SysTime()
		
		while SysTime() - start_time < limit do
			prop = freeze_queue[freezing_index]
			
			if prop then
				if prop:IsValid() then
					local creation_id = prop:MapCreationID()
					
					if not exempt_from_freeze[creation_id] then
						local physics = prop:GetPhysicsObject()
						
						if physics:IsValid() then physics:EnableMotion(false) end
					end
				end
			else break end
			
			freezing_index = freezing_index + 1
		end
		
		if prop then return end
		
		hook.Remove("Think", "WeepingAngelsProp")
	end)
end

--globals
WEEPING_ANGELS.PropsExemptFromFreeze = exempt_from_freeze

function GM:InitPostEntity() do_freeze() end

function GM:OnEntityCreated(entity)
	if not IsValid(entity) then return end
	if frozen_classes[entity:GetClass()] == nil then return end
	
	table.insert(freeze_queue, entity)
end

function GM:PlayerUse(ply, entity)
	if self:PlayerTeamIsObserver(ply) then return false end
	
	if frozen_classes[entity:GetClass()] then
		local physics = entity:GetPhysicsObject()
		
		if IsValid(physics) and not physics:IsMotionEnabled() and self:AllowPlayerPickup(ply, entity, true) then
			entity:SetNWBool("PropFreezing", true)
			physics:EnableMotion(true)
			physics:Wake()
			ply:PickupObject(entity)
		end
	end
end

function GM:PropDroped(ply, entity)
	local hook_id = "PropDrop" .. entity:EntIndex()
	local weapon = ply:IsValid() and ply:GetWeapon("wa_survivor_weapon") or NULL
	
	if weapon:IsValid() then weapon:PropDropped(entity) end
	
	hook.Add("Think", hook_id, function()
		if entity:IsValid() then
			local physics = entity:GetPhysicsObject()
			
			if physics:IsValid() then
				if physics:IsAsleep() then
					entity:SetNWBool("PropFreezing", false)
					physics:EnableMotion(false)
				else return end
			end
		end
		
		hook.Remove("Think", hook_id)
	end)
end

function GM:PostCleanupMap() do_freeze() end

--post
RunConsoleCommand("sv_playerpickupallowed", "1")