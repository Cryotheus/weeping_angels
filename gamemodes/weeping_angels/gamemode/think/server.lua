--gamemode hooks
function GM:Think()
	local cur_time = CurTime()
	
	self:ThinkShared(cur_time)
	self:ThinkDamage(cur_time)
end

function GM:ThinkAngel(ply, cur_time, survivors, angels) --called by ThinkShared
	self:PlayerVisibilityThinkAngel(angel, _cur_time, survivors)
	self:PlayerAngelThink(ply, cur_time, survivors, angels)
	
	if ply:IsBot() then self:NextbotThinkAngel(ply, cur_time, survivors, angels) end
end

function GM:ThinkSurvivor(ply, cur_time, survivors, angels) --called by ThinkShared
	self:ThinkSurvivorDamage(ply, cur_time)
	self:ThinkSurvivorFall(ply, cur_time)
	
	if ply:IsBot() then self:NextbotThinkSurvivor(ply, cur_time, survivors, angels) end
end