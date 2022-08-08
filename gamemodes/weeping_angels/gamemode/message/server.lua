--locals
local color_error = GM.ColorError
local color_generic = GM.ColorGeneric
local color_significant = GM.ColorSignificant
local color_significant_border = GM.ColorSignificantBorder

--gamemode function
function GM:MessageConsole(first, ...)
	if istable(first) then MsgC(color_significant_border, "[", color_significant, "Weeping Angels", color_significant_border, "] ", first, ...)
	else MsgC(color_significant_border, "[", color_significant, "Weeping Angels", color_significant_border, "] ", color_generic, first, ...) end
end

function GM:MessageConsoleError(first, ...)
	if istable(first) then MsgC(color_significant_border, "[", color_significant, "Weeping Angels", color_significant_border, "] ", first, ...)
	else MsgC(color_significant_border, "[", color_significant, "Weeping Angels", color_significant_border, "] ", color_error, first, ...) end
end