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
			elseif curdist >= 24 and curdist <= 45 then
				--Zap to
				local curda = 18
				local rand2 = math.random(-9, 9)
				self.Vel = Vector(curda, rand2):RadRotate(targetdir)
			elseif curdist > 45 and curdist < 60 then
				--Zap to
				local rand1 = math.random(19, 30)
				local rand2 = math.random(-17, 17)
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)
			elseif curdist >= 60 then
				--Make lightning track target, but still wiggle around
				local rand1 = math.random(31, 47)
				local rand2 = math.random(-29, 29)
				self.Vel = Vector(rand1, rand2):RadRotate(targetdir)
			end
		else
			--If there's no target, randomly fly around
			local rand1 = math.random(36, 67)
			local rand2 = math.random(-47, 47)
			self.Vel = Vector(rand1, rand2):RadRotate(self.checkVect)
		end
	end
end
