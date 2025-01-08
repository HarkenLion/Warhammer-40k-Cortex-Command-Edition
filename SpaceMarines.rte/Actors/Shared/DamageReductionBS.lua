function Create(self)
	self.HealthReduction = 0.6
	self.WoundNegation = 0.6

	self.damagePreHealth = self.Health

	self.totalWoundCount = 0
end

function Update(self)
	if self.Health < self.damagePreHealth - 1 then
		local damage = self.damagePreHealth - self.Health

		local nuHealth = damage * self.HealthReduction

		self.Health = self.Health + nuHealth

		self.damagePreHealth = self.Health

		if self.WoundCount > self.totalWoundCount then
			if math.random() <= self.WoundNegation then
				self:RemoveWounds(1, true, false, false)
			end
			self.totalWoundCount = self.WoundCount
		end
	else
		self.damagePreHealth = self.Health

		self.totalWoundCount = self.WoundCount
	end
end
