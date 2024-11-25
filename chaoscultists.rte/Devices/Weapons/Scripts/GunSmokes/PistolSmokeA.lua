function Create(self) end

function Update(self)
	if self.FiredFrame then
		local randomSmoke = math.floor(math.random() * 2) + 1

		for i = 1, randomSmoke do
			local smokefx = CreateMOSParticle("Tiny Smoke Ball 1")
			smokefx.Pos = self.MuzzlePos
			smokefx.Vel = self.Vel / 4
				+ Vector(((math.random() * 3) + 1) * self.FlipFactor, 0):RadRotate(
					self.RotAngle + (math.random() * 0.2) - 0.1
				)
			MovableMan:AddParticle(smokefx)
			smokefx = nil
		end
	end
end
