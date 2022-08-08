DEFINE_BASECLASS("player_default")

--locals
local PLAYER = {
	AvoidPlayers = false,
	CanUseFlashlight = true,
	DisplayName = "Builder",
	DuckSpeed = 0.2,
	MaxArmor = 0,
	RunSpeed = 600,
	SlowWalkSpeed = 150,
	TeammateNoCollide = false,
	UnDuckSpeed = 0.2,
	WalkSpeed = 300
}

--player functions
function PLAYER:Loadout()
	local ply = self.Player
	
	ply:RemoveAllItems()
	ply:Give("wa_builder_tool")
	ply:Give("weapon_crowbar")
	ply:Give("weapon_physgun")
end

--post
player_manager.RegisterClass("player_builder", PLAYER, "player_default")