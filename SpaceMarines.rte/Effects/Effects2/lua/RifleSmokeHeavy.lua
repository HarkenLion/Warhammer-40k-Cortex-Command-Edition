function Create(self)
	local set = self.Vel * (20 * TimerMan.DeltaTimeSecs)

	for i = 1, 2 do
		eff = CreateMOSParticle("Longsmoke " .. math.random(2))
		eff.Pos = self.Pos - set
		eff.Vel = (self.Vel * 0.7) * math.random()
		MovableMan:AddParticle(eff)
	end

	eff = CreateMOSParticle("Side Thruster Blast Ball Tiny Short")
	eff.Pos = self.Pos - set
	eff.Vel = (self.Vel * 0.6) * math.random()
	MovableMan:AddParticle(eff)
end
