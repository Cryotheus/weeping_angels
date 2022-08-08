include("shared.lua")

SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Slot = 5
SWEP.SlotPos = 6
SWEP.WepSelectIcon = surface.GetTextureID("vgui/gmod_tool")

--locals
local font = "DermaDefault"
local font_action = "Trebuchet24"
local font_large = "DermaLarge"
local margin = 4
local margin_double = margin * 2
local margin_outline = margin_double + 2
local render_target = GetRenderTarget("GModToolgunScreen", 256, 256)
local screen_material = Material("models/weapons/v_toolgun/screen")
local wa_toolmode = CreateClientConVar("wa_toolmode", "zone", true, true, "The Weeping Angels Gamemode's version of gmod_tool. Used for admins in build mode.")

--local functions
local function png_texture_id(path) return surface.GetTextureID("!" .. Material(path):GetTexture("$basetexture"):GetName()) end

local texture_background = png_texture_id("gui/dupe_bg.png")
local material_gradient_down = Material("gui/gradient_down")
local material_gradient_up = Material("gui/gradient_up")
local texture_primary = png_texture_id("gui/lmb.png")
local texture_secondary = png_texture_id("gui/rmb.png")
local texture_special = png_texture_id("gui/r.png")

--swep functions
function SWEP:DrawHUD()
	local mode = self:GetMode()
	
	surface.SetFont(font)
	
	local text_width, text_height = surface.GetTextSize(mode)
	
	--draw a background that encompasses the text
	surface.SetDrawColor(0, 0, 0, 128)
	surface.DrawRect(0, 0, text_width + margin_double, text_height + margin_double)
	
	surface.SetDrawColor(255, 255, 255, 128)
	surface.DrawOutlinedRect(-1, -1, text_width + margin_outline, text_height + margin_outline, 1)
	
	--draw what mode we are in
	draw.SimpleTextOutlined(mode, font, margin, margin, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 1, color_black)
end

function SWEP:GetMode()
	local mode = wa_toolmode:GetString()
	
	return mode == "" and "none" or mode
end

function SWEP:RenderScreen()
	local mode = self:GetMode()
	
	screen_material:SetTexture("$basetexture", render_target)
	
	local valid_actions = {
		{texture_primary, "Primary"},
		{texture_secondary, "Secondary"},
		{texture_special, "Special"}
	}
	
	local valid_count = #valid_actions
	local valid_size = 20 * valid_count
	local valid_size_gradient = valid_size * 2.5
	local valid_y = 248 - valid_size
	local valid_y_gradient = 256 - valid_size_gradient
	
	-- Set up our view for drawing to the texture
	render.PushRenderTarget(render_target)
		cam.Start2D()
			do --background
				render.Clear(0, 0, 0, 0, true, true)
				surface.SetDrawColor(255, 255, 255)
				surface.SetTexture(texture_background)
				surface.DrawTexturedRect(0, 0, 256, 256)
			end
			
			do --header
				surface.SetDrawColor(0, 0, 0, 255)
				surface.DrawRect(0, 0, 256, 24)
				
				surface.SetMaterial(material_gradient_down)
				surface.DrawTexturedRect(0, 0, 256, 128)
				surface.DrawTexturedRect(0, 24, 256, 96)
				surface.DrawTexturedRect(0, 24, 256, 64)
				
				draw.SimpleText(mode, font_large, 128, 8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
			end
			
			do --footer
				surface.SetMaterial(material_gradient_up)
				surface.DrawTexturedRect(0, valid_y_gradient, 256, valid_size_gradient)
				surface.DrawTexturedRect(0, valid_y_gradient, 256, valid_size_gradient)
				
				surface.SetDrawColor(255, 255, 255)
				surface.SetFont(font_action)
				
				for index, action in ipairs(valid_actions) do
					local text = action[2]
					local text_width = surface.GetTextSize(text)
					local y = valid_y + index * 20
					
					draw.SimpleText(text, font_action, 128, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
					surface.SetTexture(action[1])
					surface.DrawTexturedRect(128 - text_width * 0.5 - 20, y - 18, 16, 16)
				end
			end
		cam.End2D()
	render.PopRenderTarget()
end

--post
screen_material:SetTexture("$basetexture", render_target)

--hooks
hook.Remove("HUDPaint", "test")