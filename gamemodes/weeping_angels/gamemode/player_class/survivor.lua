DEFINE_BASECLASS("player_validated")

--locals
local PLAYER = {
	AvoidPlayers = true,
	CanUseFlashlight = true,
	DisplayName = "Survivor",
	TeammateNoCollide = true
}

--localized functions
local bit_band = bit.band

--player functions
function PLAYER:Loadout()
	local ply = self.Player
	
	ply:RemoveAllItems()
	ply:Give("wa_survivor_weapon")
	
	if math.random(8) == 1 then
		ply:Give("weapon_357")
		ply:GiveAmmo(12, "357", true)
	end
end

function PLAYER:SetupDataTables()
	local ply = self.Player
	
	--cultists help the angel
	ply:NetworkVar("Bool", 0, "SilentWalk")
	ply:NetworkVar("Bool", 1, "Injured")
	ply:NetworkVar("Bool", 2, "IsCultist")
	ply:NetworkVar("Bool", 3, "LocalChatting")
	ply:NetworkVar("Float", 0, "InjuredTime")
	ply:NetworkVar("Float", 1, "LastDamaged")
end

function PLAYER:StartMove(_move, command) --copies from the user command to the move
	local buttons = command:GetButtons()
	local ply = self.Player
	
	local silent_walking =
		not ply:GetInjured()
		and bit_band(buttons, IN_WALK) == IN_WALK --using +walk
		and bit_band(buttons, IN_SPEED) ~= IN_SPEED --not using +speed
	
	if silent_walking ~= ply:GetSilentWalk() then ply:SetSilentWalk(silent_walking) end
end

--function PLAYER:Move(move) end --runs the move (can run multiple times for the same client)
--function PLAYER:FinishMove(move) end --copy the results of the move back to the Player

--post
player_manager.RegisterClass("player_survivor", PLAYER, "player_validated")