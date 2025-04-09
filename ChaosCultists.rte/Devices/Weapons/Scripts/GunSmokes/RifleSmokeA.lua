function Create(self) end

function Update(self)
	if self.FiredFrame then
		local randomSmoke = math.floor(math.random() * 3) + 2

		for i = 1, randomSmoke do
			local smokefx = CreateMOSParticle("Tiny Smoke Ball 1")
			smokefx.Pos = self.MuzzlePos
			smokefx.Vel = self.Vel / 4
				+ Vector(((math.random() * 5) + 2) * self.FlipFactor, 0):RadRotate(
					self.RotAngle + (math.random() * 0.5) - 0.15
				)
			MovableMan:AddParticle(smokefx)
			smokefx = nil
		end
	end
end
