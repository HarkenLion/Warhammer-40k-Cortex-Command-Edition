function Create(self)
	self.LTimer = Timer()
	self.curdist = 90

	self.hit = 0
end

function Update(self)
	local hitnum = self.hit

	local activate = math.random(0, 1)
	if activate == 0 then
		self.Vel = self.Vel * 1.02
	else
		--Get a target.  Go for the closest actor within 85 pixels.
		if MovableMan:IsActor(self.zapman) == false then
			for actor in MovableMan:GetMOsInRadius(self.Pos, 85, self.Team) do
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

			if self.hit > 0 then
				self.ToDelete = true
			end

			if curdist < 10 then
				local soundfx = CreateAEmitter("Gauss Lightning Impact")
				soundfx.Pos = self.Pos
				MovableMan:AddParticle(soundfx)

				local chain = CreateMOPixel("Gauss Impact Corrosion Particle")
				chain.Pos = self.Pos
				chain.Vel = self.Vel
				MovableMan:AddParticle(chain)

				local chain = CreateMOPixel("Lightning Particle C")
				local curda = curdist
				local curdb = 0
				chain.Pos = self.Pos
				chain.Vel = Vector(curda, curdb):RadRotate(targetdir)
				MovableMan:AddParticle(chain)
				local curda = curdist * 1.35
				local curdb = curdist * 0.35
				self.Vel = Vector(curda, curdb):RadRotate(targetdir)
				self.hit = self.hit + 1
			elseif curdist >= 15 and curdist < 24 then
				--Zap to
				local rand1 = 11
				local rand2 = 5
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Lightning Particle C")
				chain.Vel = Vector(rand1, rand2):RadRotate(targetdir)
				chain.Pos = self.Pos
				MovableMan:AddParticle(chain)
			elseif curdist >= 24 and curdist <= 45 then
				--Zap to
				local curda = 18
				local rand2 = math.random(-9, 9)
				self.Vel = Vector(curda, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Lightning Particle C")
				chain.Vel = Vector(curda, rand2):RadRotate(targetdir)
				chain.Pos = self.Pos
				MovableMan:AddParticle(chain)
			elseif curdist > 45 and curdist < 60 then
				--Zap to
				local rand1 = math.random(19, 30)
				local rand2 = math.random(-17, 17)
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Lightning Particle C")
				chain.Pos = self.Pos
				chain.Vel = Vector(rand1, rand2):RadRotate(targetdir)
				MovableMan:AddParticle(chain)
			elseif curdist >= 60 then
				--Make lightning track target, but still wiggle around
				local rand1 = math.random(31, 47)
				local rand2 = math.random(-29, 29)
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Lightning Particle C")
				chain.Vel = Vector(rand1 * 0.5, rand2):RadRotate(targetdir)
				chain.Pos = self.Pos
				MovableMan:AddParticle(chain)
			end
		else
			--If there's no target, randomly fly around
			local rand1 = math.random(-26, 26)
			local rand2 = math.random(-27, 27)
			self.Vel = Vector(rand1, rand2)

			if self.LTimer:IsPastSimMS(50) then
				self.LTimer:Reset()
				local chain = CreateMOPixel("Lightning Particle C")
				chain.Pos = self.Pos
				chain.Vel = Vector(rand1 * 0.5, rand2 * 0.5)
				MovableMan:AddParticle(chain)
			end
		end
	end
end
