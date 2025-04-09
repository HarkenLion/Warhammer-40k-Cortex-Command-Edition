function Create(self)
	self.recoil = 0
	self.recoiltimer = Timer()
end

function OnFire(self)
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

	if self.recoil < 1.5 then
		self.recoil = self.recoil + 0.021
	end

	self.recoiltimer:Reset()
	local randomy = math.random(-35, 35)
	local scattery = randomy * self.recoil

	local vect = Vector(2275, scattery)
	vect = vect:RadRotate(sfx.RotAngle)
	vect = vect:SetMagnitude(2275)
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
		local pulseexplosion = CreateAEmitter("Pulse Carbine Explosion", "Tau.rte")
		pulseexplosion.RotAngle = sfx.RotAngle
		pulseexplosion.Pos = hitpos
		pulseexplosion.Team = self.Team
		pulseexplosion.IgnoresTeamHits = true
		MovableMan:AddParticle(pulseexplosion)

		local Range = SceneMan:ShortestDistance(self.MuzzlePos, pulseexplosion.Pos, false)
		local angle = Range.AbsRadAngle
		local distance = Range.Magnitude

		self.RotAngle = angle

		local trail = CreateMOPixel("Pulse Impact Trail")
		trail.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.85, 0))

		if self.HFlipped then
			trail.Pos = self.MuzzlePos - self:RotateOffset(Vector(distance * 0.85, 0))
		end

		local firevel = distance * 0.25

		if firevel < 105 then
			firevel = 105
		end

		trail.Vel = Vector(firevel, 0):RadRotate(angle)

		trail.Team = self.Team
		trail.IgnoresTeamHits = true

		MovableMan:AddParticle(trail)

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

function Update(self)
	local root = self.RootID
	if self.ID ~= root then
		root = MovableMan:GetMOFromID(root)
		if root.PresetName == "XV8 Crisis Battlesuit - B" or root.PresetName == "XV8 Crisis Battlesuit" then
			if ToActor(root).HFlipped == false then
				self.RotAngle = ToActor(root):GetAimAngle(true)
			else
				self.RotAngle = (ToActor(root):GetAimAngle(true) + math.pi)
			end
		end

		if self.Magazine ~= nil then
			local recoil = self.recoil
			if self.recoiltimer:IsPastSimMS(350) then
				if recoil > 0 then
					self.recoil = recoil - 0.001
				elseif recoil < 0 then
					self.recoil = 0
				end
			end
		end
	end
end
