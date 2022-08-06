--locals
local client_entities = WEEPING_ANGELS.ClientEntities or {}

--local table
local banned_bones = {
	["__INVALIDBONE__"] = true,
	["ValveBiped.Bip01_L_Bicep"] = false,
	["ValveBiped.Bip01_L_Elbow"] = false,
	["ValveBiped.Bip01_L_Finger0"] = false,
	["ValveBiped.Bip01_L_Finger01"] = false,
	["ValveBiped.Bip01_L_Finger02"] = false,
	["ValveBiped.Bip01_L_Finger1"] = false,
	["ValveBiped.Bip01_L_Finger11"] = false,
	["ValveBiped.Bip01_L_Finger12"] = false,
	["ValveBiped.Bip01_L_Finger2"] = false,
	["ValveBiped.Bip01_L_Finger21"] = false,
	["ValveBiped.Bip01_L_Finger22"] = false,
	["ValveBiped.Bip01_L_Finger3"] = false,
	["ValveBiped.Bip01_L_Finger31"] = false,
	["ValveBiped.Bip01_L_Finger32"] = false,
	["ValveBiped.Bip01_L_Finger4"] = false,
	["ValveBiped.Bip01_L_Finger41"] = false,
	["ValveBiped.Bip01_L_Finger42"] = false,
	["ValveBiped.Bip01_L_Pectoral"] = false,
	["ValveBiped.Bip01_L_Shoulder"] = false,
	["ValveBiped.Bip01_L_Trapezius"] = false,
	["ValveBiped.Bip01_L_Ulna"] = false,
	["ValveBiped.Bip01_L_Wrist"] = false,
	["ValveBiped.Bip01_R_Bicep"] = false,
	["ValveBiped.Bip01_R_Elbow"] = false,
	["ValveBiped.Bip01_R_Finger0"] = false,
	["ValveBiped.Bip01_R_Finger01"] = false,
	["ValveBiped.Bip01_R_Finger02"] = false,
	["ValveBiped.Bip01_R_Finger1"] = false,
	["ValveBiped.Bip01_R_Finger11"] = false,
	["ValveBiped.Bip01_R_Finger12"] = false,
	["ValveBiped.Bip01_R_Finger2"] = false,
	["ValveBiped.Bip01_R_Finger21"] = false,
	["ValveBiped.Bip01_R_Finger22"] = false,
	["ValveBiped.Bip01_R_Finger3"] = false,
	["ValveBiped.Bip01_R_Finger31"] = false,
	["ValveBiped.Bip01_R_Finger32"] = false,
	["ValveBiped.Bip01_R_Finger4"] = false,
	["ValveBiped.Bip01_R_Finger41"] = false,
	["ValveBiped.Bip01_R_Finger42"] = false,
	["ValveBiped.Bip01_R_Shoulder"] = false,
	["ValveBiped.Bip01_R_Trapezius"] = false,
	["ValveBiped.Bip01_R_Ulna"] = false,
	["ValveBiped.Bip01_R_Wrist"] = false,
	["ValveBiped.forward"] = true,
}

--local functions
local function create_model(ply)
	local model = ClientsideRagdoll(ply:GetModel())
	local model_offsets = {}
	local position = ply:GetPos() + Vector(0, 0, 10)
	
	table.insert(client_entities, model)
	model:SetMaterial("models/props_canal/rock_riverbed01a")
	
	for index = 0, model:GetPhysicsObjectCount() - 1 do
		local physics = model:GetPhysicsObjectNum(index)
		
		if physics:IsValid() then
			local physics_position = physics:GetPos()
			
			model_offsets[index] = physics_position
			
			physics:SetPos(physics_position + position)
			physics:EnableMotion(false)
		end
	end
	
	--needed
	function model:SetAbsolutePos(position)
		self:SetPos(position)
		
		for index = 0, model:GetPhysicsObjectCount() - 1 do
			local physics = model:GetPhysicsObjectNum(index)
			
			if physics:IsValid() then physics:SetPos(model_offsets[index] + position) end
		end
	end
	
	return model
end

--globals
WEEPING_ANGELS.ClientEntities = client_entities

--gamemode hooks
function GM:PlayerAngelFrozen(ply, frozen)
	--chat.AddText(Color(255, 192, 0), ply:Name() .. " had their frozen field set to " .. tostring(frozen) .. ".")
	ply:DrawShadow(not frozen)
	
	if frozen then
		local freeze_bone_positions = {}
		local freeze_bones = {}
		local model = ply.FreezeBonesModel
		local player_position = ply:GetPos()
		ply.FreezeBonePositions = freeze_bone_positions
		ply.FreezeBones = freeze_bones
		
		if not IsValid(model) then
			model = create_model(ply)
			ply.FreezeBonesModel = model
		end
		
		--do we need this?
		ply:SetupBones()
		
		--cache bone position and angles
		for bone_index = 0, ply:GetBoneCount() do
			--to prevent unwritable bone errors
			if not banned_bones[ply:GetBoneName(bone_index)] then
				local matrix = ply:GetBoneMatrix(bone_index)
				
				freeze_bone_positions[bone_index] = matrix:GetTranslation() - player_position
				freeze_bones[bone_index] = matrix
			end
		end
		
		return
	end
	
	ply.FreezeBonePositions = false
	ply.FreezeBones = false
end

function GM:PrePlayerDraw(ply, flags)
	local freeze_bones = ply.FreezeBones
	local model = ply.FreezeBonesModel
	
	if freeze_bones and IsValid(model) then
		local freeze_bone_positions = ply.FreezeBonePositions
		local player_position = ply:GetPos()
		
		model:SetAbsolutePos(player_position)
		model:SetupBones()
		
		for bone_index = 0, model:GetBoneCount() do
			if not banned_bones[model:GetBoneName(bone_index)] then
				local matrix = freeze_bones[bone_index]
				
				--model:SetTranslation()
				matrix:SetTranslation(freeze_bone_positions[bone_index] + player_position)
				model:SetBoneMatrix(bone_index, matrix)
			end 
		end
		
		model:DrawModel(flags)
		
		--debugoverlay.Axis(model:GetPos(), model:GetAngles(), 5, RealFrameTime(), true)
		
		return true
	end
end

--hooks
hook.Add("PlayerChangedTeam", "WeepingAngelsPlayerAngel", function(ply, _old, new)
	local model = ply.FreezeBonesModel
	
	if new == TEAM_ANGEL then
		local model = IsValid(model) and model or create_model(ply)
		ply.FreezeBonesModel = model
		
		ply:DrawShadow(false)
	elseif model then
		ply.FreezeBonesModel = nil
		
		if model:IsValid() then model:Remove() end
	end
end)

--autoreload
for index, entity in ipairs(client_entities) do if entity:IsValid() then entity:Remove() end end

table.Empty(client_entities)