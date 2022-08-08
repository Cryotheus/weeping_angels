--locals
local cancel_velocity = Vector(-1, -1, 0)
local freeze_registry = {}
local freeze_velocity = Vector(-1, -1, 0)

--globals
GM.PlayerAngelFreezeRegistry = freeze_registry

--local functions
local function freeze(ply)
	if ply:IsOnGround() then ply:SetVelocity(ply:GetVelocity() * freeze_velocity) end
	
	ply:SetFrozen(true)
	hook.Run("PlayerAngelFrozen", ply, true) --only used on client
end

local function unfreeze(ply)
	ply:SetFrozen(false)
	hook.Run("PlayerAngelFrozen", ply, false) --only used on client
end

--gamemode functions
function GM:PlayerAngelFreeze(ply, key, state)
	local was_frozen = false
	local registry = freeze_registry[ply]
	
	if registry then
		was_frozen = next(registry) and true or false
		registry[key] = state or nil
	else
		registry = {[key] = state or nil}
		freeze_registry[ply] = registry
	end
	
	local now_frozen = next(registry) and true or false
	
	if now_frozen == was_frozen then return end
	if now_frozen then freeze(ply)
	else unfreeze(ply) end
end

--gamemode hooks
function GM:PlayerAngelThink(ply) if ply:GetFrozen() then ply:SetVelocity(ply:GetVelocity() * cancel_velocity) end end

--hooks
hook.Add("PlayerVisibilityChanged", "WeepingAngelsPlayerAngelFreeze", function(angel, status) hook.Run("PlayerAngelFreeze", angel, "Visibility", status) end)