AddCSLuaFile()

--locals
local hack_angle = Angle(0.01, 0.01, 0.01) --this angle is a hack to prevent the angle from acting strange and messing up when we change it back to a normal
local material_ring = Material("effects/select_ring")
local render_maximums = Vector(8, 8, 8)
local render_minimums = -render_maximums

function EFFECT:Init(data)
	self:SetAngles(data:GetNormal():Angle() + hack_angle)
	self:SetCollisionBounds(render_minimums, render_maximums)
	self:SetParentPhysNum(data:GetAttachment())
	self:SetPos(data:GetOrigin() + data:GetNormal() * 2)
	
	if IsValid(data:GetEntity()) then self:SetParent(data:GetEntity()) end
	
	self.Alpha = 255
	self.Life = 0.5
	self.Normal = data:GetNormal()
	self.Pos = data:GetOrigin()
	self.Size = 4
	self.Speed = math.Rand(0.5, 1.5)
end

function EFFECT:Think()
	local alpha = self.Alpha
	local speed = self.Speed
	
	--1275 = 255 * 5
	self.Alpha = alpha - FrameTime() * 1275 * speed 
	self.Size = self.Size + FrameTime() * 256 * speed 
	
	return alpha >= 0
end

function EFFECT:Render()
	local alpha = self.Alpha
	
	if alpha < 1 then return end
	
	render.SetMaterial(material_ring)
	render.DrawQuadEasy(self:GetPos(), self:GetAngles():Forward(), self.Size, self.Size, Color(math.Rand(10, 150), math.Rand(170, 220), math.Rand(240, 255), alpha))
end