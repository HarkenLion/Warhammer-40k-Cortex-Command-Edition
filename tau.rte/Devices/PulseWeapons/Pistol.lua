function Create(self)
	self.recoil = 0
	self.recoiltimer = Timer()

	self.Scale = 0.9
end

function OnFire(self)
	self.recoil = self.recoil + 0.075

	local sfx = CreateAEmitter("Pulse Muzzle Flash")
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
		self.recoil = self.recoil + 0.08
	end

	self.recoiltimer:Reset()

	local scattery = math.random(-20, 20) * self.recoil

	local vect = Vector(1705, scattery)
	vect = vect:RadRotate(sfx.RotAngle)
	vect = vect:SetMagnitude(1705)
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
		local pulseexplosion = CreateAEmitter("Pulse Carbine Explosion", "Tau.rte")
		pulseexplosion.RotAngle = sfx.RotAngle
		pulseexplosion.Pos = SceneMan:GetLastRayHitPos()
		pulseexplosion.Team = self.Team
		pulseexplosion.IgnoresTeamHits = true
		MovableMan:AddParticle(pulseexplosion)

		local Range = SceneMan:ShortestDistance(self.MuzzlePos, pulseexplosion.Pos, false)
		local angle = Range.AbsRadAngle
		local distance = Range.Magnitude

		self.RotAngle = angle

		local firevel = 90

		local trail = CreateMOPixel("Pulse Impact Trail")
		trail.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.8, 0))
		trail.Vel = Vector(firevel, 0):RadRotate(angle)

		local trail2 = CreateMOPixel("Pulse Impact Trail 2")
		trail2.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.825, 0))
		trail2.Vel = Vector(firevel, 0):RadRotate(angle)

		if self.HFlipped then
			trail.Pos = self.MuzzlePos - self:RotateOffset(Vector(distance * 0.8, 0))
			trail2.Pos = self.MuzzlePos - self:RotateOffset(Vector(distance * 0.825, 0))
		end

		trail.Team = self.Team
		trail.IgnoresTeamHits = true

		trail2.Team = self.Team
		trail2.IgnoresTeamHits = true

		MovableMan:AddParticle(trail)
		MovableMan:AddParticle(trail2)

		local smoke = CreateMOSParticle("Small Smoke Ball 1", "Base.rte")
		smoke.Pos = SceneMan:GetLastRayHitPos()
		MovableMan:AddParticle(smoke)
		local smoke = CreateMOSParticle("Explosion Smoke Small Short", "Tau.rte")
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
