
local _M = {}

function _M.mp4_meta_table(filename)
    opts = loadfile("options.lua")
    if opts then
        opts()
    end
    dofile("log.lua")
    dofile("mediasource.lua")
    framesProvider = mediaSource:createSource(filename)
    for frame in framesProvider:getFrames() do
        frame:dump()
    end
end

return _M
