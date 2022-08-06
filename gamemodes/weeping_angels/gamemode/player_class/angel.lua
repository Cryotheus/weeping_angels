DEFINE_BASECLASS("player_validated")

--locals
local PLAYER = {
	AvoidPlayers = false,
	DisplayName = "Weeping Angel",
	MaxHealth = 8000,
	RunSpeed = 1000,
	SlowWalkSpeed = 150,
	StartHealth = 8000,
	TeammateNoCollide = false
}

--local functions
local function fullbright_changed(ply, _name, _old, new)
	if ply ~= LocalPlayer() then return end
	
	hook.Run("VisibilityFullbright", "AngelPlayerClass", new)
end

local function frozen_changed(ply, _name, old, new)
	print(ply, _name, old, new)
	
	if old ~= new then hook.Run("PlayerAngelFrozen", ply, new) end
end

--player functions
function PLAYER:Death(_inflictor, _attacker)
	local ply = self.Player
	
	ply:SetTeam(TEAM_SPECTATOR)
	ply:Spawn()
end

function PLAYER:DoFreeze(ply, move, command)
	if ply:GetFrozen() then
		move:SetButtons(0)
		
		if command then command:ClearButtons() end
		
		return true
	end
	
	return false
end

--function PLAYER:FinishMove(move) end --copy the results of the move back to the Player

function PLAYER:Loadout()
	local ply = self.Player
	
	ply:RemoveAllItems()
	ply:Give("wa_angel_weapon")
end

function PLAYER:Move(move) --runs the move (can run multiple times for the same client)
	--more?
	if self:DoFreeze(self.Player, move) then return end
end

function PLAYER:SetModelPost() self.Player:SetMaterial("models/props_canal/rock_riverbed01a") end

function PLAYER:SetupDataTables()
	local ply = self.Player
	
	ply:NetworkVar("Bool", 0, "Frozen")
	ply:NetworkVar("Bool", 1, "Fullbright")
	
	if CLIENT then
		ply:NetworkVarNotify("Frozen", frozen_changed)
		ply:NetworkVarNotify("Fullbright", fullbright_changed)
	end
end

function PLAYER:Spawn()
	self.Player:DrawShadow(false)
	
	return BaseClass.Spawn(self)
end

function PLAYER:StartMove(move, command) --copies from the user command to the move
	--more?
	if self:DoFreeze(self.Player, move, command) then return end
end

--post
player_manager.RegisterClass("player_angel", PLAYER, "player_validated")