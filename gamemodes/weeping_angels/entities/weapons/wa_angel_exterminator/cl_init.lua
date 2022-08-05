include("shared.lua")

--locals
local beam_end_width = 10
local beam_color = Color(255, 192, 128)
local beam_points = 9
local beam_points_divider = beam_points - 1
local beam_warble = 20
local beam_width = 10
local charge_time = 2
local glow_width = 54
local material_glow = Material("sprites/light_glow02_add")
local math_sin = math.sin
local pi = math.pi
local reticle_material = Material("vgui/hud/xbox_reticle")
local soft_glow_width = 72
local view_model_beam_target_offset = Vector(0, 0, 8)

local beam_material = CLIENT and CreateMaterial("weeping_angels/angel_exterminator_beam", "UnlitGeneric", {
	["$additive"] = 1,
	["$basetexture"] = "sprites/physbeam_active_white",
	["$MaxLight"] = 1,
	["$MinLight"] = 1,
	["$model"] = 1,
	["$nocull"] = 1,
	["$translucent"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

local beam_material_charging = CLIENT and CreateMaterial("weeping_angels/angel_exterminator_beam_charging", "UnlitGeneric", {
	["$additive"] = 1,
	["$basetexture"] = "sprites/laser",
	["$MaxLight"] = 1,
	["$MinLight"] = 1,
	["$model"] = 1,
	["$nocull"] = 1,
	["$translucent"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1
})

local material_soft_glow = CLIENT and CreateMaterial("weeping_angels/angel_exterminator_glow", "UnlitGeneric", {
	["$additive"] = 1,
	["$basetexture"] = "sprites/glow06",
	["$translucent"] = 1,
	["$vertexcolor"] = 1
})

--local functions
local function bezier(start, control, finish, fraction)
	local fraction_inverse = 1 - fraction
	local out = fraction_inverse ^ 2 * start + 2 * fraction_inverse * fraction * control + fraction ^ 2 * finish 
	
	--debugoverlay.Axis(out, angle_zero, 5, RealFrameTime(), true)
	
	return out
end

function SWEP:DoDrawCrosshair(x, y)
	local size = math.floor(ScrW() * 0.04) * 2
	local size_half = size * 0.5
	
	surface.SetDrawColor(0, 0, 0)
	surface.SetMaterial(reticle_material)
	surface.DrawTexturedRect(x - size_half, y - size_half, size, size)
	
	surface.SetDrawColor(beam_color)
	surface.DrawTexturedRect(x - size_half, y - size_half, size, size)
	
	return true
end

function SWEP:DrawBeam(start, target, draw_source_glow)
	local cur_time = CurTime()
	local distance = target:Distance(start)
	local real_time = RealTime()
	local owner = self:GetOwner()
	local shoot_time = cur_time - self:GetAttackStart()
	local target_control = start + owner:GetAimVector() * distance * 0.5
	local target_fraction = math.Clamp((shoot_time / charge_time) ^ 2, 0, 1)
	local sprite_width = target_fraction ^ 0.1 * soft_glow_width
	
	render.SetMaterial(material_soft_glow)
	render.DrawSprite(start, sprite_width, sprite_width, beam_color)
	
	if draw_source_glow then
		sprite_width = sprite_width * 0.25
		
		render.SetMaterial(material_glow)
		render.DrawSprite(start, sprite_width, sprite_width, beam_color)
	else render.SetMaterial(material_glow) end
	
	if target_fraction == 1 then
		local width_scroll = real_time * 2
		local scroll_offset = real_time * 4
		local sprite_width = math_sin(width_scroll * pi % pi) * glow_width + glow_width
		
		render.DrawSprite(target, sprite_width, sprite_width, beam_color)
		render.SetMaterial(beam_material)
		render.StartBeam(beam_points)
		
		for point = 0, beam_points_divider do
			local fraction = point / beam_points_divider
			
			render.AddBeam(
				bezier(start, target_control, target, fraction),
				point ~= 0 and point ~= beam_points_divider and beam_width - math_sin((width_scroll + fraction) * pi % pi) ^ 0.75 * beam_warble + beam_warble or beam_end_width,
				fraction + scroll_offset,
				beam_color
			)
		end
	else
		local width = target_fraction * beam_width
		local scroll_offset = real_time * 2
		local sprite_width = target_fraction * glow_width
		
		render.DrawSprite(target, sprite_width, sprite_width, beam_color)
		render.SetMaterial(beam_material_charging)
		render.StartBeam(beam_points)
		
		for point = 0, beam_points_divider do
			local fraction = point / beam_points_divider
			
			render.AddBeam(
				bezier(start, target_control, target, fraction),
				width,
				fraction + scroll_offset,
				beam_color
			)
		end
	end
	
	render.EndBeam()
end

function SWEP:DrawWorldModelTranslucent()
	if self:GetAttacking() then
		local start = self:GetAttachment(1).Pos
		local target = self:GetAngel():WorldSpaceCenter()
		
		target.z = (target.z + start.z) * 0.5
		
		self:DrawBeam(start, target, true)
	end
end

function SWEP:PreDrawViewModel(view_model, _swep, owner)
	cam.Start3D(owner:EyePos(), owner:EyeAngles())
		cam.IgnoreZ(true)
			local view_entity = owner:GetViewEntity()
			
			if view_entity == owner then
				local start = view_model:GetAttachment(1).Pos
				local sprite_width = soft_glow_width * 0.75
				
				render.SetMaterial(material_soft_glow)
				render.DrawSprite(start, sprite_width, sprite_width, beam_color)
				
				if self:GetAttacking() then
					
					self:DrawBeam(start, self:GetAngel():WorldSpaceCenter() + view_model_beam_target_offset)
				end
			end
		cam.IgnoreZ(false)
	cam.End3D()
	
	render.ClearDepth()
end
