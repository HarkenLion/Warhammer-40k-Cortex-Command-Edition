function Create(self)
	--[[
	self.speedThreshold = 15;

	self.strengthThreshold = 4;

	self.effectSpeed = 4;

	local pos = Vector();
	local trace = Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi) * TimerMan.DeltaTimeSecs * 20;
	if SceneMan:CastObstacleRay(self.Pos, trace, pos, Vector(), 0, self.Team, 0, 5) >= 0 then
		--Check that the position is actually strong enough to cause dissipation.
		trace = SceneMan:ShortestDistance(self.Pos, pos, true);
		local strength = SceneMan:CastStrengthRay(self.Pos, trace, self.strengthThreshold, Vector(), 0, 0, true);
		local mo = SceneMan:CastMORay(self.Pos, trace, 0, self.Team, 0, true, 5);
		if strength or (mo ~= 255 and mo ~= 0) then
			local effect = CreateAEmitter("untitled.rte/Plasma Hit 1");
			effect.Pos = pos + Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi):SetMagnitude(1);
			effect.Vel = (Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi):SetMagnitude(self.effectSpeed))*0.4;
			effect.Team = self.Team;
			effect.IgnoresTeamHits = true;
			MovableMan:AddParticle(effect);
			self.ToDelete = true;
		end
	end
]]
	--
end

function Update(self)
	local Effect
	local Offset = self.Vel * (15 * TimerMan.DeltaTimeSecs)

	local trailLength = math.floor(Offset.Magnitude + 0.5)
	for i = 1, trailLength, 5 do
		Effect = CreateMOPixel("Plasma Trail Glow A " .. math.random(2), "untitled.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset * (i / trailLength) + Vector(RangeRand(-2, 2), RangeRand(-2, 2))
			Effect.Vel = self.Vel * RangeRand(0.9, 1.0)
			Effect.Lifetime = Effect.Lifetime + (math.random(100))
			Effect.Team = self.Team
			Effect.IgnoresTeamHits = true
			MovableMan:AddParticle(Effect)
		end
	end
	--[[
	if not self.ToDelete then
		if self.Vel.Magnitude >= self.speedThreshold then

			local pos = Vector();
			local trace = Vector(self.Vel.X, self.Vel.Y) * TimerMan.DeltaTimeSecs * 20;
			if SceneMan:CastObstacleRay(self.Pos, trace, pos, Vector(), 0, self.Team, 0, 5) >= 0 then
				--Check that the position is actually strong enough to cause dissipation.
				trace = SceneMan:ShortestDistance(self.Pos, pos, true);
				local strength = SceneMan:CastStrengthRay(self.Pos, trace, self.strengthThreshold, Vector(), 0, 0, true);
				local mo = SceneMan:CastMORay(self.Pos, trace, 0, self.Team, 0, true, 5);
				if strength or (mo ~= 255 and mo ~= 0) then
					local effect = CreateAEmitter("untitled.rte/Plasma Hit 1");
					effect.Pos = pos + Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi):SetMagnitude(1);
					effect.Vel = (Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi):SetMagnitude(self.effectSpeed))*0.4;
					effect.Team = self.Team;
					MovableMan:AddParticle(effect);
					self.ToDelete = true;
				end
			end
		end
	end
]]
	--
end

function Destroy(self) end
