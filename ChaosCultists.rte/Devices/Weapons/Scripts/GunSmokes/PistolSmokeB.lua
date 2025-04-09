function Create(self) end

function Update(self)
	if self.FiredFrame then
		local randomSmoke = math.floor(math.random() * 2) + 2

		for i = 1, randomSmoke do
			local smokefx = CreateMOSParticle("Tiny Smoke Ball 1")
			smokefx.Pos = self.MuzzlePos
			smokefx.Vel = self.Vel / 4
				+ Vector(((math.random() * 3) + 2) * self.FlipFactor, 0):RadRotate(
					self.RotAngle + (math.random() * 0.2) - 0.1
				)
			MovableMan:AddParticle(smokefx)
			smokefx = nil
		end

		local glowfx = CreateMOPixel("Armada Rifle Glow A", "ImporianArmada.rte")
		glowfx.Pos = self.MuzzlePos
		MovableMan:AddParticle(glowfx)
	end
end
