AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

--swep functions
function SWEP:PropPickup(entity)
	self.HeldProp = entity
	
	self:SetHoldType("knife")
end

function SWEP:PropDropped(_entity)
	self.HeldProp = nil
	
	self:SetHoldType(self:GetUsingFists() and "fist" or "normal")
end