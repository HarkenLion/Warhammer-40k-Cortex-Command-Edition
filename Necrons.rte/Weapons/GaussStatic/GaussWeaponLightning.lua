function Create(self)
	self.hit = 0
	self.LTimer = Timer()
	self.IgnoresTeamHits = true

	self.checkVect = self.Vel.AbsRadAngle
end

function Update(self)
	local activate = math.random(0, 1)
	if activate == 0 then
		self.Vel = self.Vel * 1.02
	else
		--Get a target.  Go for the closest actor within 85 pixels.
		if MovableMan:IsActor(self.zapman) == false then
			local curdist = 45
			--for actor in MovableMan.Actors do
			for actor in MovableMan:GetMOsInRadius(self.Pos, 45, self.Team) do
				if MovableMan:IsActor(actor) then
					self.zapman = ToActor(actor)
				end
			end
		end

		if self.hit > 0 then
			self.ToDelete = true
		end

		--If the target still exists...
		if MovableMan:IsActor(self.zapman) then
			--The direction from the center of the missile to the target.
			local targetdir = math.atan2(-(self.zapman.Pos.Y - self.Pos.Y), (self.zapman.Pos.X - self.Pos.X))
			local avgx = self.zapman.Pos.X - self.Pos.X
			local avgy = self.zapman.Pos.Y - self.Pos.Y
			local dist = math.sqrt(avgx ^ 2 + avgy ^ 2)
			curdist = dist

			if curdist < 18 then
				local soundfx = CreateAEmitter("Lightning Impact")
				soundfx.Pos = self.Pos
				MovableMan:AddParticle(soundfx)

				self.HitsMOs = true

				local chain = CreateMOPixel("Gauss Lightning Particle")
				chain.Pos = self.zapman.Pos
				chain.Vel = self.Vel

				ToActor(self.zapman).Health = ToActor(self.zapman).Health
					- (math.floor((100 / ToActor(self.zapman).Mass)))

				chain.Team = self.Team
				chain.IgnoresTeamHits = true

				MovableMan:AddParticle(chain)

				local chain = CreateMOPixel("Gauss Lightning Static Particle")
				local curda = curdist
				local curdb = 12
				chain.Pos = self.Pos
				chain.Vel = Vector(curda + self.zapman.Vel.X, curdb + self.zapman.Vel.Y):RadRotate(targetdir)

				chain.Team = self.Team
				chain.IgnoresTeamHits = true

				MovableMan:AddParticle(chain)

				local chain = CreateMOPixel("Gauss Lightning Static Particle")
				local curda = curdist
				local curdb = -12
				chain.Pos = self.Pos
				chain.Vel = Vector(curda + self.zapman.Vel.X, curdb + self.zapman.Vel.Y):RadRotate(targetdir)
				chain.Team = self.Team
				chain.IgnoresTeamHits = true
				MovableMan:AddParticle(chain)

				local curda = curdist * 1.35
				local curdb = curdist * 0.35

				local lightfx = CreateMOPixel("Gauss Lightning Particle")
				lightfx.Vel = self.Vel * 0.28
				lightfx.Pos = self.Pos
				lightfx.Team = self.Team
				lightfx.IgnoresTeamHits = true
				MovableMan:AddParticle(lightfx)

				self.Vel = Vector(curda, curdb):RadRotate(targetdir)

				self.hit = self.hit + 1

				if self.hit >= 1 then
					self.ToDelete = true
				end
			elseif curdist >= 18 and curdist < 24 then
				--Zap to
				local rand1 = 17
				local rand2 = 5
				self.Vel = Vector(rand1 + self.zapman.Vel.X, rand2 + self.zapman.Vel.Y):RadRotate(targetdir)

				local chain3 = CreateMOPixel("Gauss Lightning Trail")
				chain3.Pos = self.Pos
				chain3.Vel = self.Vel
				chain3.Team = self.Team
				chain3.IgnoresTeamHits = true
				MovableMan:AddParticle(chain3)
			elseif curdist >= 24 and curdist <= 35 then
				--Zap to
				local curda = 21
				local rand2 = math.random(-7, 7)
				self.Vel = Vector(curda + self.zapman.Vel.X, rand2 + self.zapman.Vel.Y):RadRotate(targetdir)

				local chain3 = CreateMOPixel("Gauss Lightning Trail")
				chain3.Pos = self.Pos
				chain3.Vel = self.Vel
				chain3.Team = self.Team
				chain3.IgnoresTeamHits = true
				MovableMan:AddParticle(chain3)
			elseif curdist > 35 and curdist < 40 then
				--Zap to
				local rand1 = math.random(23, 38)
				local rand2 = math.random(-11, 11)
				self.Vel = Vector(rand1 + self.zapman.Vel.X, rand2 + self.zapman.Vel.Y):RadRotate(targetdir)

				local chain3 = CreateMOPixel("Gauss Lightning Trail")
				chain3.Pos = self.Pos
				chain3.Vel = self.Vel
				chain3.Team = self.Team
				chain3.IgnoresTeamHits = true
				MovableMan:AddParticle(chain3)
			elseif curdist >= 40 then
				--Make lightning track target, but still wiggle around
				local rand1 = math.random(25, 41)
				local rand2 = math.random(-13, 13)
				self.Vel = Vector(rand1 + self.zapman.Vel.X, rand2 + self.zapman.Vel.Y):RadRotate(targetdir)

				local chain3 = CreateMOPixel("Gauss Lightning Trail")
				chain3.Pos = self.Pos
				chain3.Vel = self.Vel
				chain3.Team = self.Team
				chain3.IgnoresTeamHits = true
				MovableMan:AddParticle(chain3)
			end
		else
			--If there's no target, randomly fly around
			local rand1 = math.random(46, 87)
			local rand2 = math.random(-17, 17)
			self.Vel = Vector(rand1, rand2):RadRotate(self.checkVect)

			self.HitsMOs = false

			if self.LTimer:IsPastSimMS(30) then
				self.LTimer:Reset()
				local chain3 = CreateMOPixel("Gauss Lightning Trail")
				chain3.Pos = self.Pos
				chain3.Vel = self.Vel
				chain3.Team = self.Team
				chain3.IgnoresTeamHits = true
				MovableMan:AddParticle(chain3)
			end
		end
	end
end
