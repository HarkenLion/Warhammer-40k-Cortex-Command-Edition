function Create(self)
	self.hit = 0

	self.IgnoresTeamHits = true
	self.LTimer = Timer()

	self.checkVect = self.Vel.AbsRadAngle

	self.prevpos = Vector(self.Pos.X, self.Pos.Y)
end

function Update(self)
	local hitnum = self.hit

	local activate = math.random(0, 1)
	if activate == 0 then
		self.Vel = self.Vel * 1.02
	else
		--Get a target.  Go for the closest actor within 85 pixels.
		if MovableMan:IsActor(self.zapman) == false then
			--local curdist = 85
			--for actor in MovableMan.Actors do
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
				self.zapman:GetController():SetState(Controller.BODY_CROUCH, true)
				local rand = math.random(0, 19)
				if rand == 0 then
					self.zapman:GetController():SetState(Controller.MOVE_LEFT, true)
				else
					self.zapman:GetController():SetState(Controller.MOVE_RIGHT, true)
				end

				self.zapman:SetAimAngle(math.random(math.pi / -2, math.pi / 2))

				self.zapman:GetController():SetState(Controller.WEAPON_FIRE, false)

				local soundfx = CreateAEmitter("Lightning Impact")
				soundfx.Pos = self.Pos
				MovableMan:AddParticle(soundfx)

				local chain = CreateMOPixel("Gauss Staff Corrosion Particle")
				chain.Pos = self.zapman.Pos
				chain.Vel = self.Vel
				MovableMan:AddParticle(chain)

				local chain = CreateMOPixel("Gauss Lightning Static Particle")
				local curda = 10 --curdist
				local curdb = 0 --12
				chain.Pos = self.Pos
				chain.Vel = Vector(curda, curdb):RadRotate(targetdir)
				MovableMan:AddParticle(chain)

				local chain = CreateMOPixel("Gauss Lightning Static Particle")
				local curda = curdist
				local curdb = -12
				chain.Pos = self.Pos
				chain.Vel = Vector(curda, curdb):RadRotate(targetdir)
				MovableMan:AddParticle(chain)

				local curda = curdist * 1.35
				local curdb = curdist * 0.35

				local lightfx = CreateMOPixel("Gauss Lightning Particle")
				lightfx.Vel = self.Vel * 0.08
				lightfx.Pos = self.Pos
				MovableMan:AddParticle(lightfx)

				self.Vel = Vector(curda, curdb):RadRotate(targetdir)
				self.hit = hitnum + 1

				if self.zapman:IsPlayerControlled() == false then
					self.zapman:SetControllerMode(Controller.CIM_AI, -1)
				end

				self.ToDelete = true
			elseif curdist >= 15 and curdist < 24 then
				--Zap to
				local rand1 = 11
				local rand2 = 5
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Gauss Lightning Trail")
				chain.Vel = Vector(rand1, rand2):RadRotate(targetdir)
				chain.Pos = self.Pos
				MovableMan:AddParticle(chain)
			elseif curdist >= 24 and curdist <= 45 then
				--Zap to
				local curda = 18
				local rand2 = math.random(-9, 9)
				self.Vel = Vector(curda, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Gauss Lightning Trail")
				chain.Vel = Vector(curda, rand2):RadRotate(targetdir)
				chain.Pos = self.Pos
				MovableMan:AddParticle(chain)
			elseif curdist > 45 and curdist < 60 then
				--Zap to
				local rand1 = math.random(19, 30)
				local rand2 = math.random(-11, 11)
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Gauss Lightning Trail")
				chain.Pos = self.Pos
				chain.Vel = Vector(rand1, rand2):RadRotate(targetdir)
				MovableMan:AddParticle(chain)
			elseif curdist >= 60 then
				--Make lightning track target, but still wiggle around
				local rand1 = math.random(31, 47)
				local rand2 = math.random(-15, 15)
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Gauss Lightning Trail")
				chain.Vel = Vector(rand1 * 0.5, rand2):RadRotate(targetdir)
				chain.Pos = self.Pos
				MovableMan:AddParticle(chain)
			end
		else
			--If there's no target, randomly fly around
			local rand1 = math.random(26, 45)
			local rand2 = math.random(-17, 17)
			self.Vel = Vector(rand1, rand2):RadRotate(self.checkVect)

			if self.LTimer:IsPastSimMS(90) then
				self.LTimer:Reset()
				local chain = CreateMOPixel("Gauss Lightning Trail")
				chain.Pos = self.Pos
				chain.Vel = Vector(rand1 * 0.5, rand2 * 0.5):RadRotate(self.checkVect)
				MovableMan:AddParticle(chain)
			end
		end

		local posa = self.prevpos
		local posb = self.Pos
		PrimitiveMan:DrawLinePrimitive(posa, posb, 117, 1.85)

		self.prevpos = self.Pos
	end
end
