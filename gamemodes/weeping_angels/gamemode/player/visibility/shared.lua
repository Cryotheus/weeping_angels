--locals
local entity_meta = FindMetaTable("Entity")
local player_meta = FindMetaTable("Player")
local player_screen_heights = WEEPING_ANGELS.NetPlayerHeights
local player_screen_widths = WEEPING_ANGELS.NetPlayerWidths
local radian = math.pi / 180
local radian_half = radian * 0.5
local screen_height
local screen_width
local trace_leniency = 4
local trace_output = {}
local visibility_status = {}
local visibility_viewers = {}

--local tables
--[[
	ValveBiped.Bip01_Spine
	ValveBiped.Bip01_Spine1
	ValveBiped.Bip01_Spine2
	ValveBiped.Bip01_Spine4
	ValveBiped.Bip01_Neck1
	ValveBiped.Bip01_Head1
	ValveBiped.forward
	ValveBiped.Bip01_R_Clavicle
	ValveBiped.Bip01_R_UpperArm
	ValveBiped.Bip01_R_Forearm
	ValveBiped.Bip01_R_Hand
	ValveBiped.Anim_Attachment_RH
	ValveBiped.Bip01_L_Clavicle
	ValveBiped.Bip01_L_UpperArm
	ValveBiped.Bip01_L_Forearm
	ValveBiped.Bip01_L_Hand
	ValveBiped.Anim_Attachment_LH
	ValveBiped.Bip01_R_Thigh
	ValveBiped.Bip01_R_Calf
	ValveBiped.Bip01_R_Foot
	ValveBiped.Bip01_R_Toe0
	ValveBiped.Bip01_L_Thigh
	ValveBiped.Bip01_L_Calf
	ValveBiped.Bip01_L_Foot
	ValveBiped.Bip01_L_Toe0
]]

local use_bones = {
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_L_Foot",
	"ValveBiped.Bip01_R_Foot",
	"ValveBiped.Bip01_Head1",
	"ValveBiped.Bip01_Spine"
}

local visibility_trace = {
	mask = MASK_VISIBLE_AND_NPCS,
	output = trace_output
}

--localized functions
local math_abs = math.abs
local math_tan = math.tan
local Entity_EyeAngles = entity_meta.EyeAngles
local Entity_EyePos = entity_meta.EyePos
local Entity_GetBonePosition = entity_meta.GetBonePosition
local Player_GetFOV = player_meta.GetFOV
local Entity_LookupBone = entity_meta.LookupBone
local screen_height = ScrH
local screen_width = ScrW
local util_TraceLine = util.TraceLine
local WorldToLocal = WorldToLocal

--local functions
local function position_in_fov(target, source_position, source_angle, source_fov, screen_width, screen_height)
	local localized = WorldToLocal(target, angle_zero, source_position, source_angle)
	local depth = localized.x
	
	if depth <= 0 then return false end
	
	local divider = depth * math_tan(source_fov * radian_half)
	local x = localized.y * screen_height / screen_width / divider
	local y = localized.z / divider
	
	return math_abs(x) < 0.7365 and math_abs(y) < 0.7365
end

local function position_in_viewer_fov(target, viewer)
	return position_in_fov(
		target,
		Entity_EyePos(viewer),
		Entity_EyeAngles(viewer),
		Player_GetFOV(viewer) + 1,
		screen_width(viewer),
		screen_height(viewer)
	)
end

local function trace_visibility(start, finish, filter)
	trace_output.HitPos = false
	visibility_trace.endpos = finish
	visibility_trace.filter = filter
	visibility_trace.start = start
	
	util_TraceLine(visibility_trace)
	
	return trace_output.HitPos:Distance(finish) < trace_leniency
end

local function visible(viewer, target_player)
	local eye_angles = Entity_EyeAngles(viewer)
	local eye_position = Entity_EyePos(viewer)
	local filter = {viewer, target_player}
	local fov = Player_GetFOV(viewer) + 1
	local viewer_height = screen_height(viewer)
	local viewer_width = screen_width(viewer)
	
	for index, bone_name in ipairs(use_bones) do
		local bone_index = Entity_LookupBone(target_player, bone_name)
		
		if bone_index then
			local bone_position = Entity_GetBonePosition(target_player, bone_index)
			
			if position_in_fov(bone_position, eye_position, eye_angles, fov, viewer_width, viewer_height) and trace_visibility(eye_position, bone_position, filter) then
				--originally had lag compensation
				--but it kinda sucked and so did its performance
				--may remake it in the future
				return true
			end
		else return false end
	end
	
	return false
end

--sided local functions
if SERVER then
	function screen_height(ply) return player_screen_heights[ply] or 1080 end
	function screen_width(ply) return player_screen_widths[ply] or 1920 end
end

--globals
GM.PlayerVisibilityBones = use_bones
GM.PlayerVisibilityViewers = visibility_viewers

--gamemode hooks
function GM:PlayerVisibilityChanged(ply, status)
	local status_zero = status and 0 or nil
	
	visibility_status[ply] = status
	
	self:PlayerPenalizeJump(ply, "Visibility", status_zero)
	self:PlayerPenalizeSpeed(ply, "Visibility", status_zero)
end

function GM:PlayerVisibilityThinkAngel(ply, _cur_time, survivors)
	local previous_status = visibility_status[ply]
	local status = false
	local viewers = {}
	
	for survivor_index, survivor in ipairs(survivors) do
		if survivor:Alive() and visible(survivor, ply) then
			--build a list of the viewers
			table.insert(viewers, survivor)
		end
	end
	
	if next(viewers) then
		visibility_viewers[ply] = viewers
		status = true
	else visibility_viewers[ply] = nil end
	
	if status ~= previous_status then hook.Run("PlayerVisibilityChanged", ply, status) end
end

--player meta functions
function player_meta:PointIsVisible(target) return position_in_viewer_fov(target, self) and trace_visibility(self:EyePos(), target, {self}) end
function player_meta:PlayerIsVisible(ply) return visible(self, ply) end
function player_meta:ToggleFullbright() if self.SetFullbright then self:SetFullbright(not self:GetFullbright()) end end

--hooks
hook.Add("PlayerDisconnected", "WeepingAngelsPlayerVisibility", function(ply)
	visibility_viewers[ply] = nil
	visibility_status[ply] = nil
end)