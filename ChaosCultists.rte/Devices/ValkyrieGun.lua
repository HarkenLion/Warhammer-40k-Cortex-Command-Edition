function Create(self)
	self.recoil = 0
	self.firecounter = 0
	self.recoilcooldown = 0.00005
	self.firetimer = Timer()
	self.Scale = 0.95
end

function OnFire(self)
	if self.RootID ~= self.ID then
		local recoil2 = self.recoil
		if recoil2 < 0.024 then
			self.recoil = recoil2 + 0.0009 + 1 * 0.65 * 0.0005
			self.firetimer:Reset()
		end

		local sfx = CreateAEmitter("Las Muzzle Flash")
		sfx.Pos = self.MuzzlePos

		if self.HFlipped then
			sfx.RotAngle = self.RotAngle + math.pi
		else
			sfx.RotAngle = self.RotAngle
		end

		sfx.Team = self.Team
		sfx.IgnoresTeamHits = true

		MovableMan:AddParticle(sfx)

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

		if rayL > 0 then
			local hitpos = SceneMan:GetLastRayHitPos()

			local Range = SceneMan:ShortestDistance(self.MuzzlePos, hitpos, false)
			local angle = Range.AbsRadAngle

			local pulseexplosion = CreateMOPixel("Rifle Las Particle Hit")
			pulseexplosion.Pos = hitpos
			pulseexplosion.Team = self.Team
			pulseexplosion.Vel = Vector(110, 0):RadRotate(angle)
			pulseexplosion.IgnoresTeamHits = true
			MovableMan:AddParticle(pulseexplosion)

			local pulseexplosion2 = CreateMOPixel("Rifle Las Particle Light Hit")
			pulseexplosion2.Pos = hitpos
			pulseexplosion2.Team = self.Team
			pulseexplosion2.Vel = Vector(120, 0):RadRotate(angle)
			pulseexplosion2.IgnoresTeamHits = true
			MovableMan:AddParticle(pulseexplosion2)

			PrimitiveMan:DrawLinePrimitive(self.MuzzlePos, hitpos, 13, 2)

			local smoke = CreateMOPixel("Rifle Las Contact Flash Hellgun")
			smoke.Pos = SceneMan:GetLastRayHitPos()
			MovableMan:AddParticle(smoke)

			local smoke2 = CreateMOSParticle("Small Smoke Ball 1", "Base.rte")
			smoke2.Pos = SceneMan:GetLastRayHitPos()
			MovableMan:AddParticle(smoke2)
		else
			PrimitiveMan:DrawLinePrimitive(self.MuzzlePos, self.MuzzlePos + self:RotateOffset(Vector(1900, 0)), 13, 2)
		end
		--END WEAPON DISCHARGE
	end
end

function Update(self)
	if self:IsReloading() then
		self.recoil = 0
	end

	if MovableMan:ValidMO(self.Magazine) then
		local randb = math.random(-4, 4)
		local recoil = self.recoil
		local recoilrand = randb * recoil

		self.RotAngle = self.RotAngle + recoilrand

		if self.firetimer:IsPastSimMS(80) then
			if recoil > 0 then
				self.recoil = recoil - self.recoilcooldown
			elseif recoil < 0 then
				self.recoil = 0
			end
		end
	end
end
