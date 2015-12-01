-- Main file
-- Usage lua main.lua <source>

local cjson = require "cjson"
local cjson2 = cjson.new()
local cjson_safe = require "cjson.safe"

opts = loadfile("options.lua")
if opts then opts() end

dofile("log.lua")
dofile("mediasource.lua")

args = args or {...}
s = args[1]

if not s then
	loge("no uri provided")
	os.exit(1)
end

framesProvider = mediaSource:createSource(s)

for frame in framesProvider:getFrames() do
--	frame:dump()
end

r = framesProvider:get_meta_table()

print(cjson_safe.encode(r))

--for _, v in pairs(r) do
--	for _, vi in pairs(v) do
--		print(vi)
--	end
--	print('------')
--end
