function Create(self) end

function Update(self)
	if self.FiredFrame then
		local randomSmoke = math.floor(math.random() * 5) + 3

		for i = 1, randomSmoke do
			local smokefx = CreateMOSParticle("Tiny Smoke Ball 1")
			smokefx.Pos = self.MuzzlePos
			smokefx.Vel = self.Vel / 4
				+ Vector(((math.random() * 6) + 3) * self.FlipFactor, 0):RadRotate(
					self.RotAngle + (math.random() * 0.6) - 0.2
				)
			MovableMan:AddParticle(smokefx)
			smokefx = nil
		end

		for i = 1, randomSmoke / 2 do
			local smokefx = CreateMOSParticle("Small Smoke Ball 1")
			smokefx.Pos = self.MuzzlePos
			smokefx.Vel = self.Vel / 4
				+ Vector(((math.random() * 3) + 2) * self.FlipFactor, 0):RadRotate(
					self.RotAngle + (math.random() * 0.6) - 0.2
				)
			MovableMan:AddParticle(smokefx)
			smokefx = nil
		end

		local blastBall = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte")
		blastBall.Pos = self.MuzzlePos + Vector(1 * self.FlipFactor, 0)
		blastBall.Vel = self.Vel + Vector(10 * self.FlipFactor, 0)
		MovableMan:AddParticle(blastBall)

		local glowfx = CreateMOPixel("Armada Rifle Glow A", "ImporianArmada.rte")
		glowfx.Pos = self.MuzzlePos
		MovableMan:AddParticle(glowfx)
	end
end
