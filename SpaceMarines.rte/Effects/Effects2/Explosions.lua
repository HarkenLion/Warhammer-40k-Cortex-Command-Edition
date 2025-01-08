function Update(self)
	for i = 1, 2 do
		local thing = CreateAEmitter("Untitled.rte.rte/Explosion Thing")
		thing.Pos = self.Pos
			+ Vector(RangeRand(self.Age * 0.40, self.Age * 0.45), 0):RadRotate(2 * math.pi * math.random())

		--thing.Vel = Vector(1, 0):RadRotate(2 * math.pi * math.random());
		MovableMan:AddParticle(thing)
	end
end
