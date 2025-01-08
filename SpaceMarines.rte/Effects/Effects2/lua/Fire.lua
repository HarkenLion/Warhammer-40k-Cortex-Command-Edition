function Create(self)
	self.IgnoresTeamHits = true
	self.lifeTimer = Timer()
	self.actionPhase = 0
	self.blink = true
	self.changeCounter = 0
	self.stuck = false
	self.target = nil
	self.burnTimer = Timer()

	self.effCounter = 1
	self.random = math.random(300)

	self.delay1 = 500 * RangeRand(0.80, 1.20) -- lifetime without target
	self.delay2 = 3 * self.delay1 -- lifetime on terrain
	self.delay3 = 2 * self.delay2 -- lifetime on mo
end

function Update(self)
	if not self.lifeTimer:IsPastSimMS(self.delay3 - self.delay1) then
		local eff1 = CreateMOSParticle("Flame Particle " .. math.random(self.effCounter), "Untitled.rte")
		eff1.Pos = self.Pos
		eff1.Vel = Vector(math.random(self.effCounter), 0):RadRotate(math.random() * (math.pi * 2)) + (self.Vel * 0.30)
		eff1.Lifetime = eff1.Lifetime + (eff1.Lifetime * 0.20)
		MovableMan:AddParticle(eff1)
	end

	if self.lifeTimer:IsPastSimMS(30) then
		self.effCounter = 2
	end
	if self.lifeTimer:IsPastSimMS(80) then
		self.effCounter = 3
	end
	if self.lifeTimer:IsPastSimMS(330) then
		self.effCounter = 2
	end
	if self.lifeTimer:IsPastSimMS(480) then
		self.effCounter = 1
	end

	if self.actionPhase == 0 then
		local rayHitPos = Vector(0, 0)
		local rayHit = false
		for i = 1, 15 do
			local checkPos = self.Pos + Vector(self.Vel.X, self.Vel.Y):SetMagnitude(i)
			local checkPix = SceneMan:GetMOIDPixel(checkPos.X, checkPos.Y)
			if checkPix ~= 255 then
				checkPos = checkPos
					+ SceneMan:ShortestDistance(checkPos, self.Pos, SceneMan.SceneWrapsX):SetMagnitude(3)
				local checkteam = MovableMan:GetMOFromID(checkPix)
				local actor = MovableMan:GetMOFromID(checkteam.RootID)
				if MovableMan:IsActor(actor) then
					teamcheck = ToActor(actor)
					if teamcheck.Team ~= self.Team then
						self.target = MovableMan:GetMOFromID(checkPix)
						self.stickpositionX = checkPos.X - self.target.Pos.X
						self.stickpositionY = checkPos.Y - self.target.Pos.Y
						self.stickrotation = self.target.RotAngle
						self.stickdirection = self.RotAngle
						self.stuck = true
						rayHit = true
						break
						--elseif teamcheck.Team == self.Team then
						--self.ToDelete = true;
					end
				end
			end
		end
		if rayHit == true then
			self.actionPhase = 1
		else
			if
				SceneMan:CastStrengthRay(
					self.Pos,
					Vector(self.Vel.X, self.Vel.Y):SetMagnitude(15),
					0,
					rayHitPos,
					0,
					0,
					SceneMan.SceneWrapsX
				) == true
			then
				self.Pos = rayHitPos
					+ SceneMan:ShortestDistance(rayHitPos, self.Pos, SceneMan.SceneWrapsX):SetMagnitude(2)
				self.PinStrength = 1000
				self.AngularVel = 0
				self.stuck = true
				self.actionPhase = 2
			end
		end
	elseif self.actionPhase == 1 then
		if self.target ~= nil and self.target.ID ~= 255 then
			self.Pos = self.target.Pos
				+ Vector(self.stickpositionX, self.stickpositionY):RadRotate(self.target.RotAngle - self.stickrotation)
			self.RotAngle = self.stickdirection + (self.target.RotAngle - self.stickrotation)
			self.PinStrength = 1000
			self.Vel = Vector(0, 0)
		else
			self.PinStrength = 0
			self.ToSettle = false
			self.actionPhase = 0
		end
	end

	if self.actionPhase ~= 1 then
		if self.actionPhase == 0 then
			if self.lifeTimer:IsPastSimMS(self.delay1) then
				self.ToSettle = false
				self.ToDelete = true
			end
		end
		if self.actionPhase == 2 then
			if self.lifeTimer:IsPastSimMS(self.delay2) then
				self.ToSettle = false
				self.ToDelete = true
			end
		end
	else
		self.ToSettle = false
	end
	if self.target ~= nil then
		local MO = MovableMan:GetMOFromID(self.target.RootID)
		if MovableMan:IsActor(MO) then
			MO = ToActor(MO)
			if MO.Team ~= self.Team then
				if not self.lifeTimer:IsPastSimMS(self.delay3) then
					if self.burnTimer:IsPastSimMS(self.random + ((MO.Mass ^ 2) / 40)) then
						self.random = math.random(300)
						if MO.Health > 0 then
							MO.Health = MO.Health - 1
						end
						self.burnTimer:Reset()
					end
				end
			end
		end
	end
end
