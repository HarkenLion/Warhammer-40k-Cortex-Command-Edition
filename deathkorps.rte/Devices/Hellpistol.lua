function Create(self)
	self.recoil = 0
	self.firecounter = 0
	self.recoilcooldown = 0.00006
	self.firetimer = Timer()
	self.Scale = 0.95
end

function OnFire(self)
	local recoil2 = self.recoil
	if recoil2 < 0.024 then
		local user
		user = MovableMan:GetMOFromID(self.RootID)

		self.recoil = recoil2 + 0.0009 + (4 - user.Sharpness) * 0.65 * 0.0005
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

	if rayL > -1 then
		local hitpos = SceneMan:GetLastRayHitPos()

		local Range = SceneMan:ShortestDistance(self.MuzzlePos, hitpos, false)
		local angle = Range.AbsRadAngle
		local distance = Range.Magnitude

		local pulseexplosion2 = CreateMOPixel("Rifle Las Particle Light Hit")
		pulseexplosion2.Pos = hitpos
		pulseexplosion2.Team = self.Team
		pulseexplosion2.Vel = Vector(120, 0):RadRotate(angle)
		pulseexplosion2.IgnoresTeamHits = true
		MovableMan:AddParticle(pulseexplosion2)

		local pulseexplosion2 = CreateMOPixel("Rifle Las Particle Light Hit")
		pulseexplosion2.Pos = hitpos
		pulseexplosion2.Team = self.Team
		pulseexplosion2.Vel = Vector(120, 0):RadRotate(angle)
		pulseexplosion2.IgnoresTeamHits = true
		MovableMan:AddParticle(pulseexplosion2)

		PrimitiveMan:DrawLinePrimitive(self.MuzzlePos, self.MuzzlePos + Range, 13,2)

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

function OnReload(self)
	self.recoil = 0
end

function Update(self)
	if self.RootID ~= self.ID then
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
					local user
					user = MovableMan:GetMOFromID(self.RootID)
					self.recoil = recoil - (self.recoilcooldown * user.Sharpness)
				elseif recoil < 0 then
					self.recoil = 0
				end
			end
		end
	end
end
