function Create(self)
	local set = self.Vel * (20 * TimerMan.DeltaTimeSecs)

	for i = 1, 2 do
		local eff = CreateMOSParticle("Shortsmoke 1")
		eff.Pos = self.Pos - set
		eff.Vel = (self.Vel * 0.7) * math.random()
		MovableMan:AddParticle(eff)
	end
end
