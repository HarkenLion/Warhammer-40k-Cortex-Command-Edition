function Create(self)
	self.parentSet = false

	-- Sounds --
	self.stopSound = CreateSoundContainer("Stop Tazer", "chaosspacemarines.rte")

	self.startSound = CreateSoundContainer("Start Tazer", "chaosspacemarines.rte")

	self.reflectionSound = CreateSoundContainer("Reflection Tazer", "chaosspacemarines.rte")

	self.magInPrepareSound = CreateSoundContainer("MagInPrepare Tazer", "chaosspacemarines.rte")

	self.magInSound = CreateSoundContainer("MagIn Tazer", "chaosspacemarines.rte")

	self.boltBackPrepareSound = CreateSoundContainer("BoltBackPrepare Tazer", "chaosspacemarines.rte")

	self.boltBackSound = CreateSoundContainer("BoltBack Tazer", "chaosspacemarines.rte")

	self.boltForwardPrepareSound = CreateSoundContainer("BoltForwardPrepare Tazer", "chaosspacemarines.rte")

	self.boltForwardSound = CreateSoundContainer("BoltForward Tazer", "chaosspacemarines.rte")

	self.lastAge = self.Age

	self.originalSharpLength = self.SharpLength

	self.originalStanceOffset = Vector(math.abs(self.StanceOffset.X), self.StanceOffset.Y)
	self.originalSharpStanceOffset = Vector(self.SharpStanceOffset.X, self.SharpStanceOffset.Y)

	self.rotation = 0
	self.rotationTarget = 0
	self.rotationSpeed = 9

	self.horizontalAnim = 0
	self.verticalAnim = 0

	self.angVel = 0
	self.lastRotAngle = self.RotAngle

	self.smokeTimer = Timer()
	self.smokeDelayTimer = Timer()
	self.canSmoke = false

	self.reloadTimer = Timer()

	self.triggerPulled = false
	self.shotCounter = 0

	self.boltBackPrepareDelay = 350
	self.boltBackAfterDelay = 1000
	self.magInPrepareDelay = 350
	self.magInAfterDelay = 300
	self.boltForwardPrepareDelay = 300
	self.boltForwardAfterDelay = 1000

	-- phases:
	-- 0 boltback
	-- 1 magin
	-- 2 boltforward

	self.reloadPhase = 0

	self.BaseReloadTime = 9999

	-- Progressive Recoil System
	self.recoilAcc = 0 -- for sinous
	self.recoilStr = 0 -- for accumulator
	self.recoilStrength = 3 -- multiplier for base recoil added to the self.recoilStr when firing
	self.recoilPowStrength = 0 -- multiplier for self.recoilStr when firing
	self.recoilRandomUpper = 2 -- upper end of random multiplier (1 is lower)
	self.recoilDamping = 1.2

	self.recoilMax = 1 -- in deg.
	self.originalSharpLength = self.SharpLength
	-- Progressive Recoil System
end

function ThreadedUpdate(self)
	self.rotationTarget = 0 -- ZERO IT FIRST AAAA!!!!!

	if self.ID == self.RootID then
		self.parent = nil
		self.parentSet = false
	elseif self.parentSet == false then
		local actor = MovableMan:GetMOFromID(self.RootID)
		if actor and IsAHuman(actor) then
			self.parent = ToAHuman(actor)
			self.parentSet = true
		end
	end

	-- Smoothing
	local min_value = -math.pi
	local max_value = math.pi
	local value = self.RotAngle - self.lastRotAngle
	local result
	local ret = 0

	local range = max_value - min_value
	if range <= 0 then
		result = min_value
	else
		ret = (value - min_value) % range
		if ret < 0 then
			ret = ret + range
		end
		result = ret + min_value
	end

	self.lastRotAngle = self.RotAngle
	self.angVel = (result / TimerMan.DeltaTimeSecs) * self.FlipFactor

	if self.lastHFlipped ~= nil then
		if self.lastHFlipped ~= self.HFlipped then
			self.lastHFlipped = self.HFlipped
			self.angVel = 0
		end
	else
		self.lastHFlipped = self.HFlipped
	end

	-- TEST
	--if self.Magazine then self.Magazine.RoundCount = -1 end
	-- TEST

	-- PAWNIS RELOAD ANIMATION HERE
	if self:IsReloading() then
		if self.reloadPhase == 0 then
			self.Frame = 0
			self.reloadDelay = self.boltBackPrepareDelay
			self.afterDelay = self.boltBackAfterDelay
			self.prepareSound = self.boltBackPrepareSound
			self.afterSound = self.boltBackSound

			self.rotationTarget = 5
		elseif self.reloadPhase == 1 then
			self.Frame = 4
			self.reloadDelay = self.magInPrepareDelay
			self.afterDelay = self.magInAfterDelay
			self.prepareSound = self.magInPrepareSound
			self.afterSound = self.magInSound

			self.rotationTarget = 5
		elseif self.reloadPhase == 2 then
			self.Frame = 5
			self.reloadDelay = self.boltForwardPrepareDelay
			self.afterDelay = self.boltForwardAfterDelay
			self.prepareSound = self.boltForwardPrepareSound
			self.afterSound = self.boltForwardSound

			self.rotationTarget = 2
		end

		if self.prepareSoundPlayed ~= true then
			self.prepareSoundPlayed = true
			if self.prepareSound then
				self.prepareSound:Play(self.Pos)
			end
		end

		if self.reloadTimer:IsPastSimMS(self.reloadDelay) then
			if self.reloadPhase == 0 then
				self:SetNumberValue("MagRemoved", 1)

				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay / 5) * 0.9)) then
					self.Frame = 4
					self.coverBack = true
					self.phaseOnStop = 1
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay / 5) * 0.6)) then
					self.Frame = 3
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay / 5) * 0.4)) then
					self.Frame = 2
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay / 5) * 0.3)) then
					self.Frame = 1
				end
			elseif self.reloadPhase == 1 then
				self:RemoveNumberValue("MagRemoved")
				self.magInside = true
				self.phaseOnStop = 2
				self.Frame = 5
			elseif self.reloadPhase == 2 then
				if self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay / 5) * 0.9)) then
					self.Frame = 0
					self.coverBack = false
					self.magInside = false
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay / 5) * 0.7)) then
					self.Frame = 10
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay / 5) * 0.6)) then
					self.Frame = 9
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay / 5) * 0.5)) then
					self.Frame = 8
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay / 5) * 0.4)) then
					self.Frame = 7
				elseif self.reloadTimer:IsPastSimMS(self.reloadDelay + ((self.afterDelay / 5) * 0.2)) then
					self.Frame = 6
				end
			end

			if self.afterSoundPlayed ~= true then
				if self.reloadPhase == 0 then
					self.phaseOnStop = 1
					local fake
					fake = CreateMOSRotating("Battery MOSRotating Tazer")
					fake.Pos = self.Pos + Vector(-0.5 * self.FlipFactor, 0):RadRotate(self.RotAngle)
					fake.Vel = self.Vel + Vector(0.5 * self.FlipFactor, -6):RadRotate(self.RotAngle)
					fake.RotAngle = self.RotAngle
					fake.AngularVel = self.AngularVel + (-1 * self.FlipFactor)
					fake.HFlipped = self.HFlipped
					MovableMan:AddParticle(fake)

					self.angVel = self.angVel + 2
					self.verticalAnim = self.verticalAnim + 1
				elseif self.reloadPhase == 1 then
					self.phaseOnStop = 2
					self.angVel = self.angVel - 2
					self.verticalAnim = self.verticalAnim - 1
					self:RemoveNumberValue("MagRemoved")
				elseif self.reloadPhase == 2 then
					self.horizontalAnim = self.horizontalAnim + 1
					self.angVel = self.angVel + 4
					self.phaseOnStop = nil
				else
					self.phaseOnStop = nil
				end

				self.afterSoundPlayed = true
				if self.afterSound then
					self.afterSound:Play(self.Pos)
				end
			end
			if self.reloadTimer:IsPastSimMS(self.reloadDelay + self.afterDelay) then
				self.reloadTimer:Reset()
				self.afterSoundPlayed = false
				self.prepareSoundPlayed = false
				if self.reloadPhase == 2 then
					self.BaseReloadTime = 0
					self.reloadPhase = 0
				else
					self.reloadPhase = self.reloadPhase + 1
				end
			end
		end
	else
		self.BaseReloadTime = 9999
		self.reloadTimer:Reset()
	end

	-- PAWNIS RELOAD ANIMATION HERE

	if self.prepareSound then
		self.prepareSound.Pos = self.Pos
	end

	if self.afterSound then
		self.afterSound.Pos = self.Pos
	end

	if self:IsActivated() and self.RoundInMagCount > 0 then
		self.reflectionSound:Stop(-1)
		self.stopSound:Stop(-1)
		if self.triggerPulled ~= true then
			self.triggerPulled = true
			self.startSound:Play(self.Pos)
		end
	else
		if self.triggerPulled == true then
			self.triggerPulled = false

			self.stopSound:Play(self.Pos)

			local outdoorRays = 0

			local indoorRays = 0

			local bigIndoorRays = 0

			if self.parent and self.parent:IsPlayerControlled() then
				self.rayThreshold = 2 -- this is the first ray check to decide whether we play outdoors
				local Vector2 = Vector(0, -700) -- straight up
				local Vector2Left = Vector(0, -700):RadRotate(45 * (math.pi / 180))
				local Vector2Right = Vector(0, -700):RadRotate(-45 * (math.pi / 180))
				local Vector2SlightLeft = Vector(0, -700):RadRotate(22.5 * (math.pi / 180))
				local Vector2SlightRight = Vector(0, -700):RadRotate(-22.5 * (math.pi / 180))
				local Vector3 = Vector(0, 0) -- dont need this but is needed as an arg
				local Vector4 = Vector(0, 0) -- dont need this but is needed as an arg

				self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7)
				self.rayRight = SceneMan:CastObstacleRay(
					self.Pos,
					Vector2Right,
					Vector3,
					Vector4,
					self.RootID,
					self.Team,
					128,
					7
				)
				self.rayLeft = SceneMan:CastObstacleRay(
					self.Pos,
					Vector2Left,
					Vector3,
					Vector4,
					self.RootID,
					self.Team,
					128,
					7
				)
				self.raySlightRight = SceneMan:CastObstacleRay(
					self.Pos,
					Vector2SlightRight,
					Vector3,
					Vector4,
					self.RootID,
					self.Team,
					128,
					7
				)
				self.raySlightLeft = SceneMan:CastObstacleRay(
					self.Pos,
					Vector2SlightLeft,
					Vector3,
					Vector4,
					self.RootID,
					self.Team,
					128,
					7
				)

				self.rayTable = { self.ray, self.rayRight, self.rayLeft, self.raySlightRight, self.raySlightLeft }
			else
				self.rayThreshold = 1 -- has to be different for AI
				local Vector2 = Vector(0, -700) -- straight up
				local Vector3 = Vector(0, 0) -- dont need this but is needed as an arg
				local Vector4 = Vector(0, 0) -- dont need this but is needed as an arg
				self.ray = SceneMan:CastObstacleRay(self.Pos, Vector2, Vector3, Vector4, self.RootID, self.Team, 128, 7)

				self.rayTable = { self.ray }
			end

			for _, rayLength in ipairs(self.rayTable) do
				if rayLength < 0 then
					outdoorRays = outdoorRays + 1
				elseif rayLength > 170 then
					bigIndoorRays = bigIndoorRays + 1
				else
					indoorRays = indoorRays + 1
				end
			end

			if outdoorRays >= self.rayThreshold then
				self.reflectionSound:Play(self.Pos)
			end
		end
	end

	if self.FiredFrame then
		self.canSmoke = true
		self.smokeTimer:Reset()
	end

	-- Animation
	if self.parent then
		self.horizontalAnim = math.floor(self.horizontalAnim / (1 + TimerMan.DeltaTimeSecs * 24.0) * 1000) / 1000
		self.verticalAnim = math.floor(self.verticalAnim / (1 + TimerMan.DeltaTimeSecs * 15.0) * 1000) / 1000

		local stance = Vector()
		stance = stance + Vector(-1, 0) * self.horizontalAnim -- Horizontal animation
		stance = stance + Vector(0, 5) * self.verticalAnim -- Vertical animation

		self.rotationTarget = self.rotationTarget - (self.angVel * 4)

		-- Progressive Recoil Update
		if self.FiredFrame then
			self.recoilStr = self.recoilStr
				+ ((math.random(10, self.recoilRandomUpper * 10) / 10) * 0.5 * self.recoilStrength)
				+ (self.recoilStr * 0.6 * self.recoilPowStrength)
			self:SetNumberValue(
				"recoilStrengthBase",
				self.recoilStrength * (1 + self.recoilPowStrength) / self.recoilDamping
			)
		end
		self:SetNumberValue("recoilStrengthCurrent", self.recoilStr)

		self.recoilStr = math.floor(self.recoilStr / (1 + TimerMan.DeltaTimeSecs * 8.0 * self.recoilDamping) * 1000)
			/ 1000
		self.recoilAcc = (self.recoilAcc + self.recoilStr * TimerMan.DeltaTimeSecs) % (math.pi * 4)

		local recoilA = (math.sin(self.recoilAcc) * self.recoilStr) * 0.05 * self.recoilStr
		local recoilB = (math.sin(self.recoilAcc * 0.5) * self.recoilStr) * 0.01 * self.recoilStr
		local recoilC = (math.sin(self.recoilAcc * 0.25) * self.recoilStr) * 0.05 * self.recoilStr

		local recoilFinal = math.max(math.min(recoilA + recoilB + recoilC, self.recoilMax), -self.recoilMax)

		self.SharpLength = math.max(self.originalSharpLength - (self.recoilStr * 3 + math.abs(recoilFinal)), 0)

		self.rotationTarget = self.rotationTarget + recoilFinal -- apply the recoil
		-- Progressive Recoil Update

		self.rotation = (self.rotation + self.rotationTarget * TimerMan.DeltaTimeSecs * self.rotationSpeed)
			/ (1 + TimerMan.DeltaTimeSecs * self.rotationSpeed)
		local total = math.rad(self.rotation) * self.FlipFactor

		self.InheritedRotAngleOffset = total * self.FlipFactor
		-- self.RotAngle = self.RotAngle + total;
		-- self:SetNumberValue("MagRotation", total);

		-- local jointOffset = Vector(self.JointOffset.X * self.FlipFactor, self.JointOffset.Y):RadRotate(self.RotAngle);
		-- local offsetTotal = Vector(jointOffset.X, jointOffset.Y):RadRotate(-total) - jointOffset
		-- self.Pos = self.Pos + offsetTotal;
		-- self:SetNumberValue("MagOffsetX", offsetTotal.X);
		-- self:SetNumberValue("MagOffsetY", offsetTotal.Y);

		self.StanceOffset = Vector(self.originalStanceOffset.X, self.originalStanceOffset.Y) + stance
		self.SharpStanceOffset = Vector(self.originalSharpStanceOffset.X, self.originalSharpStanceOffset.Y) + stance
	end

	if self.canSmoke and not self.smokeTimer:IsPastSimMS(1500) then
		if self.smokeDelayTimer:IsPastSimMS(120) then
			local poof = CreateMOSParticle("Tiny Smoke Ball 1")
			poof.Pos = self.Pos
				+ Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle)
			poof.Lifetime = poof.Lifetime * RangeRand(0.3, 1.3) * 0.9
			poof.Vel = self.Vel * 0.1
			poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4 -- Go up and down
			MovableMan:AddParticle(poof)
			self.smokeDelayTimer:Reset()
		end
	end
end
