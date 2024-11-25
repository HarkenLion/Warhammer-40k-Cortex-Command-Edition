function Create(self)
	self.fireTimer = Timer()
	self.rechargeTimer = Timer()
	self.negatore = 1
	self.fired = false
	self.ammoCounter = 35

	self.damageParNum = 9 --2;

	self.fireDelay = 20
	self.rechargeDelay = 105 -- 175; --75;

	self.Magazine.RoundCount = self.ammoCounter
end

function Update(self)
	if self.ID ~= self.RootID then
		if self.HFlipped == false then
			self.negatore = 1
			self.RotAngle = self.RotAngle - 0.95
		else
			self.negatore = -1
			self.RotAngle = self.RotAngle + 0.95
		end

		self.Pos = self.Pos + Vector(12 * self.negatore, -2):RadRotate(self.RotAngle)

		if MovableMan:IsParticle(self.beamSound) then
			self.beamSound.ToDelete = false
			self.beamSound.ToSettle = false
			self.beamSound.PinStrength = 1000
			self.beamSound.Pos = self.MuzzlePos
			if self:IsActivated() and self.ammoCounter > 1 then
				self.beamSound:EnableEmission(true)
			else
				self.beamSound:EnableEmission(false)
			end
		end

		if self:IsActivated() then
			if self.ammoCounter > 1 then
				if self.fireTimer:IsPastSimMS(self.fireDelay) then
					self.fireTimer:Reset()
					self.ammoCounter = self.ammoCounter - 1

					local trail = CreateMOPixel("Gauss Staff Lightning Particle")
					trail.Pos = self.MuzzlePos
					trail.Vel = Vector(5 * self.negatore, -15):RadRotate(self.RotAngle)
					trail.Team = self.Team
					trail.IgnoresTeamHits = true
					MovableMan:AddParticle(trail)
				end
				self.fired = true
			else
				self:Deactivate()
			end
		else
			if self.fired == true then
				self.rechargeTimer:Reset()
				self.fired = false
			end
			if self.rechargeTimer:IsPastSimMS(self.rechargeDelay) and self.ammoCounter < 75 then
				self.rechargeTimer:Reset()
				self.ammoCounter = self.ammoCounter + 1
			end
		end

		if self.Magazine ~= nil then
			self.Magazine.RoundCount = self.ammoCounter
		end
	end
end
