function Create(self)
	self.recoil = 0
	self.recoiltimer = Timer()
	self.Scale = 0.85
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

	local vect = Vector(2705, scattery)
	vect = vect:RadRotate(sfx.RotAngle)
	vect = vect:SetMagnitude(2705)
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

		local pulseexplosion = CreateAEmitter("Plasma Rifle Explosion", "Tau.rte")
		pulseexplosion.RotAngle = sfx.RotAngle
		pulseexplosion.Pos = hitpos
		pulseexplosion.Team = self.Team
		pulseexplosion.Vel = Vector(35, 0):RadRotate(sfx.RotAngle)
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

		for actor in MovableMan.Actors do
			local dist = SceneMan:ShortestDistance(SceneMan:GetLastRayHitPos(), actor.Pos, true).Magnitude
			if
				dist < 15
				and actor.PresetName ~= "Charred Skeleton"
				and actor.Team ~= self.Team
				and actor:HasObjectInGroup("Brains") == false
			then
				ToActor(actor).Health = ToActor(actor).Health - 15

				if actor.Health <= 13 then
					if actor.ClassName == "AHuman" and actor.Mass < 91 then
						local charburst = CreateAEmitter("Char Burst")
						charburst.Pos = actor.Pos
						charburst.Vel = actor.Vel
						MovableMan:AddParticle(charburst)

						local flash = CreateMOPixel("Particle Flame Glow Short")
						flash.Pos.X = actor.Pos.X + 5
						flash.Pos.Y = actor.Pos.Y - 5
						flash.Vel = actor.Vel
						MovableMan:AddParticle(flash)

						local charburst = CreateAEmitter("Char Burst")
						charburst.Pos.X = actor.Pos.X + 5
						charburst.Pos.Y = actor.Pos.Y - 5
						charburst.Vel = actor.Vel
						MovableMan:AddParticle(charburst)

						local flash = CreateMOPixel("Particle Flame Glow Short")
						flash.Pos.X = actor.Pos.X + 5
						flash.Pos.Y = actor.Pos.Y - 5
						flash.Vel = actor.Vel
						MovableMan:AddParticle(flash)

						local charburst = CreateAEmitter("Char Burst")
						charburst.Pos.X = actor.Pos.X - 5
						charburst.Pos.Y = actor.Pos.Y + 5
						charburst.Vel = actor.Vel
						MovableMan:AddParticle(charburst)

						local flash = CreateMOPixel("Particle Flame Glow Short")
						flash.Pos.X = actor.Pos.X + 5
						flash.Pos.Y = actor.Pos.Y - 5
						flash.Vel = actor.Vel
						MovableMan:AddParticle(flash)

						local CharredSkeleton = CreateAHuman("Charred Skeleton")
						CharredSkeleton.Pos.X = actor.Pos.X
						CharredSkeleton.Pos.Y = actor.Pos.Y
						CharredSkeleton.Vel.X = actor.Vel.X
						CharredSkeleton.Vel.Y = actor.Vel.Y
						CharredSkeleton.RotAngle = actor.RotAngle
						CharredSkeleton.HFlipped = actor.HFlipped
						CharredSkeleton.AngularVel = actor.AngularVel
						CharredSkeleton.Team = -1
						CharredSkeleton.HitsMOs = false
						CharredSkeleton.GetsHitByMOs = false
						CharredSkeleton.Health = 0
						MovableMan:AddActor(CharredSkeleton)
						actor.ToDelete = true
					end
				end
			end
		end

		local smoke = CreateMOSParticle("Small Smoke Ball 1", "Base.rte")
		smoke.Pos = SceneMan:GetLastRayHitPos()
		MovableMan:AddParticle(smoke)
		local smoke = CreateMOSParticle("Small Smoke Ball 1", "Base.rte")
		smoke.Pos = SceneMan:GetLastRayHitPos()
		MovableMan:AddParticle(smoke)
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

function Update(self)
	local root = self.RootID
	if self.ID ~= self.RootID then
		root = MovableMan:GetMOFromID(root)
		if root.PresetName == "XV8 Crisis Battlesuit - P" or root.PresetName == "XV8 Crisis Battlesuit" then
			if ToActor(root).HFlipped == false then
				self.RotAngle = ToActor(root):GetAimAngle(true)
			else
				self.RotAngle = (ToActor(root):GetAimAngle(true) + math.pi)
			end
		end
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
