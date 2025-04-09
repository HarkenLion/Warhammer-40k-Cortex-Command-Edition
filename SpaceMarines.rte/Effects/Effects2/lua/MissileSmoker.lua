function Create(self)
	self.lifeTimer = Timer()

	self.started = false -- basically this is the same as self:EnableEmission

	self.smokeCounter = 2 -- count the smokes; 2 = pre-started, 3 = started
end

function Update(self)
	local Effect
	local Offset = self.Vel * (20 * TimerMan.DeltaTimeSecs)

	local trailLength = math.floor(Offset.Magnitude + 0.5)
	for i = 1, trailLength, 6 do
		Effect = CreateMOSParticle("Launcher Trail Smoke " .. math.random(self.smokeCounter), "Untitled.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset * (i / trailLength) + Vector(RangeRand(-1.0, 1.0), RangeRand(-1.0, 1.0))
			Effect.Vel = self.Vel * math.random()
				+ Vector(math.random() * 4, 0):RadRotate(math.random() * (math.pi * 2))
			Effect.Lifetime = Effect.Lifetime * RangeRand(0.75, 1.25)
			MovableMan:AddParticle(Effect)
		end
	end

	if not self.started then
		if self.lifeTimer:IsPastSimMS(200) then
			self.smokeCounter = 4
			self.started = true
		end
	end

	if self.lifeTimer:IsPastSimMS(2000) then
		self.smokeCounter = 2
	elseif self.lifeTimer:IsPastSimMS(1700) then
		self.smokeCounter = 3
	end
end
