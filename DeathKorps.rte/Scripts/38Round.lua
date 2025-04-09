function Create(self)
	local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
	local checkVect = self.Vel * velFactor
	local moid = SceneMan:CastMORay(self.Pos, checkVect, self.ID, self.Team, 0, false, 0)

	if moid ~= 255 and moid ~= 0 then
		self.ToDelete = true
	end
end

function ThreadedUpdate(self)
	local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
	local checkVect = self.Vel * velFactor
	local moid = SceneMan:CastMORay(self.Pos, checkVect, self.ID, self.Team, 0, false, 0)

	if moid ~= 255 and moid ~= 0 then
		self.ToDelete = true
	end
end
