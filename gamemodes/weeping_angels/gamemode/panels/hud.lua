--locals
local health_bar_duration = 2
local health_bar_fade = 1
local health_bar_window = health_bar_duration + health_bar_fade
local last_health = 0
local nice_time = WEEPING_ANGELS._TimeNicefy
local PANEL = {}

--panel functions
function PANEL:EnableHealthToggling(state)
	if state then
		self.HealthToggling = 0
		
		return
	end
	
	
end

function PANEL:Init()
	GAMEMODE:HUDRemove()
	self:Dock(FILL)
	self:SetMouseInputEnabled(false)
	self:SetParent(GetHUDPanel())
	
	do --header
		local header = vgui.Create("DPanel", self)
		local parent = self
		self.HeaderPanel = header
		
		header:Dock(TOP)
		
		function header:Paint() end
		function header:PerformLayout(width, height) parent:PerformLayoutHeader(self, width, height) end
		function header:Think() parent:ThinkHeader(self) end
		
		do --timer
			local label = vgui.Create("DLabel", header)
			header.TimerLabel = label
			
			function label:Paint(width, height)
				surface.SetDrawColor(0, 0, 0, 64)
				surface.DrawRect(0, 0, width, height)
			end
		end
	end
	
	do --health bar
		local panel = vgui.Create("WeepingAngelsHUDHealth", self)
		self.HealthBarPanel = panel
	end
end

function PANEL:OnRemove() if WEEPING_ANGELS.PanelsHUDPanel == self then WEEPING_ANGELS.PanelsHUDPanel = nil end end

function PANEL:Paint() end

function PANEL:PerformLayout(width, height)
	local health_bar = self.HealthBarPanel
	local header_tall = height * 0.02
	
	self.HeaderPanel:SetTall(math.max(header_tall, 24))
	
	if health_bar then
		health_bar:DockMargin(4, 0, width * 0.75 - 4, 4)
		health_bar:SetHeight(math.max(header_tall * 0.5, 12, select(2, health_bar:GetTextSize()) + 2))
	end
end

function PANEL:PerformLayoutHeader(header, width, height)
	local label = header.TimerLabel
	local text_width = label:GetTextSize()
	
	label:SetSize(math.max(width * 0.1, text_width + 8), height)
	label:Center()
end

function PANEL:Think()
	local health_toggling = self.HealthToggling
	
	if health_toggling then
		local health = local_player:Health()
		local health_bar = self.HealthBarPanel
		local real_time = RealTime()
		
		if health ~= last_health then
			if not health_bar:IsVisible() then health_bar:SetVisible(true) end
			
			health_toggling = real_time
			last_health = health
			health_bar.AlphaMultiplier = nil
			self.HealthToggling = health_toggling
		end
		
		local time_difference = real_time - health_toggling
		
		if time_difference > health_bar_window then
			if health_bar:IsVisible() then
				health_bar.AlphaMultiplier = nil
				
				health_bar:SetVisible(false)
			end
			
			return
		end
		
		if time_difference > health_bar_duration then
			health_bar.AlphaMultiplier = math.Remap(time_difference - health_bar_duration, 0, health_bar_fade, 1, 0)
		end
	end
end

function PANEL:ThinkHeader(header)
	local label = header.TimerLabel
	local time_remaining = GAMEMODE:TimerGetRemaining()
	
	if time_remaining == 0 then if label:IsVisible() then label:SetVisible(false) end
	else
		local new_text = nice_time(math.ceil(time_remaining), 2, false, nil, {}, "", ":")
		
		if not label:IsVisible() then label:SetVisible(true) end
		if label:GetText() ~= new_text then label:SetText(new_text) end
	end
end

--post
derma.DefineControl("WeepingAngelsHUD", "Container for everything in the HUD", PANEL, "DPanel")