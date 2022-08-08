DEFINE_BASECLASS("player_angel")

--locals
local duck_mask = bit.bxor(2 ^ 32 - 1, IN_DUCK)
local PLAYER = table.Merge({DisplayName = "Weeping Angel Bot"}, BaseClass)

--player functions
function PLAYER:Spawn()
	local driver = self.Driver
	
	if IsValid(driver) then return end
	
	local ply = self.Player
	driver = ents.Create("wa_angel_driver")
	
	driver:SetPos(ply:GetPos())
	driver:Spawn()
	driver:SetBot(ply)
	
	ply.Driver = driver
end

function PLAYER:SetMoveSpeed(ply, move, speed)
	move:SetMaxSpeed(speed)
	move:SetMaxClientSpeed(speed)
	ply:SetMaxSpeed(speed)
end

function PLAYER:StartMove(move, command)
	local move_speed = self.RunSpeed
	local ply = self.Player
	
	self:SetMoveSpeed(ply, move, move_speed)
	
	if self:DoFreeze(ply, move, command) or CLIENT then return end
	
	local target_position = ply.MoveTarget
	
	if isvector(target_position) then --debug behavior
		local player_pos = ply:EyePos()
		local target = self.BotTarget
		local target_distance = target_position:Distance(player_pos)
		
		local angles = (target_position - player_pos):Angle()
		
		self:SetMoveSpeed(ply, move, target_distance)
		
		command:SetViewAngles(angles)
		ply:SetEyeAngles(angles)
		move:SetMoveAngles(angles)
		
		--[[
		if target_distance < 96 then
			command:ClearButtons()
			move:SetButtons(0)
			
			return
		end]]
		
		local new_buttons = bit.band(move:GetButtons(), duck_mask)
		
		command:SetButtons(new_buttons)
		move:SetButtons(new_buttons)
		
		command:AddKey(IN_SPEED)
		move:AddKey(IN_SPEED)
		
		command:SetForwardMove(move_speed)
		move:SetForwardSpeed(move_speed)
	end
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