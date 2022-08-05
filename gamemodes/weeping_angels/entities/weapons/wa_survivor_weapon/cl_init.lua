include("shared.lua")

--locals
local reticle_material = Material("vgui/hud/xbox_reticle")

--swep functions
function SWEP:DoDrawCrosshair(x, y)
	if self:GetUsingFists() then
		local size = math.floor(ScrW() * 0.04) * 2
		local size_half = size * 0.5
		
		surface.SetDrawColor(0, 0, 0)
		surface.SetMaterial(reticle_material)
		surface.DrawTexturedRect(x - size_half, y - size_half, size, size)
		
		surface.SetDrawColor(255, 192, 0)
		surface.DrawTexturedRect(x - size_half, y - size_half, size, size)
		
		return true
	end
end

function SWEP:GetViewModelPosition(eye_position)
	--we adjust the fists to be even lower when holstered otherwise we can weird finger signs
	if self:GetUsingFists() then return end
	
	local view_model = self:GetOwner():GetViewModel()
	local sequence = view_model:GetSequence()
	local sequence_duration = view_model:SequenceDuration()
	local sequence_fraction = math.Clamp(CurTime() - self:GetAnimationStart(), 0, sequence_duration) / sequence_duration
	
	--we are only doing this to the fists_holster sequence
	if sequence == 6 then return eye_position + Vector(0, 0, sequence_fraction * -10)
	elseif sequence == 1 then
		if sequence_fraction < 0.1 then return eye_position + Vector(0, 0, -20) end
		
		return eye_position + Vector(0, 0, sequence_fraction * 8 - 2)
	end
end