if CLIENT then ENT.Base = "base_point" return end

ENT.Base = "base_nextbot"

--locals
local total_area_count = navmesh.GetNavAreaCount()

--local functions
local function get_random_area_center()
	local area
	local human = player.GetHumans()[1]
	
	if IsValid(human) then
		area = navmesh.GetNearestNavArea(
			human:GetPos(),
			false,
			65536,
			false,
			true,
			-2 --TEAM_ANY
		)
	else area = navmesh.GetNavAreaByID(math.random(total_area_count)) end
	
	return area:GetCenter()
end

--entity functions
function ENT:CurrentBehavior() return "Wander" end

function ENT:FindViewer() --fetch the list of players who see the bot and use the closest one
	local bot = self.Bot
	local visibility_viewers = GAMEMODE.PlayerVisibilityViewers[bot]
	
	if visibility_viewers then
		local bot_pos = bot:GetPos()
		local record = math.huge
		local victim
		
		for index, ply in ipairs(visibility_viewers) do
			local distance = ply:GetPos():Distance(bot_pos)
			
			if distance < record then
				record = distance
				victim = ply
			end
		end
		
		return victim
	end
	
	return false
end

function ENT:HandleStuck()
	print(self, "got stuck")
end

function ENT:Initialize()
	self:SetModel("models/player.mdl")
	self:SetNoDraw(true)
	self:SetSolid(SOLID_NONE)
end

function ENT:MoveToPos(pos, options)
	local options = options or {}
	local path = Path("Follow")
	
	path:SetMinLookAheadDistance(options.lookahead or 300)
	path:SetGoalTolerance(options.tolerance or 20)
	path:Compute(self, pos)
	
	if not path:IsValid() then return "failed" end
	
	while path:IsValid() do
		local locomotion = self.loco
		
		path:Update(self.Bot)
		
		if locomotion:IsStuck() then
			self:HandleStuck()
			
			return "stuck"
		end
		
		if options.maxage and path:GetAge() > options.maxage then return "timeout" end
		if options.repath and path:GetAge() > options.repath then path:Compute(self, pos) end
		
		coroutine.yield()
	end
	
	return "ok"
end

function ENT:RunBehaviour()
	local limit = 100
	local attempts = false
	
	while true do
		local control, time_override = self:CurrentBehavior(self.Bot, self.TargetPlayer)
		
		--set the next run time
		if isnumber(control) then time_override = control
		elseif isstring(control) then --set the new behavior
			self:SetCurrentBehavior(control)
			
			if attempts then
				if attempts > limit then
					print("delaying behavior to stop server crash!")
					coroutine.wait(math.max(time_override or 0, 5))
				else attempts = attempts + 1 end
			else attempts = 1 end
		else
			if attempts then
				if attempts > limit then print("behavior restored") end
				
				attempts = false
			end
			
			coroutine.wait(time_override or 5)
		end
	end
end

function ENT:SetBot(bot) self.Bot = bot end

function ENT:SetCurrentBehavior(key)
	local method = self["Run" .. key]
	
	print("updating behavior to " .. key .. " for " .. tostring(self.Bot))
	
	if isfunction(method) then self.CurrentBehavior = method end
end

function ENT:Think()
	local bot = self.Bot
	
	if IsValid(bot) and bot.Driver == self and bot:Team() == TEAM_ANGEL then
		if bot:IsInWorld() then self:SetPos(bot:GetPos()) end	
		
		return
	end
	
	self.Think = nil
	
	print(self, "driver suicided!")
	self:Remove()
end

function ENT:RunChase(_bot, _target_player)
	local viewer = self.TargetPlayer
	
	if not IsValid(viewer) or viewer:Team() ~= TEAM_SURVIVOR then
		self.TargetPlayer = nil
		
		return "Wander"
	end
	
	
end

--function ENT:RunEscape(bot) end

function ENT:RunWander(bot)
	local pather = self.Pather or Path("Follow")
	local viewer = self:FindViewer()
	
	if viewer then --we found someone, go and get them
		self.TargetPlayer = viewer
		
		return "Chase"
	end
	
	local wander_target = self.WanderTarget
	
	if not wander_target or not pather:IsValid() then --compute >:D
		wander_target = get_random_area_center()
		self.WanderTarget = wander_target
		
		pather:Compute(bot, wander_target)
		
		if not pather:IsValid() then ErrorNoHalt("Pather failed.", bot) return end
	end
	
	if bot:GetPos():Distance(wander_target) < 24 then --reached the goal?
		self.WanderTarget = nil
		
		return
	end
	
	bot.MoveTarget = pather:GetClosestPosition(bot:GetPos())
	
	print(pather, #pather:GetAllSegments())
	pather:Update(bot)
	
	return 0.1
end

function ENT:UpdateTransmitState() return TRANSMIT_NEVER end

--[[

function GM:NextbotAngelThink(ply, _cur_time, survivors, _angels)
	--local path_chase = ply.PathChase
	local path_follower = ply.PathFollow
	
	self:NextbotAngelWander(ply, path_follower, survivors)
end

function GM:NextbotAngelWander(ply, path_follower, survivors)
	local wander_target = ply.WanderTarget or self:NextbotAngelWanderGet(ply, path_follower)
	
	if not wander_target then return ErrorNoHalt("Unable to make a path for a nextbot.") end
	
	--if we're at our target, make a new target
	if ply:GetPos():Distance(wander_target) < 100 then wander_target = self:NextbotAngelWanderGet(ply, path_follower, survivors) end
	
	path_follower:Update(ply)
end

function GM:NextbotAngelWanderGet(ply, path_follower, survivors)
	local random_area = navmesh.GetNavAreaByID(math.random(total_area_count))
	
	if not IsValid(random_area) then return false end
	
	local wander_target = random_area:GetCenter()
	ply.WanderTarget = wander_target
	
	path_follower:Compute(ply, Entity(1):GetPos())
	
	return wander_target
end
]]