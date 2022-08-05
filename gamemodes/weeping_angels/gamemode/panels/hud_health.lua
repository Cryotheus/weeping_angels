--locals
local bar_background_color = color_black
local bar_color = color_white
local bar_flash_color = color_white
local health = 0
local health_percentage = GM._HealthPrecentage
local hurt_shake = 0
local hurt_time = 0
local last_health = 0
local local_player = LocalPlayer()
local max_health = 1
local shake_threshold = 100
local PANEL = {}

--localized functions
local math_sqrt = math.sqrt

--local functions
local function color_mix(from, to, fraction)
	local fraction_inverse = 1 - fraction
	
	return Color(
		math_sqrt(from.r ^ 2 * fraction_inverse + to.r ^ 2 * fraction),
		math_sqrt(from.g ^ 2 * fraction_inverse + to.g ^ 2 * fraction),
		math_sqrt(from.b ^ 2 * fraction_inverse + to.b ^ 2 * fraction)
	)
end

local function draw_bar(x, y, width, height, fractional_width, hurt_fraction)
	surface.SetDrawColor(bar_background_color)
	surface.DrawRect(x, y, width, height)
	
	surface.SetDrawColor(hurt_fraction == 1 and bar_color or color_mix(bar_flash_color, color, hurt_fraction))
	surface.DrawRect(x, y, fractional_width, height)
	surface.SetAlphaMultiplier(1)
end

--panel functions
function PANEL:Init()
	self:Dock(BOTTOM)
	self:SetContentAlignment(5)
	self:SetFont("DermaDefaultBold")
	self:SetTextColor(color_white)
	
	self.Think = local_player:IsValid() and self.ThinkHealth or self.ThinkValidity
	
	self:UpdateText(health, max_health)
end

function PANEL:ThinkHealth()
	health = local_player:Health()
	max_health = local_player:GetMaxHealth()
	
	if health == last_health then return end
	if health < last_health then hurt_time = RealTime() end
	
	local health_difference = last_health - health
	last_health = health
	
	if health_difference > shake_threshold then hurt_shake = RealTime() + math.min((health_difference - shake_threshold) * 0.005, 1) end
	
	self:UpdateText(health, max_health)
end

function PANEL:ThinkValidity() if local_player:IsValid() then self.Think = self.ThinkHealth end end

function PANEL:UpdateText(health, max_health)
	local new_text = health_percentage(health, max_health)
	
	if self:GetText() == new_text then return end
	
	self:SetText(new_text)
end

function PANEL:Paint(width, height)
	local alpha = self.AlphaMultiplier
	local fraction = health / max_health
	local fractional_width = math.Round(width * fraction)
	local hurt_fraction = math.max(RealTime() - hurt_time, 1)
	local hurt_shake_distance = math.max(hurt_shake - RealTime(), 0) * 10
	
	if alpha then surface.SetAlphaMultiplier(alpha) end
	
	if hurt_shake_distance > 0 then
		local clipping = DisableClipping(true)
		
		draw_bar(
			math.Rand(-hurt_shake_distance, hurt_shake_distance),
			math.Rand(-hurt_shake_distance, hurt_shake_distance),
			width,
			height,
			fractional_width,
			hurt_fraction
		)
		
		DisableClipping(clipping)
		
		return
	end
	
	draw_bar(0, 0, width, height, fractional_width, hurt_fraction)
end

--hooks
hook.Add("InitPostEntity", "WeepingAngelsPanelsHUDHealth", function() local_player = LocalPlayer() end)

hook.Add("LocalPlayerChangedTeam", "WeepingAngelsPanelsHUDHealth", function(_ply, _old, new)
	local team_color = team.GetColor(new)
	
	bar_color = color_mix(color_black, team_color, 0.75)
	bar_background_color = color_mix(color_black, team_color, 0.25)
	bar_flash_color = color_mix(color_white, team_color, 0.1)
end)

--team.GetColor
--post
derma.DefineControl("WeepingAngelsHUDHealth", "Health bar", PANEL, "DLabel")