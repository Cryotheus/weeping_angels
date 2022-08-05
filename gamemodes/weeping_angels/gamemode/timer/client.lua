--gamemode functions
function GM:TimerSetTarget(target_time) self.TimerTarget = target_time or nil end

--net
net.Receive("weeping_angels_time", function() GAMEMODE:TimerSetTarget(net.ReadBool() and net.ReadFloat()) end)