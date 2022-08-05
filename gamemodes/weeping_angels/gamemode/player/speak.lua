--locals
local voice_events = GM.PlayerSpeakVoiceEvents or {}

--local tables
local female_overrides = table.Merge(WEEPING_ANGELS.FemaleOverrides or {}, {
	["models/player/alyx.mdl"] = true,
	["models/player/mossman.mdl"] = true,
	["models/player/mossman_arctic.mdl"] = true,
	["models/player/p2_chell.mdl"] = true
})

--globals
GM.PlayerSpeakVoiceEvents = voice_events
WEEPING_ANGELS.FemaleOverrides = female_overrides

--gamemode functions
function GM:PlayerSpeak(ply, key)
	--TODO: smell event!
	local model = ply:GetModel()
	local is_female = female_overrides[model]
	
	--cache the sex if we have to solve for it
	if is_female == nil then
		is_female = string.find(model, "female") and true or false
		female_overrides[model] = is_female
	end
	
	local voice_lines = voice_events[key]
	local line = voice_lines[math.random(voice_lines.Count)]
	
	ply:EmitSound((is_female and "vo/npc/female01/" or "vo/npc/male01/") .. line .. ".wav", 65, 100, 1, CHAN_VOICE)
end

function GM:PlayerSpeakRegister(key, ...)
	local voice_lines = voice_events[key]
	
	--create and cache if it doesn't already exist
	if not voice_lines then
		voice_lines = {}
		voice_events[key] = voice_lines
	end
	
	--insert strings, and entries of tables into the existing
	for index, voice_line in ipairs{...} do
		if istable(voice_line) then table.Add(voice_lines, voice_line)
		else table.insert(voice_lines, voice_line) end
	end
	
	voice_lines.Count = #voice_lines
end

--post
GM:PlayerSpeakRegister("Moan", "moan01", "moan02", "moan03", "moan04", "moan05")

--punching an angel
GM:PlayerSpeakRegister("PainfulPunch", "myarm01", "myarm02", "ow01", "ow02", "pain02", "pain03", "pain06")

--after punching an angel
GM:PlayerSpeakRegister("AdmireBloodyFists", "answer03", "answer12", "answer15", "answer22", "answer36", "answer40", "evenodds", "fantastic01", "goodgod",
	"moan01", "moan02", "moan03", "moan04", "moan05", "nice", "ohno", "question02", "question05", "question10", "question11", "question16", "question17",
	"question18", "thislldonicely01", "vanswer02", "vanswer14", "yeah02")