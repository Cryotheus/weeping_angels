--locals
local player_meta = FindMetaTable("Player")

--globals
player_meta.GetNameX_WeepingAngels = player_meta.GetNameX_WeepingAngels or player_meta.GetName

--player meta functions
function player_meta:GetName() return self:GetNWString("PlayerName", self:GetNameX_WeepingAngels()) end
function player_meta:Name() return self:GetNWString("PlayerName", self:GetNameX_WeepingAngels()) end
function player_meta:Nick() return self:GetNWString("PlayerName", self:GetNameX_WeepingAngels()) end
function player_meta:SetName(name) self:SetNWString("PlayerName", name) end

function player_meta:Remove(reason)
	if CLIENT then ErrorNoHaltWithStack("Attempted to remove a player as a client.") return end
	
	self:Kick(reason)
end