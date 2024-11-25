function SongScript:StartScript()
	AudioMan:StopMusic()
	self.SongSelect = nil
	self.LastSong = nil
end

function SongScript:UpdateScript()
if not AudioMan:IsMusicPlaying() then
	self.SongSelect = math.random(8)

	if self.SongSelect == 1 then
		AudioMan:PlayMusic("spacemarines.rte/40kMusic/Music/W1.ogg",0,1)
		self.LastSong = 1
	--
	elseif self.SongSelect == 2 and self.LastSong ~= 2 then
		AudioMan:PlayMusic("spacemarines.rte/40kMusic/Music/W2.ogg",0,1)
		self.LastSong = 2
	--
	elseif self.SongSelect == 3 and self.LastSong ~= 3 then
		AudioMan:PlayMusic("spacemarines.rte/40kMusic/Music/W3.ogg",0,1)
		self.LastSong = 3
	--
	elseif self.SongSelect == 4 and self.LastSong ~= 4 then
		AudioMan:PlayMusic("spacemarines.rte/40kMusic/Music/W4.ogg",0,1)
		self.LastSong = 4
	--
	elseif self.SongSelect == 5 and self.LastSong ~= 5 then
		AudioMan:PlayMusic("spacemarines.rte/40kMusic/Music/W5.ogg",0,1)
		self.LastSong = 5
	--
	elseif self.SongSelect == 6 and self.LastSong ~= 6 then
		AudioMan:PlayMusic("spacemarines.rte/40kMusic/Music/W6.ogg",0,1)
		self.LastSong = 6
	--
	elseif self.SongSelect == 7 and self.LastSong ~= 7 then
		AudioMan:PlayMusic("spacemarines.rte/40kMusic/Music/W7.ogg",0,1)
		self.LastSong = 7
	--
	elseif self.SongSelect == 8 and self.LastSong ~= 8 then
		AudioMan:PlayMusic("spacemarines.rte/40kMusic/Music/W8.ogg",0,1)
		self.LastSong = 8
	elseif self.LastSong == 8 then
	self.SongSelect = 1
	end
end
end