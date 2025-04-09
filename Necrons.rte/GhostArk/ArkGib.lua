function Create(self)
	--self.PinStrength = 100000
	self.AngularVel = 0

	self.ToSettle = true
end

function Update(self)
	self.ToSettle = true

	if self.ToSettle == true then
		local rand = math.random(-80, 85)
		local rand2 = math.random(-65, 65)

		local chain7 = CreateMOPixel("Gauss Lightning Static Particle")
		chain7.Pos.X = self.Pos.X + rand
		chain7.Pos.Y = self.Pos.Y + rand2
		chain7.Vel = self.Vel
		chain7.Team = self.Team
		chain7.IgnoresTeamHits = true
		MovableMan:AddParticle(chain7)

		self.ArkExplosion = CreateMOSRotating("Necron Ghost Ark Explosion")
		self.ArkExplosion.Pos = self.Pos
		MovableMan:AddParticle(self.ArkExplosion)
	end
end

function Destroy(self)
	if self.IsGeneric then
		self.ArkExplosion = CreateMOSRotating("Necron Ghost Ark Explosion")
		self.ArkExplosion.Pos = self.Pos
		MovableMan:AddParticle(self.ArkExplosion)
	end
end
