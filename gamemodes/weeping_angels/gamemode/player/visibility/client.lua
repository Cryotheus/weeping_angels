--locals
local registry = {}
local zoom_material = Material("vgui/zoom")

--local functions
local function draw_fullbright()
	local width, height = ScrW(), ScrH()
	local width_half, height_half = width * 0.5, height * 0.5
	
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(zoom_material)
	
	surface.DrawTexturedRect(width_half, 0, width_half, height_half) --top right
	surface.DrawTexturedRectUV(0, 0, width_half, height_half, 1, 0, 0, 1) --top left
	surface.DrawTexturedRectUV(0, height_half, width_half, height_half, 1, 1, 0, 0) --bottom left
	surface.DrawTexturedRectUV(width_half, height_half, width_half, height_half, 0, 1, 1, 0) --bottom right
end

local function end_fullbright() render.SetLightingMode(0) end
local function start_fullbright() render.SetLightingMode(1) end

local function toggle_fullbright(state)
	if state then
		hook.Add("HUDPaint", "WeepingAngelsVisibility", draw_fullbright)
		hook.Add("PreDrawHUD", "WeepingAngelsVisibility", end_fullbright)
		hook.Add("PreRender", "WeepingAngelsVisibility", start_fullbright)
		
		return
	end
	
	hook.Remove("HUDPaint", "WeepingAngelsVisibility")
	hook.Remove("PreDrawHUD", "WeepingAngelsVisibility")
	hook.Remove("PreRender", "WeepingAngelsVisibility")
end

--functions
function GM:VisibilityFullbright(key, state)
	if state ~= nil then registry[key] = state or nil
	else registry[key] = not registry[key] or nil end
	
	toggle_fullbright(next(registry) ~= nil)
end

--hooks
hook.Add("LocalPlayerChangedTeam", "WeepingAngelsVisibility", function(old_team)
	if old_team == TEAM_ANGEL then
		--more?
		hook.Run("VisibilityFullbright", "AngelPlayerClass", false)
	end
end)