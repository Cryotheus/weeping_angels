include("loader.lua")
RunConsoleCommand("gmod_maxammo", 0)

--debug
concommand.Add("qc", function() game.CleanUpMap() end, nil, "Debug command, cleans up the map.")
concommand.Add("qr", function() RunConsoleCommand("changelevel", game.GetMap()) end, nil, "Debug command, reloads the map.")