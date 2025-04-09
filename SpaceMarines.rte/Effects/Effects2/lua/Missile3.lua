function Create(self)
	self.lifeTimer = Timer() -- life timer, lua-defined destruction at bottom
	self.delayTimer = Timer() -- related to target scan

	self.searchDelay = 100 -- scans for new target every 100 ms... every frame might be laggy
	self.searchRange = 450 * RangeRand(0.90, 1.10) -- the radius of searching for craft, also a slightly random

	self.started = false -- basically this is the same as self:EnableEmission

	self.turnAmount = 4 -- amount of turnage when homing

	self.raylength = RangeRand(25, 35) -- more random ranges	|
	self.rayPixSpace = 5 --			V
	self.dots = math.floor(self.raylength / self.rayPixSpace) -- related to airburst script

	self.adjustTimer = Timer() -- related to homing script
	self.Vel = self.Vel + Vector(0, -1) -- boost slightly upward to make a straight line
	self:EnableEmission(false) -- hold the emission at start (lol hold the fart)
	self.smokeCounter = 2 -- count the smokes; 2 = pre-started, 3 = started
	self.startTime = math.random(200) -- random time without emission at start for even more randomness

	-- thx abdul for some antique sine demo

	self.angle = 3.14 * math.random() -- 180 degrees is ~3.14 rad, equal possibilities of every starting variation
	self.alpha = RangeRand(0.2, 0.3) -- speed of the sway, determined with the change of self.angle value
	self.beta = RangeRand(1.5, 2.5) -- radius of the sway(?)

	self.startBlast = false -- smoke effects on emission, burst is already used on creation afaik
end

function Update(self)
	if self.smokeCounter == 3 and self.target == nil then
		self.angle = self.angle + self.alpha
		self.Pos = self.Pos + self.Vel.Perpendicular.Normalized * (math.sin(self.angle) * self.beta)
	end
	--[[
	local Effect
	local Offset = self.Vel*(20*TimerMan.DeltaTimeSecs)

	local trailLength = math.floor(Offset.Magnitude+0.5)
	for i = 1, trailLength, 6 do
		Effect = CreateMOSParticle("Launcher Trail Smoke " .. math.random(self.smokeCounter), "Untitled.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset * (i/trailLength) + Vector(RangeRand(-1.0, 1.0), RangeRand(-1.0, 1.0));
			Effect.Vel = self.Vel * math.random() + Vector(math.random()*3,0):RadRotate(math.random()*(math.pi*2));
			Effect.Lifetime = Effect.Lifetime*RangeRand(0.75,1.25);
			MovableMan:AddParticle(Effect);
		end
	end
]]
	--
	if self.started then
		if self.startBlast ~= true then -- more smoke effects
			fx = CreateAEmitter("Missile Blast Thing", "Untitled.rte")
			fx.Pos = self.Pos
			fx.Vel = self.Vel * RangeRand(0.25, 0.50)
			MovableMan:AddParticle(fx)

			self.startBlast = true
		end

		if self.target and MovableMan:IsActor(self.target) then
			local dist = SceneMan:ShortestDistance(self.Pos, self.target.Pos, SceneMan.SceneWrapsX) -- assuming a target is already assigned
			local adjustedTurnAmount = self.turnAmount + (self.adjustTimer.ElapsedSimTimeMS / 100) -- adjusting the turn amount based on MS time in between frames
			local adjustVector = Vector(adjustedTurnAmount, 0):RadRotate(dist.AbsRadAngle)
			local oldSpeed = self.Vel.Magnitude

			self.Vel = Vector(self.Vel.X + adjustVector.X, self.Vel.Y + adjustVector.Y):SetMagnitude(oldSpeed)
			self.adjustTimer:Reset()
		elseif self.delayTimer:IsPastSimMS(self.searchDelay) then
			self.delayTimer:Reset()
			local dist = Vector(self.searchRange + 1, 0)
			for actor in MovableMan.Actors do
				if actor.Team ~= self.Team then
					if actor.ClassName == "ACDropShip" or actor.ClassName == "ACRocket" then
						local curdist = SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX)
						if
							curdist.Magnitude < dist.Magnitude
							and SceneMan:CastStrengthRay(
									self.Pos,
									curdist:SetMagnitude(curdist.Magnitude - actor.Radius),
									0,
									Vector(0, 0),
									5,
									0,
									SceneMan.SceneWrapsX
								)
								== false
						then
							self.target = actor
							dist = curdist
						end
					end
				end
			end
		end
	else
		if self.lifeTimer:IsPastSimMS(self.startTime) then
			self:EnableEmission(true)
			self.smokeCounter = 3
			self.delayTimer:Reset()
			self.started = true
		end
	end
	--[[
	if self.target ~= nil and MovableMan:IsActor(self.target) then
		local dist = SceneMan:ShortestDistance(self.Pos,self.target.Pos,SceneMan.SceneWrapsX);
		self.RotAngle = dist.AbsRadAngle;
	end
]]
	--
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
						self.Vel = self.Vel * 0.8
						self:GibThis()
					end
				end
			else
				self.Vel = self.Vel * 0.8
				self:GibThis()
			end
		end
	end

	if self.lifeTimer:IsPastSimMS(2200 + 2 * self.startTime) then
		self.Vel = self.Vel * 0.8
		self:GibThis()
	end
end
