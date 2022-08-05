AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Type = "anim"

ENT.PrintName = "Visibility Test"
ENT.Author = "Cryotheum"
ENT.Contact = "Cryotheum#4096"
ENT.Purpose = "Testing visibility in Weeping Angels"
ENT.Instructions = "None"
ENT.Spawnable = true
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

local render_maximums = Vector(1, 1, 1)
local render_minimums = -render_maximums

function ENT:DrawTranslucent()
	local angles = self:GetAngles()
	local bounds_minimum, bounds_maximum = self:GetCollisionBounds()
	local color = self:GetColor()
	local positon = self:GetPos()
	
	local distance = EyePos():Distance(positon) * 0.01
	
	render.SetColorMaterial()
	render.DrawBox(positon, angles, render_minimums * distance, render_maximums * distance, color)
	--0.7365
	color.a = 128
	
	render.DrawBox(positon, angles, bounds_minimum, bounds_maximum, color)
end

function ENT:Initialize()
	self:SetAutomaticFrameAdvance(true)
	
	if CLIENT then return end
	
end

function ENT:OnRemove() hook.Remove("HUDPaint", self) end

if CLIENT then return end

function ENT:Think()
	local target = self:GetPos()
	local visible = false
	
	for index, ply in ipairs(player.GetAll()) do
		ply:PointIsVisible(target)
	end
	
	self:SetColor(visible and Color(0, 144, 0) or Color(240, 0, 0))
	self:NextThink(0)
	
	return true
end