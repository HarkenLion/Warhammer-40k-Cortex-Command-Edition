function Update(self)
	--[[
	local smoke = CreateMOSParticle("Tiny Smoke Ball 1");
	smoke.Pos = self.Pos;
	smoke.Lifetime = smoke.Lifetime - math.random(200);
	smoke.Vel = self.Vel * math.random();
	smoke.Team = self.Team;
	smoke.IgnoresTeamHits = true;
	MovableMan:AddParticle(smoke);
]]
	--
	local Effect
	local Offset = self.Vel * (15 * TimerMan.DeltaTimeSecs)

	local trailLength = math.floor(Offset.Magnitude + 0.5)
	for i = 1, trailLength, 6 do
		Effect = CreateMOPixel("(CH3)3CLi Trail " .. math.random(3), "Untitled.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset * (i / trailLength) + Vector(RangeRand(-0.5, 0.5), RangeRand(-0.5, 0.5))
			Effect.Vel = self.Vel * RangeRand(0.9, 1.0)
			Effect.Team = self.Team
			Effect.IgnoresTeamHits = true
			MovableMan:AddParticle(Effect)
		end
	end
end
