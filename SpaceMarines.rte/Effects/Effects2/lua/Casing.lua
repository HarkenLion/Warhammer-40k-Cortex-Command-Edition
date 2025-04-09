function Create(self)
	self.AngularVel = (5 + math.random(15))

	self.timer1 = Timer()
	self.counter = 1
end

function Update(self)
	if self.timer1:IsPastSimMS(self.counter) then
		self.counter = self.counter * 1.1
		self.timer1:Reset()

		eff = CreateMOSParticle("Longsmoke 1", "Untitled.rte")
		eff.Pos = self.Pos + Vector(math.random(), 0):RadRotate(2 * math.pi * math.random())
		eff.Vel = self.Vel * math.random() + Vector(math.random(), 0):RadRotate(math.random() * (math.pi * 2))
		eff.Lifetime = eff.Lifetime + math.random(50)
		MovableMan:AddParticle(eff)
	end
end
