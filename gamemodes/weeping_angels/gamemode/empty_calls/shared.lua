--function
local function empty_function() end

--post
for index, method in ipairs(GM.EmptyCalls) do GM[method] = empty_function end