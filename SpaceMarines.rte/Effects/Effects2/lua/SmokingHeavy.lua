function Create(self)
	self.timer1 = Timer()
	self.counter = 1
end

function Update(self)
	if self.RoundCount == 0 then
		if self.timer1:IsPastSimMS(self.counter) then
			self.counter = self.counter * 1.1
			self.timer1:Reset()

			eff = CreateMOSParticle("Longsmoke " .. math.random(2), "Untitled.rte")
			eff.Pos = self.Pos + Vector(math.random() * 2, 0):RadRotate(2 * math.pi * math.random())
			eff.Vel = self.Vel * math.random() + Vector(math.random(), 0):RadRotate(math.random() * (math.pi * 2))
			eff.Lifetime = eff.Lifetime + math.random(70)
			MovableMan:AddParticle(eff)
		end
	end
end
