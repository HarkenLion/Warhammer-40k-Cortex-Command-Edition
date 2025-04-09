function SongScript:StartScript()
	AudioMan:StopMusic();
	self.songSelect = nil;
	self.lastSong = nil;
end

function SongScript:UpdateScript()
	if not AudioMan:IsMusicPlaying() then
		self.songSelect = math.random(8);

		if self.songSelect == 1 then
			AudioMan:PlayMusic("SpaceMarines.rte/Music/W1.ogg", 0, 1);
			self.lastSong = 1;
		elseif self.songSelect == 2 and self.lastSong ~= 2 then
			AudioMan:PlayMusic("SpaceMarines.rte/Music/W2.ogg", 0, 1);
			self.lastSong = 2;
		elseif self.songSelect == 3 and self.lastSong ~= 3 then
			AudioMan:PlayMusic("SpaceMarines.rte/Music/W3.ogg", 0, 1);
			self.lastSong = 3;
		elseif self.songSelect == 4 and self.lastSong ~= 4 then
			AudioMan:PlayMusic("SpaceMarines.rte/Music/W4.ogg", 0, 1);
			self.lastSong = 4;
		elseif self.songSelect == 5 and self.lastSong ~= 5 then
			AudioMan:PlayMusic("SpaceMarines.rte/Music/W5.ogg", 0, 1);
			self.lastSong = 5;
		elseif self.songSelect == 6 and self.lastSong ~= 6 then
			AudioMan:PlayMusic("SpaceMarines.rte/Music/W6.ogg", 0, 1);
			self.lastSong = 6;
		elseif self.songSelect == 7 and self.lastSong ~= 7 then
			AudioMan:PlayMusic("SpaceMarines.rte/Music/W7.ogg", 0, 1);
			self.lastSong = 7;
		elseif self.songSelect == 8 and self.lastSong ~= 8 then
			AudioMan:PlayMusic("SpaceMarines.rte/Music/W8.ogg", 0, 1);
			self.lastSong = 8;
		elseif self.lastSong == 8 then
			self.songSelect = 1;
		end
	end
end