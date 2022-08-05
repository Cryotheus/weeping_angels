DEFINE_BASECLASS("player_default")

--locals
local kleiner_model = "models/player/kleiner.mdl"
local players_warned = {}

local PLAYER = {
	AvoidPlayers = false,
	CanUseFlashlight = true,
	DisplayName = "Weeping Angels Player Base",
	DuckSpeed = 0.2,
	MaxArmor = 0,
	RunSpeed = 300,
	SlowWalkSpeed = 150,
	TeammateNoCollide = false,
	UnDuckSpeed = 0.2,
	WalkSpeed = 300
}

--player functions
function PLAYER:Fall() return 0 end

function PLAYER:Spawn()
	self.Player:DrawShadow(true)
	
	return BaseClass.Spawn(self)
end

function PLAYER:SetModel()
	local ply = self.Player
	local model_name = player_manager.TranslatePlayerModel(ply:GetInfo("cl_playermodel"))
	
	util.PrecacheModel(model_name)
	ply:SetMaterial("")
	ply:SetModel(model_name)
	
	--make sure the model has the bones needed for this gamemode
	for index, bone_name in ipairs(GAMEMODE.PlayerVisibilityBones) do
		if not ply:LookupBone(bone_name) then
			ply:SetModel(kleiner_model)
			
			--we will only warn them about their invalid model once
			if players_warned[ply] then break end
			
			players_warned[ply] = true
			
			--archaic...
			ply:PrintMessage(HUD_PRINTCONSOLE, "Your player model does not have all the required bones for usage in this gamemode. Your model will be set to kleiner as a fallback.")
			
			break
		end
	end
	
	if self.SetModelPost then self:SetModelPost() end
end

--hooks
hook.Add("PlayerDisconnected", "WeepingAngelsPlayerClassValidated", function(ply) players_warned[ply] = nil end)

--post
player_manager.RegisterClass("player_validated", PLAYER, "player_default")
util.PrecacheModel(kleiner_model)