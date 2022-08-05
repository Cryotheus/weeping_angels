--local tables
local empty_calls = {
	"PlayerAngelFreeze",
	"PlayerSpeak",
	"PlayerSpeakRegister"
}

--local functions
local function empty_call() end

--post
for index, method in ipairs(empty_calls) do GM[method] = empty_call end