--locals
local player_bits = math.ceil(math.log(game.MaxPlayers(), 2))

--local functions
local function read_player() return Entity(net.ReadUInt(player_bits)) end
local function write_player(ply) net.WriteUInt(ply:EntIndex() - 1, player_bits) end

--globals
WEEPING_ANGELS._NetReadPlayer = read_player
WEEPING_ANGELS._NetWritePlayer = write_player