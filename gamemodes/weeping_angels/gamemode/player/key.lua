--locals
local jump_power = 195
local local_voicing = false
local speed_jump_power = jump_power * 2
local voicing = false

--gamemode hooks
function GM:KeyPress(ply, key) return self:TeamRunMethod(ply, "KeyPress", key) end
function GM:KeyRelease(ply, key) return self:TeamRunMethod(ply, "KeyRelease", key) end

function GM:PlayerBindPress(ply, bind, pressed)
	if ply:Team() ~= TEAM_SURVIVOR then return end
	
	local interrupt
	
	if bind == "+voicerecord" then
		interrupt = true
		voicing = pressed
	elseif bind == "+speed" then
		interrupt = true
		local_voicing = pressed
	end
	
	if interrupt then
		permissions.EnableVoiceChat(local_voicing or voicing)
		
		return true
	end
end

--hooks
hook.Add("LocalPlayerChangedTeam", "WeepingAngelsPlayerKey", function(old)
	if old == TEAM_SURVIVOR then
		local_voicing = false
		
		ply:SetLocalChatting(false)
		
		if voicing then voicing = false
		else permissions.EnableVoiceChat(false) end
	end
end)

--post
GM:TeamRegisterMethod(TEAM_ANGEL, "KeyPress", function(ply, key) if key == IN_SPEED then ply:SetJumpPower(speed_jump_power) end end)
GM:TeamRegisterMethod(TEAM_ANGEL, "KeyRelease", function(ply, key) if key == IN_SPEED then ply:SetJumpPower(jump_power) end end)

if CLIENT then return end

GM:TeamRegisterMethod(TEAM_SURVIVOR, "KeyPress", function(ply, key) if key == IN_SPEED then ply:SetLocalChatting(true) end end)
GM:TeamRegisterMethod(TEAM_SURVIVOR, "KeyRelease", function(ply, key) if key == IN_SPEED then ply:SetLocalChatting(false) end end)