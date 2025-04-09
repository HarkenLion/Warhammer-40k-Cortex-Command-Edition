function Create(self)
	self.lifeTimer = Timer()
	self.falloffTime = 150 + (math.random() * 150)
end

function Update(self)
	if self.lifeTimer:IsPastSimMS(self.falloffTime) then
		if math.random() < 0.50 then
			self.HitsMOs = false
		else
			self.Sharpness = self.Sharpness * RangeRand(0.40, 0.60)
		end

		self.Vel = self.Vel * RangeRand(0.90, 1.0)
		self.lifeTimer:Reset()
	end
end
