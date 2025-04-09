function Create(self)
	self.recoil = 0

	self.ff = false

	self.f0 = ToMagazine(self.Magazine).RoundCount

	self.f1 = ToMagazine(self.Magazine).RoundCount

	self.recoil = 0
	self.recoiltimer = Timer()

	self.Scale = 0.90
end

function Update(self)
	if self.ID ~= self.RootID then
		if self:IsReloading() then
			self.f1 = 0
			self.f0 = 0
		end

		if self.Magazine ~= nil then
			--IF GUN HAS A MAGAZINE

			if self.ff then
				--THIS CHECK CONSTANTLY REFRESHES F0/FF ALTERNATIVELY. FO/FF ASSIGNMENT
				self.f0 = ToMagazine(self.Magazine).RoundCount

				self.ff = false
			else
				self.f1 = ToMagazine(self.Magazine).RoundCount

				self.ff = true
			end

			--END F0/FF ASSIGNMENTS

			if self.f1 ~= self.f0 and ((self.ff == false and self.f1 ~= 0) or (self.ff == true and self.f0 ~= 0)) then --CHECKS TO MAKE SURE YOU DON'T HAVE ZERO AMMO. CHECKS F0/FF AGAINST EACHOTHER. DISCREPANCY INDICATES SHOT FIRED.
				--THIS NEXT BLOCK PRODUCES THE MUZZLE FLASH. YOU NEED THIS BECAUSE IT SETS UP THE ROTATION ANGLE USED IN A RAYCAST LATER
				local sfx = CreateAEmitter("Rail Rifle Muzzle Flash")
				sfx.Pos = self.MuzzlePos

				if self.HFlipped then
					sfx.RotAngle = self.RotAngle + math.pi
				else
					sfx.RotAngle = self.RotAngle
				end

				sfx.Team = self.Team
				sfx.IgnoresTeamHits = true

				MovableMan:AddParticle(sfx)
				--END MUZZLE FLASH

				--HANDLE RECOIL
				if self.recoil < 1 then
					self.recoil = self.recoil + 0.1
				end

				self.recoiltimer:Reset()
				--END RECOIL

				--THIS NEXT BLOCK SETS UP A RAY (COMPUTER TRACKS A STRAIGHT LINE AND DETECTS CERTAIN THINGS).
				local randomy = math.random(-25, 25)
				local scattery = randomy * self.recoil

				local vect = Vector(2105, scattery)
				vect = vect:RadRotate(sfx.RotAngle) --USING THAT MUZZLE FLASH ROTATION ANGLE
				vect = vect:SetMagnitude(2105)

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
				--END RAYCAST

				--FINALLY, THE PART WHERE THE WEAPON FINALLY FIRES
				if rayL > 0 then
					local hitpos = SceneMan:GetLastRayHitPos()
					local pulseexplosion = CreateMOSRotating("Railgun Payload", "Tau.rte")
					pulseexplosion.RotAngle = sfx.RotAngle
					pulseexplosion.Pos = hitpos

					pulseexplosion.Team = self.Team
					pulseexplosion.IgnoresTeamHits = true

					MovableMan:AddParticle(pulseexplosion)

					local Range = SceneMan:ShortestDistance(self.MuzzlePos, pulseexplosion.Pos, false)
					local angle = Range.AbsRadAngle
					local distance = Range.Magnitude

					self.RotAngle = angle

					local trail = CreateAEmitter("Rail Rifle Explosive")
					trail.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.75, 0))
					trail.Vel = Vector(110, 0):RadRotate(angle)

					local trail2 = CreateAEmitter("Rail Rifle Trail")
					trail2.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.68, 0))
					trail2.Vel = Vector(75, 0):RadRotate(angle)

					local trail3 = CreateAEmitter("Rail Rifle Whiz")
					trail3.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.680, 0))
					trail3.Vel = Vector(95, 0):RadRotate(angle)

					if self.HFlipped then
						trail.Pos = self.MuzzlePos - self:RotateOffset(Vector(distance * 0.75, 0))
						trail2.Pos = self.MuzzlePos - self:RotateOffset(Vector(distance * 0.68, 0))
						trail3.Pos = self.MuzzlePos - self:RotateOffset(Vector(distance * 0.680, 0))
					end

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

			--THIS NEXT BLOCK HANDLES RECOIL COOLDOWN
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
