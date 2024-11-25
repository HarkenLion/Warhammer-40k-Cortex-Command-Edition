function Create(self)
	self.ForceSensitiveList = { "Black Legion Marine", "End" }
	self.hit = 0

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
			local curdist = 85
			for actor in MovableMan.Actors do
				local avgx = actor.Pos.X - self.Pos.X
				local avgy = actor.Pos.Y - self.Pos.Y
				local dist = math.sqrt(avgx ^ 2 + avgy ^ 2)
				if dist < curdist and actor.Team ~= self.Team then
					curdist = dist
					self.zapman = actor
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
				self.zapman:FlashWhite(25)

				self.zapman:GetController():SetState(Controller.WEAPON_FIRE, false)

				local soundfx = CreateAEmitter("Lightning Impact")
				soundfx.Pos = self.Pos
				MovableMan:AddParticle(soundfx)

				local part1 = 3

				if self.zapman.Mass > 170 and hitnum < 1 then
					part1 = 0
				end

				if part1 == 0 and hitnum > 1 then
					part1 = 1
				end

				local mathran = math.random(0, 12)
				local maybezap = mathran - self.zapman.Sharpness

				if maybezap > 3 then
					ToActor(self.zapman).Health = ToActor(self.zapman).Health - part1
				end

				local chain = CreateMOPixel("Lightning Particle B")
				local curda = curdist
				local curdb = 0
				chain.Pos = self.Pos
				chain.Vel = Vector(curda, curdb):RadRotate(targetdir)
				MovableMan:AddParticle(chain)
				local curda = curdist * 1.35
				local curdb = curdist * 0.35
				self.Vel = Vector(curda, curdb):RadRotate(targetdir)
				self.hit = hitnum + 1

				if self.zapman:IsPlayerControlled() == false then
					self.zapman:SetControllerMode(Controller.CIM_AI, -1)
				end
			elseif curdist >= 15 and curdist < 24 then
				--Zap to
				local rand1 = 11
				local rand2 = 5
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Lightning Particle B")
				chain.Vel = Vector(rand1, rand2):RadRotate(targetdir)
				chain.Pos = self.Pos
				MovableMan:AddParticle(chain)
			elseif curdist >= 24 and curdist <= 45 then
				--Zap to
				local curda = 18
				local rand2 = math.random(-9, 9)
				self.Vel = Vector(curda, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Lightning Particle B")
				chain.Vel = Vector(curda, rand2):RadRotate(targetdir)
				chain.Pos = self.Pos
				MovableMan:AddParticle(chain)
			elseif curdist > 45 and curdist < 60 then
				--Zap to
				local rand1 = math.random(19, 30)
				local rand2 = math.random(-17, 17)
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Lightning Particle B")
				chain.Pos = self.Pos
				chain.Vel = Vector(rand1, rand2):RadRotate(targetdir)
				MovableMan:AddParticle(chain)
			elseif curdist >= 60 then
				--Make lightning track target, but still wiggle around
				local rand1 = math.random(31, 47)
				local rand2 = math.random(-29, 29)
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)

				local chain = CreateMOPixel("Lightning Particle B")
				chain.Vel = Vector(rand1 * 0.5, rand2):RadRotate(targetdir)
				chain.Pos = self.Pos
				MovableMan:AddParticle(chain)
			end
		else
			--If there's no target, randomly fly around
			local rand1 = math.random(36, 67)
			local rand2 = math.random(-47, 47)
			self.Vel = Vector(rand1, rand2):RadRotate(self.checkVect)
			local chain = CreateMOPixel("Lightning Particle B")
			chain.Pos = self.Pos
			chain.Vel = Vector(rand1 * 0.5, rand2 * 0.5):RadRotate(self.checkVect)
			MovableMan:AddParticle(chain)
		end
	end
end
