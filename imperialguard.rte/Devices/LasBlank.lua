function Create(self)
	local actor = MovableMan:GetMOFromID(self.RootID)
	if MovableMan:IsActor(actor) then
		self.parent = ToActor(actor)
	end

	self.recoil = 0

	self.ff = false

	self.f0 = ToMagazine(self.Magazine).RoundCount

	self.f1 = ToMagazine(self.Magazine).RoundCount

	self.firecounter = 0
	self.recoilcooldown = 0.00006
	self.firetimer = Timer()
end

function Update(self)
	if MovableMan:IsActor(self.parent) then
		if self:IsReloading() then
			self.f1 = 0
			self.f0 = 0
			self.recoil = 0
		end

		if self.Magazine ~= nil then
			if self.ff then
				self.f0 = ToMagazine(self.Magazine).RoundCount

				self.ff = false
			else
				self.f1 = ToMagazine(self.Magazine).RoundCount

				self.ff = true
			end

			local randb = math.random(-4, 4)

			local recoil = self.recoil
			local recoilrand = randb * recoil

			self.RotAngle = self.RotAngle + recoilrand

			if self.firetimer:IsPastSimMS(80) then
				if recoil > 0 then
					local user
					user = MovableMan:GetMOFromID(self.RootID)
					self.recoil = recoil - self.recoilcooldown * user.Sharpness
				elseif recoil < 0 then
					self.recoil = 0
				end
			end

			if self.f1 ~= self.f0 and ((self.ff == false and self.f1 ~= 0) or (self.ff == true and self.f0 ~= 0)) then
				local recoil2 = self.recoil
				if recoil2 < 0.024 then
					self.recoil = recoil2 + 0.0005 + (4 - self.parent.Sharpness) * 0.65 * 0.0005
					self.firetimer:Reset()
				end

				local sfx = CreateAEmitter("Las Muzzle Flash")
				sfx.Pos = self.MuzzlePos

				if self.HFlipped then
					sfx.RotAngle = self.RotAngle + math.pi
				else
					sfx.RotAngle = self.RotAngle
				end

				sfx:SetWhichMOToNotHit(self.parent, -1)
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
					local distance = Range.Magnitude

					local pulseexplosion = CreateMOPixel("Rifle Las Particle Hit")
					pulseexplosion.Pos = hitpos
					pulseexplosion.Team = self.Team
					pulseexplosion.Vel = Vector(105, 0):RadRotate(angle)
					pulseexplosion.IgnoresTeamHits = true
					MovableMan:AddParticle(pulseexplosion)

					local pulseexplosion = CreateMOPixel("Rifle Las Particle Hit")
					pulseexplosion.Pos = hitpos
					pulseexplosion.Team = self.Team
					pulseexplosion.Vel = Vector(105, 0):RadRotate(angle)
					pulseexplosion.IgnoresTeamHits = true
					MovableMan:AddParticle(pulseexplosion)

					local pulseexplosion2 = CreateMOPixel("Rifle Las Particle Light Hit")
					pulseexplosion2.Pos = hitpos
					pulseexplosion.Team = self.Team
					pulseexplosion2.Vel = Vector(105, 0):RadRotate(angle)
					pulseexplosion2.IgnoresTeamHits = true
					MovableMan:AddParticle(pulseexplosion2)

					local firevel = distance * 0.15

					if firevel < 105 then
						firevel = 105
					end

					local i = 0
					local beamsplit = math.floor(distance * 0.045)

					while i < beamsplit do
						local trail = CreateMOPixel("Rifle Las Particle")
						trail.Pos = self.MuzzlePos + self:RotateOffset(Vector(i * 21, 0))
						trail.Vel = Vector(firevel, 0):RadRotate(angle)
						trail.Team = self.Team
						trail.IgnoresTeamHits = true
						MovableMan:AddParticle(trail)
						i = i + 1
					end

					local smoke = CreateMOPixel("Rifle Las Contact Flash")
					smoke.Pos = SceneMan:GetLastRayHitPos()
					MovableMan:AddParticle(smoke)

					local smoke2 = CreateMOSParticle("Small Smoke Ball 1", "Base.rte")
					smoke2.Pos = SceneMan:GetLastRayHitPos()
					MovableMan:AddParticle(smoke2)
				else
					local angle = self.RotAngle
					local firevel = 215
					if self.HFlipped == true then
						firevel = -215
					end

					local trail = CreateMOPixel("Rifle Las Particle Blank")
					trail.Pos = self.MuzzlePos
					trail.Vel = Vector(firevel, 0):RadRotate(angle)
					trail.Team = self.Team
					trail.IgnoresTeamHits = true
					MovableMan:AddParticle(trail)
				end

				--END WEAPON DISCHARGE
			end
		end
	else
		local actor = MovableMan:GetMOFromID(self.RootID)
		if MovableMan:IsActor(actor) then
			self.parent = ToActor(actor)
		end
	end
end
