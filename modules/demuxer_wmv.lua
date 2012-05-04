require 'include/ftyp'

do
	local wmv = {}

	local GUIDTypes = {
		
		["\048\038\178\117\142\102\207\017\166\217\000\170\000\098\206\108"] = "ASF file",
		["\054\038\178\117\142\102\207\017\166\217\000\170\000\098\206\108"] = "data",
	}

	function wmv:read(sample)
		
	end

	function wmv:open()
		self.source:open()
	end

	function wmv:close()
		self.source:close()
	end

	function wmv:parseChunk(level)
		-- 16 bytes is a GUID
		local guid = self.source:read(16)
		if not guid then
			return false
		end
		print(GUIDTypes[guid])
		-- 8 bytes size in le
		local sizeStr = ""
		for val = 1,8 do
			sizeStr = self.source:read(1) .. sizeStr
		end
		local size = convertToSize(sizeStr)
		print(size)
		self.source:seek(size - 24)
		return self:parseChunk(level)
	end

	function wmv:parse()
		self.level = 1
		self.source:open()
		self:parseChunk(0)
		self.source:close()
	end

	return wmv
end
