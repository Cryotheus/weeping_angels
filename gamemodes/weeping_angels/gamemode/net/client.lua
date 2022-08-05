--gamemode functions
function GM:NetSendInitialization()
	net.Start("weeping_angels")
	net.WriteUInt(ScrH(), 14)
	net.WriteUInt(ScrW(), 14)
	net.SendToServer()
end

--gamemode hooks
function GM:InitPostEntity() self:NetSendInitialization() end
function GM:OnScreenSizeChanged() self:NetSendInitialization() end

--net
net.Receive("weeping_angels", function() hook.Run("PlayerDisconnected", net.ReadEntity()) end)