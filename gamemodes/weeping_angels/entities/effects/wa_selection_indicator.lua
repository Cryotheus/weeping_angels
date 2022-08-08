AddCSLuaFile()

--locals
local color_translucent = Color(255, 255, 255)
local hack_angle = Angle(0.01, 0.01, 0.01) --this angle is a hack to prevent the angle from acting strange and messing up when we change it back to a normal
local material_dot = Material("effects/select_dot")
local render_maximums = Vector(8, 8, 8)
local render_minimums = -render_maximums
local size = 4

function EFFECT:Init(data)
	local attachment = data:GetAttachment()
	local entity = data:GetEntity()
	local normal = data:GetNormal()
	local origin = data:GetOrigin()
	self.Alpha = 255
	
	self:SetAngles(normal:Angle() + hack_angle)
	self:SetPos(origin)
	self:SetRenderBounds(render_minimums, render_maximums)
	
	if IsValid(entity) then
		self:SetParent(entity)
		self:SetParentPhysNum(attachment)
	end
	
	do --ring effect
		local ring = EffectData()
		
		ring:SetAttachment(attachment)
		ring:SetEntity(entity)
		ring:SetNormal(normal)
		ring:SetOrigin(origin)
		
		for i = 0, 5 do util.Effect("selection_ring", ring) end
	end
end

function EFFECT:Think()
	local alpha = self.Alpha
	self.Alpha = alpha - 255 * FrameTime()
	
	return alpha > 0
end

function EFFECT:Render()
	local alpha = self.Alpha
	
	if alpha < 1 then return end
	
	color_translucent.a = alpha
	
	render.SetMaterial(material_dot)
	render.DrawQuadEasy(self:GetPos(), self:GetAngles():Forward(), size, size, color_translucent)
end