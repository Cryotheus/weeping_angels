--locals
local color_dark_shadow = Color(0, 0, 0, 120)
local color_shadow = Color(0, 0, 0, 50)
local health_percentage = GM._HealthPrecentage
local local_player = LocalPlayer()
local small_target_id_font = "TargetIDSmall"
local target_id_font = "TargetID"

--local tables
local blocked_common = {
	CHudBattery = true,
	CHudHealth = true,
	CHudDamageIndicator = true
}

local blocked = blocked_common
local blocked_angel = table.Merge(table.Copy(blocked_common), {CHudZoom = true})

--local functions
local function draw_target_id_text(text, font, x, y, color)
	draw.SimpleText(text, font, x + 1, y + 1, color_dark_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(text, font, x + 2, y + 2, color_shadow, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(text, font, x, y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end

--gamemode hooks
function GM:HUDCreate()
	self:HUDRemove()
	
	local panel = vgui.Create("WeepingAngelsHUD", GetHUDPanel())
	self.PanelsHUDPanel = panel
	
	panel:EnableHealthBar(true)
end

function GM:HUDDrawTargetID()
	local trace = util.TraceLine(util.GetPlayerTrace(local_player))
	
	if not trace.Hit or not trace.HitNonWorld then return end
	
	local bottom_line
	local local_team = local_player:Team()
	local text_color
	local top_line
	local trace_entity = trace.Entity
	local trace_entity_class = trace_entity:GetClass()
	
	if trace_entity_class == "prop_ragdoll" and trace_entity.GetPlayer then trace_entity = trace_entity:GetPlayer() end
	
	if trace_entity:IsPlayer() then
		text_color = team.GetColor(trace_entity:Team())
		top_line = trace_entity:Nick()
		
		if local_team == TEAM_SURVIVOR then bottom_line = trace_entity:Alive() and "Alive" or local_player:GetIsCultist() and "Freash Meat" or "Deceased"
		else bottom_line = health_percentage(trace_entity:Health(), trace_entity:GetMaxHealth()) end
	elseif self:AllowPlayerPickup(local_player, trace_entity) then
		local holder = trace_entity:GetNWEntity("PropHolder")
		top_line = "Physics Prop"
		
		if IsValid(holder) then bottom_line = "Held by " .. holder:Nick()
		else
			local physics = trace_entity:GetPhysicsObject()
			local freezing = trace_entity:GetNWBool("PropFreezing")
			
			if physics:IsValid() then freezing = physics:IsMotionEnabled() end
			
			bottom_line = freezing and "Freezing..." or "Portable"
		end
	end
	
	--if we only have a bottom line (somehow)
	if not top_line then
		if not bottom_line then
			--give up if we have nothing to draw
			self.HUDTargetIDDrawn = false
			
			return
		end
		
		top_line, bottom_line = bottom_line, nil
	end
	
	if not text_color then text_color = team.GetColor(local_team) end --make sure we have a color
	
	--text is at the center bottom of the screen
	local x = ScrW() * 0.5
	local y = ScrH() - 4
	self.HUDTargetIDDrawn = true
	
	if bottom_line then
		draw_target_id_text(top_line, target_id_font, x, y - 14, text_color)
		draw_target_id_text(bottom_line, small_target_id_font, x, y, text_color)
	else draw_target_id_text(top_line, target_id_font, x, y, text_color) end
end

function GM:HUDRemove() for index, child in ipairs(GetHUDPanel():GetChildren()) do if child:GetName() == "WeepingAngelsHUD" then child:Remove() end end end
function GM:HUDShouldDraw(name) return blocked[name] == nil end

--hooks
hook.Add("InitPostEntity", "WeepingAngelsHUD", function() local_player = LocalPlayer() end)
hook.Add("LocalPlayerChangedTeam", "WeepingAngelsHUD", function(_old, new) blocked = new == TEAM_ANGEL and blocked_angel or blocked_common end)

--commands
concommand.Add("wa_reload_hud", function() create_hud() end)