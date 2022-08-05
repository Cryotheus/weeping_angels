util.AddNetworkString("weeping_angels")

--locals
local initialized_players = WEEPING_ANGELS.NetPlayersInitialized or {}
local player_screen_heights = WEEPING_ANGELS.NetPlayerHeights or {}
local player_screen_widths = WEEPING_ANGELS.NetPlayerWidths or {}

--globals
WEEPING_ANGELS.NetPlayersInitialized = initialized_players
WEEPING_ANGELS.NetPlayerHeights = player_screen_heights
WEEPING_ANGELS.NetPlayerWidths = player_screen_widths

--gamemode hooks
function GM:PlayerDisconnected(ply)
	initialized_players[ply] = nil
	player_screen_heights[ply] = nil
	player_screen_widths[ply] = nil
	
	net.Start("weeping_angels")
	net.WriteEntity(ply) --we don't use the write_player function because we need its creation id
	net.Broadcast()
end

function GM:PlayerFinishLoad(ply) initialized_players[ply] = true end

--hooks
hook.Add("PlayerInitialSpawn", "WeepingAngelsNet", function(ply) initialized_players[ply] = false end)

--net
net.Receive("weeping_angels", function(_length, ply)
	player_screen_heights[ply] = net.ReadUInt(14)
	player_screen_widths[ply] = net.ReadUInt(14)
	
	--nil: invalid player
	--false: PlayerFinishLoad has yet to run
	--true: PlayerFinishLoad already ran
	if initialized_players[ply] == false then hook.Run("PlayerFinishLoad", ply) end
end)