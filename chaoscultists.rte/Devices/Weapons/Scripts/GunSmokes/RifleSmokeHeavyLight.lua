function Create(self)
	local Effect
	local Offset = self.Vel * (20 * TimerMan.DeltaTimeSecs) -- the effect will be created the next frame so move it one frame backwards towards the barrel

	if PosRand() < 0.5 then
		Effect = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset
			Effect.Vel = self.Vel / 10
			MovableMan:AddParticle(Effect)
		end
	end
end
