require 'include/bit'
require 'include/ftyp'

do
    local _M = {}

    function _M.parse(self)
        self.level = 0
    end

    function _M.read(self, sample)
        -- returns frame data
        local result = frame:new()
        result.description = "-------"

        self.source:open()
        local extradata = ""
        framepointer, extradata = self.source:read(sample)
        if not framepointer then
            self.source:close()
            return nil
        end

        -- hack: framepointer is an file descriptor
        local header = framepointer:read(4)
        local expectVOP = "\000\000\001\182"
        local expectGOP = "\000\000\001\179"
        if header == expectVOP then
            local frametype = convertToSize(framepointer:read(1))
            frametype = bit.blogic_rshift(frametype, 6)
            if frametype == 0 then
                result.description = "  I frame"
            end
            if frametype == 1 then
                result.description = "  P frame"
            end
            if frametype == 2 then
                result.description = "  B frame"
            end
            if frametype == 3 then
                result.description = "  S frame"
            end
            if extradata then
                result.description = result.description .. extradata
            end
        else
            if header == expectGOP then
                result.description = " GOP header"
            end
        end

        self.source:close()
        return result
    end

    return _M
end
