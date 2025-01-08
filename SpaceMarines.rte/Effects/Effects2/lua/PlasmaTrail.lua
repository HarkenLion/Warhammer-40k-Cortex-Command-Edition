function Update(self)
	local Effect
	local Offset = self.Vel * (15 * TimerMan.DeltaTimeSecs)

	local trailLength = math.floor(Offset.Magnitude + 0.5)
	for i = 1, trailLength, 5 do
		Effect = CreateMOSParticle("Plasma Trail Puff " .. math.random(3), "Untitled.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset * (i / trailLength) + Vector(RangeRand(-2, 2), RangeRand(-2, 2))
			Effect.Vel = self.Vel * RangeRand(0.0, 0.2)
				+ Vector(math.random() * 2, 0):RadRotate(math.random() * (math.pi * 2))
			MovableMan:AddParticle(Effect)
		end
	end
end
