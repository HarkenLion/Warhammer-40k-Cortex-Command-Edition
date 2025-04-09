----------------------------------------------------------------------------------------------------------------
------------------- "Small" chunk from the Overheat Script for general use-------------------------------------
----------------------------- This one belongs to the RV-Sniper ------------------------------------------------
----------------------------------------------------------------------------------------------------------------

function Create(self)
	self.barrelHeat = 0
	self.barrelHeatPerBullet = 14
	self.barrelHeatCooling = 1.2
	self.barrelHeatTop = 25
	self.heatTimer = Timer()
	self.heatDelayHeated = 220
	self.heatDelayUnderheat = 140
	self.heatDelay = 160

	self.barrelDarkerSmokeThresold = 8
	self.barrelSmokeHalver = 1
	self.barrelSmokeHalverValue = 0.1

	self.muzzleSmokeTimer = Timer()
	self.muzzleSmokeDelay = 400
	self.muzzleDarkerSmokeDelay = 350
	self.muzzleSmokeChance = 0.001
	self.muzzleDarkerSmokeChance = 0.015
end

function Update(self)
	if self.barrelHeat > 0 then
		if self.muzzleSmokeTimer:IsPastSimMS(self.muzzleSmokeDelay) then
			if math.random() < (self.muzzleSmokeChance * self.barrelHeat * self.barrelSmokeHalver) then
				local smokefx = CreateMOSParticle("Guard Tiny Gun Smoke Ball Light 1", "ImporianArmada.rte")
				smokefx.Pos = self.MuzzlePos + Vector(-1 * self.FlipFactor, 0):RadRotate(self.RotAngle)
				smokefx.Vel = self.Vel / 8
					+ Vector((math.random(65, 110) / 100) * self.FlipFactor, 0):RadRotate(self.RotAngle)
				smokefx.Lifetime = smokefx.Lifetime * RangeRand(0.5, 1.5) * 1.5
				MovableMan:AddParticle(smokefx)
			end
		end

		if self.barrelHeat > self.barrelDarkerSmokeThresold then
			if self.muzzleSmokeTimer:IsPastSimMS(self.muzzleDarkerSmokeDelay) then
				if
					math.random()
					< self.muzzleDarkerSmokeChance * (self.barrelHeat - self.barrelDarkerSmokeThresold)
				then
					local smokefx = CreateMOSParticle("Guard Tiny Gun Smoke Ball 1", "ImporianArmada.rte")
					smokefx.Pos = self.MuzzlePos + Vector(-1 * self.FlipFactor, 0):RadRotate(self.RotAngle)
					smokefx.Vel = self.Vel / 8
						+ Vector((math.random(70, 120) / 100) * self.FlipFactor, 0):RadRotate(self.RotAngle)
					smokefx.Lifetime = smokefx.Lifetime * RangeRand(0.5, 1.5) * 1.5
					MovableMan:AddParticle(smokefx)
				end
			end
		end
	end

	if self.barrelHeat > self.barrelDarkerSmokeThresold then
		self.barrelSmokeHalver = self.barrelSmokeHalverValue
	else
		self.barrelSmokeHalver = 1
	end

	if self.barrelHeat > self.barrelDarkerSmokeThresold then
		self.heatDelay = self.heatDelayHeated --Slower Cooling if Heated
	elseif self.barrelHeat <= self.barrelDarkerSmokeThresold then
		self.heatDelay = self.heatDelayUnderheat --Quicker cooling if not overheated
	end

	if self.barrelHeat > 0 and self.heatTimer:IsPastSimMS(self.heatDelay) then --Time to cool
		self.heatTimer:Reset()
		self.barrelHeat = self.barrelHeat - self.barrelHeatCooling
		if self.barrelHeat < 0 then
			self.barrelHeat = 0
		end
	end

	if self.FiredFrame then --We firing, we hot
		self.muzzleSmokeTimer:Reset()
		self.heatTimer:Reset()
		self.barrelHeat = self.barrelHeat + self.barrelHeatPerBullet
	end

	if self.barrelHeat > self.barrelHeatTop then
		self.barrelHeat = self.barrelHeatTop
	end
end
