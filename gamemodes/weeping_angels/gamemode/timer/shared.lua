--gamemode functions
function GM:TimerGetActive() return self.TimerTarget and true or false end
function GM:TimerGetRemaining() return math.max(self:TimerGetTarget() - CurTime(), 0) end
function GM:TimerGetTarget() return self.TimerTarget or 0 end
function GM:TimerGetTargetRaw() return self.TimerTarget end