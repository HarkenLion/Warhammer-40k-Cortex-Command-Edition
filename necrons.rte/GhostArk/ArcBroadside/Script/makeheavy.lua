function Create(self)
	self.Mass = 0.18
	self.Sharpness = 10

	local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
	local checkVect = self.Vel * velFactor
	local moid = SceneMan:CastMORay(self.Pos, checkVect, self.ID, 0, false, 0)
	if moid ~= 255 and moid ~= 0 then
		self.Mass = 2.25
		self.Sharpness = 13
	else
		self.Mass = 0.17
		self.Sharpness = 9
	end
end

function Update(self)
	local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
	local checkVect = self.Vel * velFactor
	local moid = SceneMan:CastMORay(self.Pos, checkVect, self.ID, 0, false, 0)
	if moid ~= 255 and moid ~= 0 then
		self.Mass = 2.15
		self.Sharpness = 11
	else
		self.Mass = 0.16
		self.Sharpness = 9
	end
end
