function Create(self)
	self.lifeTimer = Timer()
	self.turnTimer = Timer()
	self.delayTimer = Timer()

	self.started = false

	self.Vel = self.Vel * RangeRand(0.95, 1.05) + Vector(0, -math.random())

	self.raylength = 30
	self.rayPixSpace = 5

	self.dots = math.floor(self.raylength / self.rayPixSpace)

	self:EnableEmission(false)
	self.smokeCounter = 2
	self.startTime = math.random(200)
end

function Update(self)
	if self.smokeCounter == 3 then
		if self.turnTimer:IsPastSimMS(math.random(100)) then
			self.AngularVel = (self.AngularVel * 0.60) + (math.sqrt(self.Age) / 15 * math.random(-1, 1))
			self.turnTimer:Reset()
		end
	end
	--[[
	local Effect
	local Offset = self.Vel*(20*TimerMan.DeltaTimeSecs)

	local trailLength = math.floor(Offset.Magnitude+0.5)
	for i = 1, trailLength, 6 do
		Effect = CreateMOSParticle("Launcher Trail Smoke " .. math.random(self.smokeCounter), "Untitled.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset * (i/trailLength) + Vector(RangeRand(-1.0, 1.0), RangeRand(-1.0, 1.0));
			Effect.Vel = (self.Vel * math.random()) + Vector(math.random()*2,0):RadRotate(math.random()*(math.pi*2));
			Effect.Lifetime = Effect.Lifetime + (math.random(200));
			MovableMan:AddParticle(Effect);
		end
	end
]]
	--
	if not self.started then
		if self.lifeTimer:IsPastSimMS(self.startTime) then
			self:EnableEmission(true)
			self.smokeCounter = 3
			self.delayTimer:Reset()
			self.started = true
		end
	end

	if self.target ~= nil and MovableMan:IsActor(self.target) then
		local dist = SceneMan:ShortestDistance(self.Pos, self.target.Pos, SceneMan.SceneWrapsX)
		self.RotAngle = dist.AbsRadAngle
	end

	if self.lifeTimer:IsPastSimMS(self.startTime) then
		for i = 1, self.dots do
			local checkPos = self.Pos + Vector(self.Vel.X, self.Vel.Y):SetMagnitude((i / self.dots) * self.raylength)
			if SceneMan.SceneWrapsX == true then
				if checkPos.X > SceneMan.SceneWidth then
					checkPos = Vector(checkPos.X - SceneMan.SceneWidth, checkPos.Y)
				elseif checkPos.X < 0 then
					checkPos = Vector(SceneMan.SceneWidth + checkPos.X, checkPos.Y)
				end
			end
			local terrCheck = SceneMan:GetTerrMatter(checkPos.X, checkPos.Y)
			if terrCheck == 0 then
				local moCheck = SceneMan:GetMOIDPixel(checkPos.X, checkPos.Y)
				if moCheck ~= 255 then
					local actor = MovableMan:GetMOFromID(MovableMan:GetMOFromID(moCheck).RootID)
					if actor.Team ~= self.Team then
						self.Vel = self.Vel * 0.9
						self:GibThis()
					end
				end
			else
				self.Vel = self.Vel * 0.9
				self:GibThis()
			end
		end
	end

	if self.lifeTimer:IsPastSimMS(1900 + self.startTime) then
		self.Vel = self.Vel * 0.9
		self:GibThis()
	end
end
