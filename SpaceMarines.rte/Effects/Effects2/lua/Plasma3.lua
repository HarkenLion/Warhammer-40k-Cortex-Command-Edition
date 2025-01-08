function Update(self)
	local Effect
	local Offset = self.Vel * (15 * TimerMan.DeltaTimeSecs)

	local trailLength = math.floor(Offset.Magnitude + 0.5)
	for i = 1, trailLength, 6 do
		Effect = CreateMOPixel("Plasma Trail Glow B " .. math.random(2), "Untitled.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset * (i / trailLength) + Vector(RangeRand(-1.5, 1.5), RangeRand(-1.5, 1.5))
			Effect.Vel = self.Vel * RangeRand(0.9, 1.0)
			Effect.Lifetime = Effect.Lifetime + (math.random(100))
			Effect.Team = self.Team
			Effect.IgnoresTeamHits = true
			MovableMan:AddParticle(Effect)
		end
	end
end
