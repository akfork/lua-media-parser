require 'include/ftyp'

do
	local sampleTableParsing = false

	-- moov trak mdia minf stbl

	local mp4 = {
		sampleTable = {
			sampleSizes = {},
			chunks = {},
			chunkOffsets = {},
		}
	}

	function mp4:read(sample)
		-- must be an iterator
		if self.samplesCount
			and self.samplesCount > 0
			and sample >= 0
			and sample < self.samplesCount then

			local samples = 0
			local currentChunk = 0
			local samplesInCurrentChunk = 0
			while samples < sample do
				-- get samples for current chunk
				currentChunk = currentChunk + 1
				for var = 1, table.getn(self.sampleTable.chunks) do
					if self.sampleTable.chunks[var].firstChunk <= currentChunk
						and (var == table.getn(self.sampleTable.chunks)
						or self.sampleTable.chunks[var+1].firstChunk > currentChunk) then

						samplesInCurrentChunk = self.sampleTable.chunks[var].samplesPerChunk
						samples = samples + self.sampleTable.chunks[var].samplesPerChunk
						break
					end
				end
			end
			local sampleInChunk = samplesInCurrentChunk - (samples - sample)
			local chunkOffset = self.sampleTable.chunkOffsets[currentChunk]
			-- sum of all chunk samples
			local offsetInChunk = 0
			local currentChunkSample = samples - samplesInCurrentChunk + 1
			while currentChunkSample < sample do
				offsetInChunk = offsetInChunk + self.sampleTable.sampleSizes[currentChunkSample]
				currentChunkSample = currentChunkSample + 1
			end
			local fullOffset = chunkOffset + offsetInChunk
			self.source:seek(fullOffset)
			if verbose >= 2 then
				logi("offset :" .. tostring(fullOffset))
			end
			return self.source.fh
		end
	end

	function mp4:open()
		self.source:open()
	end

	function mp4:close()
		self.source:close()
	end

	function mp4:parseChunk(level)
		local size = convertToSize(self.source:read(4))
		local atom = self.source:read(4)
		if not size or not atom then
			return false
		end
		if atom ~= "moov"
			and atom ~= "trak"
			and atom ~= "mdia"
			and atom ~= "minf"
			and atom ~= "stbl" then

			local parsed = false
			if atom == "stsd" then
				self.source:seek(8) -- go to mp4v/avc1
				parsed = true
			end
			if atom == "mp4v" then
				self.content = "mpeg4"
				sampleTableParsing = true
			end
			if atom == "avc1" then
				self.content = "avc"
				sampleTableParsing = true
				self.source:seek(78) -- go to avcC
				parsed = true
			end
			if atom == "avcC" then
				self.source:seek(4)
				self.nalLength = 1 + bit.band(convertToSize(self.source:read(1)), 3)
				self.source:seek(size - 13)
				parsed = true
			end
			if sampleTableParsing then
				if atom == "stsz" and size > 20 then
					-- sample sizes
					self.source:seek(4) -- flags and version
					self.source:seek(4) -- sample size, usually 0
					self.samplesCount = convertToSize(self.source:read(4))
					for var = 1, self.samplesCount do
						self.sampleTable.sampleSizes[var] = convertToSize(self.source:read(4))
					end
					parsed = true
				end
				if atom == "stsc" then
					-- sample to chunks entries
					self.source:seek(4)
					local entries = convertToSize(self.source:read(4))
					for var = 1, entries do
						self.sampleTable.chunks[var] = {
							firstChunk = convertToSize(self.source:read(4)),
							samplesPerChunk = convertToSize(self.source:read(4)),
						}
						self.source:read(4)
					end
					parsed = true
				end
				if atom == "stco" or atom == "co64" then
					-- sample to chunks offset
					self.source:seek(4)
					local entries = convertToSize(self.source:read(4))
					for var = 1, entries do
						local offset
						if atom == "stco" then
							offset = convertToSize(self.source:read(4))
						else
							offset = convertToSize(self.source:read(8))
						end
						self.sampleTable.chunkOffsets[var] = offset
					end
					parsed = true
				end
			end
			if not parsed then
				self.source:seek(size - 8)
			end
		end
		if atom == "stbl" then
			sampleTableParsing = false
		end
		if verbose >= 1 then
			print(level, atom, size)
		end
		
		return self:parseChunk(level)
	end

	function mp4:parse()
		self.level = 1
		self.source:open()
		self:parseChunk(0)
		self.source:close()
	end

	function mp4:dump()
		
	end

	return mp4
end
