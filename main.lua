-- Main file
-- Usage lua main.lua <source>

local cjson_safe = require "cjson.safe"

verbose = 3
loglevel = 0

local createLog = function(c, level)
	fstr = "function log"
		.. c
		.. "(message) if loglevel >= "
		.. level
		.. " then print(\""
		.. string.upper(c)
		.. " : \" .. message) end end"
	newlog = loadstring(fstr)
	newlog()
end

createLog("e", 0)
createLog("w", 1)
createLog("i", 2)

local mediaSource = require "mediasource"

local framesProvider = mediaSource:createSource("mpeg4conformance.mp4")

for frame in framesProvider:getFrames() do
    --frame:dump()
end

local r = framesProvider:get_meta_table()

print(cjson_safe.encode(r))

--for _, v in pairs(r) do
--	for _, vi in pairs(v) do
--		print(vi)
--	end
--	print('------')
--end
