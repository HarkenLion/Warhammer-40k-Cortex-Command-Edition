function Create(self)
	self.recoil = 0
	self.recoiltimer = Timer()

	self.Scale = 0.95
end

function OnFire(self)
	local sfx = CreateAEmitter("Pulse Rifle Muzzle Flash")
	sfx.Pos = self.MuzzlePos

	if self.HFlipped then
		sfx.RotAngle = self.RotAngle + math.pi
	else
		sfx.RotAngle = self.RotAngle
	end

	sfx.Team = self.Team
	sfx.IgnoresTeamHits = true
	MovableMan:AddParticle(sfx)

	if self.recoil < 1 then
		self.recoil = self.recoil + 0.1
	end

	self.recoiltimer:Reset()
	local randomy = math.random(-47, 47)
	local scattery = randomy * self.recoil

	local vect = Vector(2505, scattery)
	vect = vect:RadRotate(sfx.RotAngle)
	vect = vect:SetMagnitude(2505)
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

		local pulseexplosion = CreateAEmitter("Pulse Rifle Explosion", "Tau.rte")
		pulseexplosion.RotAngle = sfx.RotAngle
		pulseexplosion.Pos = hitpos
		pulseexplosion.Team = self.Team
		pulseexplosion.IgnoresTeamHits = true
		MovableMan:AddParticle(pulseexplosion)

		local Range = SceneMan:ShortestDistance(self.MuzzlePos, pulseexplosion.Pos, false)
		local angle = Range.AbsRadAngle
		local distance = Range.Magnitude

		self.RotAngle = angle

		local firevel = distance * 0.15

		if firevel < 105 then
			firevel = 105
		end

		local trail = CreateMOPixel("Pulse Impact Trail")
		trail.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.75, 0))
		trail.Vel = Vector(firevel, 0):RadRotate(angle)

		local trail2 = CreateMOPixel("Pulse Impact Trail 2")
		trail2.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.78, 0))
		trail2.Vel = Vector(firevel + 2, 0):RadRotate(angle)

		local trail3 = CreateMOPixel("Pulse Impact Trail 3")
		trail3.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.780, 0))
		trail3.Vel = Vector(firevel + 3, 0):RadRotate(angle)

		if self.HFlipped then
			trail.Pos = self.MuzzlePos - self:RotateOffset(Vector(distance * 0.75, 0))
			trail2.Pos = self.MuzzlePos - self:RotateOffset(Vector(distance * 0.78, 0))
			trail3.Pos = self.MuzzlePos - self:RotateOffset(Vector(distance * 0.780, 0))
		end

		trail.Team = self.Team
		trail.IgnoresTeamHits = true

		trail2.Team = self.Team
		trail2.IgnoresTeamHits = true

		trail3.Team = self.Team
		trail3.IgnoresTeamHits = true

		trail.Team = self.Team
		trail.IgnoresTeamHits = true
		trail2.Team = self.Team
		trail2.IgnoresTeamHits = true
		trail3.Team = self.Team
		trail3.IgnoresTeamHits = true

		MovableMan:AddParticle(trail)
		MovableMan:AddParticle(trail2)
		MovableMan:AddParticle(trail3)

		local smoke = CreateMOSParticle("Small Smoke Ball 1", "Base.rte")
		smoke.Pos = SceneMan:GetLastRayHitPos()
		MovableMan:AddParticle(smoke)
		local smoke = CreateMOSParticle("Explosion Smoke Small Short", "Tau.rte")
		smoke.Pos = SceneMan:GetLastRayHitPos()
		MovableMan:AddParticle(smoke)

		local shortglow = CreateMOPixel("Particle Flame Glow Short", "Tau.rte")
		shortglow.Pos = SceneMan:GetLastRayHitPos()
		MovableMan:AddParticle(shortglow)
	end

	--END WEAPON DISCHARGE
end

function ThreadedUpdate(self)
	if self.ID ~= self.RootID then
		if self.Magazine ~= nil then
			local recoil = self.recoil
			if self.recoiltimer:IsPastSimMS(200) then
				if recoil > 0 then
					self.recoil = recoil - 0.002
				elseif recoil < 0 then
					self.recoil = 0
				end
			end
		end
	end
end
