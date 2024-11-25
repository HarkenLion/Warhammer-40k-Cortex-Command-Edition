function Create(self)
	self.recoil = 0
	self.firecounter = 0
	self.recoilcooldown = 0.00005
	self.firetimer = Timer()

	self.chargeup = false
	self.startcharge = true
	self.chargenum = 0
	self.fireSound = CreateSoundContainer("Lasgun Fire", "deathkorps.rte")
	self.fireSoundBig = CreateSoundContainer("Lasgun Big Fire", "deathkorps.rte")
	self.chargeSound = CreateSoundContainer("Lasgun Charge", "deathkorps.rte")

	function self.DischargeGun()
		self.fireSound:Play(self.Pos)
		local recoil2 = self.recoil
		if recoil2 < 0.024 then
			local actor = MovableMan:GetMOFromID(self.RootID)
			self.recoil = recoil2 + 0.0009 + (4 - actor.Sharpness) * 0.65 * 0.0005
			self.firetimer:Reset()
		end

		local sfx = CreateAEmitter("Las Muzzle Flash", "deathkorps.rte")
		sfx.Pos = self.MuzzlePos
		if self.HFlipped then
			sfx.RotAngle = self.RotAngle + math.pi
		else
			sfx.RotAngle = self.RotAngle
		end
		sfx.Team = self.Team
		sfx.IgnoresTeamHits = true
		MovableMan:AddParticle(sfx)

		if self.chargenum > 1 then
			local framenum = math.random(1, 5)
			local effectPar = CreateMOSParticle("Lasgun Discharge " .. framenum, "deathkorps.rte")
			effectPar.Pos = self.MuzzlePos
			effectPar.RotAngle = sfx.RotAngle
			effectPar.Scale = self.chargenum * 0.125
			MovableMan:AddParticle(effectPar)
		end

		local vect = Vector(1905, 0)
		vect = vect:RadRotate(sfx.RotAngle)
		vect = vect:SetMagnitude(1905)
		rayL = SceneMan:CastObstacleRay(
			Vector(self.MuzzlePos.X, self.MuzzlePos.Y),
			vect,
			vect,
			vect,
			self.ID,
			self.Team,
			0,
			3
		)

		--WEAPON DISCHARGE

		if rayL > -1 then
			local hitpos = SceneMan:GetLastRayHitPos()
			local Range = SceneMan:ShortestDistance(self.MuzzlePos, hitpos, true)
			local angle = Range.AbsRadAngle

			for i = 0, 1 + self.chargenum do
				local pulseexplosion = CreateMOPixel("Rifle Las Particle Light Hit", "deathkorps.rte")
				pulseexplosion.Pos = hitpos
				pulseexplosion.Team = self.Team
				pulseexplosion.Vel = Vector(115, 0):RadRotate(angle)
				pulseexplosion.Mass = pulseexplosion.Mass + self.chargenum * 0.015
				pulseexplosion.IgnoresTeamHits = true
				MovableMan:AddParticle(pulseexplosion)

				local pulseexplosion = CreateMOPixel("Rifle Las Particle Hit")
				pulseexplosion.Pos = hitpos
				pulseexplosion.Team = self.Team
				pulseexplosion.Vel = Vector(110, 0):RadRotate(angle)
				pulseexplosion.Mass = pulseexplosion.Mass + self.chargenum * 0.015
				pulseexplosion.IgnoresTeamHits = true
				MovableMan:AddParticle(pulseexplosion)
			end
			PrimitiveMan:DrawLinePrimitive(self.MuzzlePos, self.MuzzlePos + Range, 48, 1 + self.chargenum * 1.2) --PrimitiveMan:DrawLinePrimitive(self.MuzzlePos, hitpos, 48, 1 + self.chargenum * 1.2)

			local smoke = CreateMOPixel("Rifle Las Contact Flash")
			smoke.Pos = SceneMan:GetLastRayHitPos()
			MovableMan:AddParticle(smoke)

			local smoke2 = CreateMOSParticle("Small Smoke Ball 1", "Base.rte")
			smoke2.Pos = SceneMan:GetLastRayHitPos()
			MovableMan:AddParticle(smoke2)
		else
			PrimitiveMan:DrawLinePrimitive(
				self.MuzzlePos,
				self.MuzzlePos + self:RotateOffset(Vector(1900, 0)),
				48,
				1 + self.chargenum * 1.2
			)
		end
		if self.chargenum >= 1 then
			self.fireSoundBig:Play(self.Pos)
			self.chargeSound:Stop()
			self.Magazine.RoundCount = self.Magazine.RoundCount - 1
		end

		self.chargenum = 0
		self.startcharge = false

		--END WEAPON DISCHARGE
	end
end

function OnFire(self)
	if self.Magazine and (self.chargenum <= 0 or self.chargenum >= 2 or self.Magazine.RoundCount == 0) then
		self.Magazine.RoundCount = self.Magazine.RoundCount + 1
	end
end

function OnReload(self)
	self.recoil = 0
end

function Update(self)
	local parent = self:GetRootParent()
	if parent and IsAHuman(parent) then
		parent = ToAHuman(parent)
		if self.Magazine then
			local recoilrand = 0
			local recoil = self.recoil
			if recoil > 0 then
				local randb = math.random(-4, 4)
				recoilrand = randb * recoil
			end
			self.RotAngle = self.RotAngle + recoilrand

			if self.firetimer:IsPastSimMS(80) then
				if recoil > 0 then
					self.recoil = recoil - (self.recoilcooldown * parent.Sharpness)
				elseif recoil < 0 then
					self.recoil = 0
				end
			end

			if parent:IsPlayerControlled() == false then
				if self.chargenum >= 1.5 then
					self:Deactivate()
				end
			end

			if self:IsActivated() then
				if self.startcharge == false then
					self.chargeSound:Play(self.Pos)
					self.startcharge = true
				end
				if self.chargenum < 3 and self.Magazine.RoundCount > 0 then
					self.chargenum = self.chargenum + 0.05
				end
				if self.chargenum >= 1 then
					local framenum = math.max(math.min(math.random(-2, 2) + math.floor(self.chargenum * 3), 9), 1)
					local effectPar = CreateMOPixel("Lucius Lasgun Charge Effect Particle " .. framenum)
					effectPar.Pos = self.MuzzlePos
					MovableMan:AddParticle(effectPar)
				end
			else
				if self.firetimer:IsPastSimMS(155) and self.chargenum > 0 then
					self.DischargeGun()
				end
			end
		end
	end
end
