function Create(self) end

function Update(self)
	if self.FiredFrame then
		local randomSmoke = math.floor(math.random() * 5) + 3

		for i = 1, randomSmoke do
			local smokefx = CreateMOSParticle("Tiny Smoke Ball 1")
			smokefx.Pos = self.MuzzlePos + Vector(0, 1)
			smokefx.Vel = self.Vel / 4
				+ Vector(((math.random() * 4) + 2) * self.FlipFactor, 0):RadRotate(
					self.RotAngle + (math.random() * 0.8) - 0.4
				)
			MovableMan:AddParticle(smokefx)
			smokefx = nil
		end
	end
end
