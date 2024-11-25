function Create(self)
	self.hit = 0
	self.LTimer = Timer()

	self.IgnoresTeamHits = true

	self.checkVect = self.Vel.AbsRadAngle
end

function Update(self)
	local hitnum = self.hit

	local activate = math.random(0, 1)
	if activate == 0 then
		self.Vel = self.Vel * 1.02
	else
		--Get a target.  Go for the closest actor within 85 pixels.
		if MovableMan:IsActor(self.zapman) == false then
			--local curdist = 45
			for actor in MovableMan:GetMOsInRadius(self.Pos, 45, self.Team) do
				if MovableMan:IsActor(actor) then
					self.zapman = ToActor(actor)
				end
			end
		end

		--If the target still exists...
		if MovableMan:IsActor(self.zapman) then
			--The direction from the center of the missile to the target.
			local targetdir = math.atan2(-(self.zapman.Pos.Y - self.Pos.Y), (self.zapman.Pos.X - self.Pos.X))
			local avgx = self.zapman.Pos.X - self.Pos.X
			local avgy = self.zapman.Pos.Y - self.Pos.Y
			local dist = math.sqrt(avgx ^ 2 + avgy ^ 2)
			curdist = dist

			if curdist < 15 then
				self.zapman:GetController():SetState(Controller.WEAPON_FIRE, false)

				local soundfx = CreateAEmitter("Lightning Impact")
				soundfx.Pos = self.Pos
				MovableMan:AddParticle(soundfx)

				local chain = CreateMOPixel("Gauss Staff Corrosion Particle")
				chain.Pos = self.zapman.Pos
				chain.Vel = self.Vel
				MovableMan:AddParticle(chain)

				local chain2 = CreateMOPixel("Gauss Staff Corrosion Particle")
				chain2.Pos = self.zapman.Pos
				chain2.Vel = self.Vel
				MovableMan:AddParticle(chain2)

				local chain3 = CreateMOPixel("Gauss Staff Corrosion Particle")
				chain3.Pos = self.zapman.Pos
				chain3.Vel = self.Vel
				MovableMan:AddParticle(chain3)

				local chain4 = CreateMOPixel("Gauss Staff Corrosion Particle")
				chain4.Pos = self.zapman.Pos
				chain4.Vel = self.Vel
				MovableMan:AddParticle(chain4)

				local chain5 = CreateMOPixel("Gauss Staff Corrosion Particle")
				chain5.Pos = self.zapman.Pos
				chain5.Vel = self.Vel
				MovableMan:AddParticle(chain5)

				local chain6 = CreateMOPixel("Gauss Staff Corrosion Particle")
				chain6.Pos = self.zapman.Pos
				chain6.Vel = self.Vel
				MovableMan:AddParticle(chain6)

				local chain7 = CreateMOPixel("Gauss Staff Corrosion Particle")
				chain7.Pos = self.zapman.Pos
				chain7.Vel = self.Vel
				MovableMan:AddParticle(chain7)

				local chain8 = CreateMOPixel("Gauss Staff Corrosion Particle")
				chain8.Pos = self.zapman.Pos
				chain8.Vel = self.Vel
				MovableMan:AddParticle(chain8)

				local chain = CreateMOPixel("Gauss Lightning Static Particle")
				local curda = 12
				local curdb = 8
				chain.Pos = self.Pos
				chain.Vel = Vector(curda, curdb):RadRotate(targetdir)
				MovableMan:AddParticle(chain)

				local chain = CreateMOPixel("Gauss Lightning Static Particle")
				local curda = 12
				local curdb = -8
				chain.Pos = self.Pos
				chain.Vel = Vector(curda, curdb):RadRotate(targetdir)
				MovableMan:AddParticle(chain)

				local curda = curdist * 1.35
				local curdb = curdist * 0.35

				local lightfx = CreateMOPixel("Gauss Lightning Particle")
				lightfx.Vel = self.Vel * 0.28
				lightfx.Pos = self.Pos
				MovableMan:AddParticle(lightfx)

				self.Vel = Vector(10, 0):RadRotate(targetdir)

				self.ToDelete = true
			elseif curdist >= 15 and curdist < 24 then
				--Zap to
				local rand1 = 17
				local rand2 = 5
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain3 = CreateMOPixel("Gauss Lightning Trail")
				chain3.Pos = self.Pos
				chain3.Vel = self.Vel
				MovableMan:AddParticle(chain3)
			elseif curdist >= 24 and curdist <= 35 then
				--Zap to
				local curda = 21
				local rand2 = math.random(-9, 9)
				self.Vel = Vector(curda, rand2):RadRotate(targetdir)

				local chain3 = CreateMOPixel("Gauss Lightning Trail")
				chain3.Pos = self.Pos
				chain3.Vel = self.Vel
				MovableMan:AddParticle(chain3)
			elseif curdist > 35 and curdist < 40 then
				--Zap to
				local rand1 = math.random(23, 38)
				local rand2 = math.random(-17, 17)
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain3 = CreateMOPixel("Gauss Lightning Trail")
				chain3.Pos = self.Pos
				chain3.Vel = self.Vel
				MovableMan:AddParticle(chain3)
			elseif curdist >= 40 then
				--Make lightning track target, but still wiggle around
				local rand1 = math.random(25, 41)
				local rand2 = math.random(-21, 21)
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain3 = CreateMOPixel("Gauss Lightning Trail")
				chain3.Pos = self.Pos
				chain3.Vel = self.Vel
				MovableMan:AddParticle(chain3)
			end
		else
			--If there's no target, randomly fly around
			local rand1 = math.random(-26, 27)
			local rand2 = math.random(-27, 27)
			self.Vel = Vector(rand1, rand2):RadRotate(self.checkVect)

			if self.LTimer:IsPastSimMS(60) then
				self.LTimer:Reset()
				local chain3 = CreateMOPixel("Gauss Lightning Trail")
				chain3.Pos = self.Pos
				chain3.Vel = self.Vel
				MovableMan:AddParticle(chain3)
			end
		end
	end
end
