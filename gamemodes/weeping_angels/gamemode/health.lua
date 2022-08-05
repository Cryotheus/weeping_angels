--local functions
local function health_percentage(health, max_health)
	local precent = math.Round(health / max_health * 100)
	
	if health < max_health and precent == 100 then return "99%"
	elseif precent == 0 and health > 0 then return "1%"
	else return precent .. "%" end
end

--globals
GM._HealthPrecentage = health_percentage