function Create(self)
	self.lifeTimer = Timer()

	local lifeset = self.Lifetime * math.random()
	if self.Lifetime <= 300 then
		self.Lifetime = 300
	else
		self.Lifetime = lifeset
	end
end

function Update(self)
	if self.lifeTimer:IsPastSimMS(450) then
		self.ToDelete = true
	end
end
