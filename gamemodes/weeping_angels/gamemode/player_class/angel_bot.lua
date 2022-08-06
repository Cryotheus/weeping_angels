DEFINE_BASECLASS("player_angel")

--locals
local duck_mask = bit.bxor(2 ^ 32 - 1, IN_DUCK)
local PLAYER = table.Merge({DisplayName = "Weeping Angel Bot"}, BaseClass)

--player functions
function PLAYER:StartMove(move, command)
	local move_speed = self.RunSpeed
	local ply = self.Player
	
	move:SetMaxSpeed(move_speed)
	move:SetMaxClientSpeed(move_speed)
	ply:SetMaxSpeed(move_speed)
	
	if self:DoFreeze(ply, move, command) or CLIENT then return end
	
	local player_pos = ply:EyePos()
	local target = self.BotTarget
	local target_distance = math.huge
	local target_position
	
	if not IsValid(target) then --find a survivor
		for index, survivor in ipairs(WEEPING_ANGELS.PlayerTeamRosters[TEAM_SURVIVOR]) do
			local distance = survivor:EyePos():Distance(player_pos)
			
			if distance < target_distance then
				target = survivor
				target_distance = distance
			end
		end
		
		if not IsValid(target) then
			command:ClearButtons()
			move:SetButtons(0)
			
			return
		end
		
		self.BotTarget = target
		target_position = target:EyePos()
	else
		target_position = target:EyePos()
		target_distance = target:EyePos():Distance(player_pos)
	end
	
	local angles = (target_position - player_pos):Angle()
	
	command:SetViewAngles(angles)
	ply:SetEyeAngles(angles)
	move:SetMoveAngles(angles)
	
	if target_distance < 96 then
		command:ClearButtons()
		move:SetButtons(0)
		
		return
	end
	
	local new_buttons = bit.band(move:GetButtons(), duck_mask)
	
	command:SetButtons(new_buttons)
	move:SetButtons(new_buttons)
	
	command:AddKey(IN_SPEED)
	move:AddKey(IN_SPEED)
	
	command:SetForwardMove(move_speed)
	move:SetForwardSpeed(move_speed)
end

--post
player_manager.RegisterClass("player_angel_bot", PLAYER, "player_angel")

--debug
if CLIENT then return end

for index, bot in ipairs(player.GetBots()) do
	local bot_team = bot:Team()
	local position, angles = bot:GetPos(), bot:EyeAngles()
	
	bot:SetTeam(TEAM_SPECTATOR)
	bot:Spawn()
	
	bot:SetTeam(bot_team)
	bot:Spawn()
	bot:SetPos(position)
	bot:SetEyeAngles(angles)
end