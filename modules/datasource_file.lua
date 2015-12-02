
do
	local _M = {}

	function _M.open(self)
		self.fh = io.open(self.uri, "rb")
		return self.fh
	end

	function _M.close(self)
		if self.fh then
			self.fh:close()
		end
	end

	function _M.read(self, bytes)
		if self.fh and bytes ~= 0  then
			return self.fh:read(bytes)
		end
	end

	function _M.seek(self, bytes)
		if self.fh then
			if bytes and bytes ~= 0 then
				self:read(bytes)
			else
				return self.fh:seek()
			end
		end
	end

	function _M.parse(self)
		self.level = 3
		if string.find(self.uri, "%.%w+$") then
			self.content = string.sub(string.sub(self.uri, string.find(self.uri, "%.%w+$")), 2)
		end
	end

	return _M
end
