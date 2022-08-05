--locals
local freeze_registry = {}
local freeze_velocity = Vector(-1, -1, 0)

--globals
GM.PlayerAngelFreezeRegistry = freeze_registry

--local functions
local function freeze(angel)
	if angel:IsOnGround() then angel:SetVelocity(angel:GetVelocity() * freeze_velocity) end
	
	angel:SetFrozen(true)
	hook.Run("PlayerAngelFrozen", angel, true)
end

local function unfreeze(angel)
	angel:SetFrozen(false)
	hook.Run("PlayerAngelFrozen", angel, false)
end

--gamemode functions
function GM:PlayerAngelFreeze(angel, key, state)
	local was_frozen = false
	local registry = freeze_registry[angel]
	
	if registry then
		was_frozen = next(registry) and true or false
		registry[key] = state or nil
	else
		registry = {[key] = state or nil}
		freeze_registry[angel] = registry
	end
	
	local now_frozen = next(registry) and true or false
	
	if now_frozen == was_frozen then return end
	if now_frozen then freeze(angel)
	else unfreeze(angel) end
end

--gamemode hooks
function GM:PlayerAngelFrozen(_angel, _frozen)
	--debug
	--_angel:SetColor(_frozen and Color(0, 144, 0) or Color(255, 0, 0))
end

--hooks
hook.Add("PlayerVisibilityChanged", "WeepingAngelsPlayerAngelFreeze", function(angel, status) GAMEMODE:PlayerAngelFreeze(angel, "Visibility", status) end)