local sourceLevels = {
    [0] = "decoder",
    "demuxer",
    "depacketizer",
    "datasource",
}

local _M = {
    level = 0,    -- level from sourceLevels
    uri = "",     -- uri
    content = "", -- content of this source
    source = nil, -- mediasource from lower level
}

function _M.get_meta_table(self)
    return self.source:get_meta_table()
end

function _M.getFrames(self)
    local currentSample = 0
    return function()
        currentSample = currentSample + 1
        return self:read(currentSample)
    end
end

function _M.parse(self)
    self.level = 3
    s, f = string.find(self.uri, "^.*://")
    if (s and f) then
        self.content = string.sub(string.sub(self.uri, string.find(self.uri, "^.*://")), 1, -4)
    else
        self.content = "file"
    end
    return true
end
-- MediaSource API end

function _M.new(self, o, s)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.uri = s
    return o
end

function _M.findModule(self, level, content)
    while level >= 0 do
        logi("loading: " .. level .. "::::" .. content)
        local f = loadfile("modules/" .. sourceLevels[level] .. "_" .. content .. ".lua")
        if not f then
            logw("no module found : " .. sourceLevels[level] .. "_" .. content .. ".lua")
            level = level - 1
        else
            logi("loading : " .. sourceLevels[level] .. "_" .. content)
            return f
        end
    end
end

function _M.createSource(self, filename)
    local state = {}
    local function getSource()
        local function iterator(state, source)
            state.source = source
            source:parse()
            local f = (source.level ~= 0) and source.content and string.len(source.content) > 0
            and self:findModule(source.level, source.content)
            if not f then
                return nil
            end
            local newsource = f()
            newsource = newsource and newsource.parse and self:new(newsource, filename)
            if not newsource then
                return nil
            end
            newsource.source, source = source, newsource
            return source
        end
        return iterator, state, self:new(nil, filename)
    end
    for source in getSource() do end
    return state.source
end

return _M
