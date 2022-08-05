util.AddNetworkString("weeping_angels_time")

--local functions
local function send_target_time(ply)
	local target_time = GAMEMODE.TimerTarget
	
	net.Start("weeping_angels_time")
	net.WriteBool(target_time and true or false)
	
	if target_time then net.WriteFloat(target_time) end
	
	--send for new players, or broadcast to everyone
	if ply then net.Send(ply)
	else net.Broadcast() end
end

local function timer_think()
	if CurTime() > GAMEMODE.TimerTarget then
		hook.Remove("Think", "WeepingAngelsTimer")
		hook.Run("TimerLapsed")
	end
end

--gamemode functions
function GM:TimerSetTarget(target_time)
	self.TimerTarget = target_time or nil
	
	hook.Add("Think", "WeepingAngelsTimer", timer_think)
	send_target_time()
end

--gamemode hooks
function GM:TimerLapsed() end

--hooks
hook.Add("PlayerFinishLoad", "WeepingAngelsTimer", send_target_time)

