function Update(self)
	--[[
	local eff = CreateMOSParticle("Shortsmoke 1", "Untitled.rte");
	eff.Pos = self.Pos;
	eff.Vel = Vector(1,0):RadRotate(math.random()*(math.pi*2)) + (self.Vel * 0.20);
	eff.Lifetime = eff.Lifetime + math.random(80);
	MovableMan:AddParticle(eff);
]]
	--
	local Effect
	local Offset = self.Vel * (20 * TimerMan.DeltaTimeSecs) -- the effect will be created the next frame so move it one frame backwards towards the barrel

	local trailLength = math.floor(Offset.Magnitude + 0.5)
	for i = 1, trailLength, 6 do
		Effect = CreateMOSParticle("Shortsmoke 1", "Untitled.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset * (i / trailLength) + Vector(RangeRand(-1.3, 1.3), RangeRand(-1.3, 1.3))
			Effect.Vel = self.Vel * RangeRand(0.6, 0.8)
			Effect.Lifetime = Effect.Lifetime + math.random(100)
			MovableMan:AddParticle(Effect)
		end
	end
end
