function Create(self)
	self.speedThreshold = 100

	self.strengthThreshold = 4

	self.effectSpeed = 4

	local pos = Vector()
	local trace = Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi) * TimerMan.DeltaTimeSecs * 20
	if SceneMan:CastObstacleRay(self.Pos, trace, pos, Vector(), 0, self.Team, 0, 5) >= 0 then
		--Check that the position is actually strong enough to cause dissipation.
		trace = SceneMan:ShortestDistance(self.Pos, pos, true)
		local strength = SceneMan:CastStrengthRay(self.Pos, trace, self.strengthThreshold, Vector(), 0, 0, true)
		local mo = SceneMan:CastMORay(self.Pos, trace, 0, self.Team, 0, true, 5)
		if strength or (mo ~= 255 and mo ~= 0) then
			local effect = CreateAEmitter("untitled.rte/Laser Hit")
			effect.Pos = pos + Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi):SetMagnitude(3)
			effect.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi):SetMagnitude(self.effectSpeed) * 0.10
			effect.Team = self.Team
			MovableMan:AddParticle(effect)
			--effect:GibThis();
		end
	end
end

function Update(self)
	if not self.ToDelete then
		if self.Vel.Magnitude >= self.speedThreshold then
			local pos = Vector()
			local trace = Vector(self.Vel.X, self.Vel.Y) * TimerMan.DeltaTimeSecs * 20
			if SceneMan:CastObstacleRay(self.Pos, trace, pos, Vector(), 0, self.Team, 0, 5) >= 0 then
				--Check that the position is actually strong enough to cause dissipation.
				trace = SceneMan:ShortestDistance(self.Pos, pos, true)
				local strength = SceneMan:CastStrengthRay(self.Pos, trace, self.strengthThreshold, Vector(), 0, 0, true)
				local mo = SceneMan:CastMORay(self.Pos, trace, 0, self.Team, 0, true, 5)
				if strength or (mo ~= 255 and mo ~= 0) then
					local effect = CreateAEmitter("untitled.rte/Laser Hit")
					effect.Pos = pos + Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi):SetMagnitude(3)
					effect.Vel = Vector(self.Vel.X, self.Vel.Y):RadRotate(math.pi):SetMagnitude(self.effectSpeed) * 0.10
					effect.Team = self.Team
					MovableMan:AddParticle(effect)
					--effect:GibThis();
				end
			end
		end
	end
end

function Destroy(self) end
