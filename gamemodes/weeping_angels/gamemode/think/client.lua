--globals
GM.ThinkAngel = GM.PlayerVisibilityThinkAngel

--gamemode hooks
function GM:Think()
	local cur_time = CurTime()
	
	self:ThinkShared(cur_time)
	self:ThinkTeams()
end

--function GM:ThinkAngel(ply, cur_time, survivors, angels) end --called by ThinkShared, replaced with PlayerVisibilityThinkAngel
function GM:ThinkSurvivor(_ply, _cur_time, _survivors, _angels) end --called by ThinkShared