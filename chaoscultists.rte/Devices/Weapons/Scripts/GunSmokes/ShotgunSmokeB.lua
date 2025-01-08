function Create(self)
	if self.Magazine then
		self.ammo = self.Magazine.RoundCount
	else
		self.ammo = 0
	end
end

function Update(self)
	if self.FiredFrame then
		local randomSmoke = math.floor(math.random() * 7) + 4

		for i = 1, randomSmoke do
			local smokefx = CreateMOSParticle("Tiny Smoke Ball 1")
			smokefx.Pos = self.MuzzlePos
			smokefx.Vel = self.Vel / 4
				+ Vector(((math.random() * 4) + 3) * self.FlipFactor, 0):RadRotate(
					self.RotAngle + (math.random() * 1) - 0.6
				)
			MovableMan:AddParticle(smokefx)
			smokefx = nil
		end

		for i = 1, math.floor(randomSmoke / 8) do
			local smokefx = CreateMOSParticle("Small Smoke Ball 1")
			smokefx.Pos = self.MuzzlePos
			smokefx.Vel = self.Vel / 4
				+ Vector(((math.random() * 2) + 1) * self.FlipFactor, 0):RadRotate(
					self.RotAngle + (math.random() * 1) - 0.6
				)
			MovableMan:AddParticle(smokefx)
			smokefx = nil
		end

		local glowfx = CreateMOPixel("Armada Rifle Glow A", "ImporianArmada.rte")
		glowfx.Pos = self.MuzzlePos
		MovableMan:AddParticle(glowfx)
	end
end