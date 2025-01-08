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

	self.Scale = 0.8
end

function Update(self)
	if self.ID ~= self.RootID then
		self.Scale = 0.8

		if MovableMan:IsActor(self.parent) then
			if self.parent.PresetName == "Necron Deathmark" then
				if
					self.parent.Vel.X < 1
					and self.parent.Vel.X > -1
					and self.parent.Vel.Y < 1
					and self.parent.Vel.Y > -1
				then
					if self.parent.HFlipped == false then
						self.RotAngle = self.parent:GetAimAngle(true)
					else
						self.RotAngle = (self.parent:GetAimAngle(true) + math.pi)
					end
				end
			end

			if self.Magazine ~= nil then
				if self.ff then
					self.f0 = ToMagazine(self.Magazine).RoundCount
					self.ff = false
				else
					self.f1 = ToMagazine(self.Magazine).RoundCount
					self.ff = true
				end

				if self:IsActivated() and self.f1 ~= self.f0 then
					local sfx = CreateAEmitter("Synaptic Bolt", "Necrons.rte")
					sfx.Pos = self.MuzzlePos

					if self.HFlipped then
						sfx.RotAngle = self.RotAngle + math.pi
					else
						sfx.RotAngle = self.RotAngle
					end

					sfx:SetWhichMOToNotHit(self.parent, -1)
					MovableMan:AddParticle(sfx)

					local vect = Vector(975, 0)
					vect = vect:RadRotate(sfx.RotAngle)
					vect = vect:SetMagnitude(975)
					rayL = SceneMan:CastObstacleRay(
						Vector(self.MuzzlePos.X, self.MuzzlePos.Y),
						vect,
						vect,
						vect,
						self.parent.ID,
						self.Team,
						0,
						3
					)

					--WEAPON DISCHARGE

					if rayL > 0 then
						local firerange =
							SceneMan:ShortestDistance(SceneMan:GetLastRayHitPos(), self.Pos, true).Magnitude

						local scatterx = math.random(-10, 10)
						local scattery = math.random(-10, 10)

						if firerange >= 950 then
							self.RateOfFire = 25
							scatterx = math.random(-9, 9)
							scattery = math.random(-9, 9)
						elseif firerange < 950 and firerange >= 650 then
							self.RateOfFire = 30
							scatterx = math.random(-7, 7)
							scattery = math.random(-7, 7)
						elseif firerange < 650 and firerange >= 500 then
							self.RateOfFire = 33
							scatterx = math.random(-6, 6)
							scattery = math.random(-6, 6)
						elseif firerange < 500 and firerange >= 425 then
							self.RateOfFire = 39
							scatterx = math.random(-3, 3)
							scattery = math.random(-3, 3)
						elseif firerange < 425 then
							self.RateOfFire = 45
							scatterx = math.random(-1, 1)
							scattery = math.random(-1, 1)
						end

						local tempvect = SceneMan:GetLastRayHitPos()
						local hitpos = Vector(tempvect.X, tempvect.Y)

						local pulseexplosion = CreateMOPixel("Gauss Lightning Particle", "Necrons.rte")
						pulseexplosion.Pos = hitpos
						pulseexplosion.Vel = Vector(35, 0):RadRotate(sfx.RotAngle)
						MovableMan:AddParticle(pulseexplosion)

						local pulseexplosion = CreateMOPixel("Gauss Lightning Particle", "Necrons.rte")
						pulseexplosion.Pos = hitpos
						pulseexplosion.Vel = Vector(11, 0):RadRotate(sfx.RotAngle)
						MovableMan:AddParticle(pulseexplosion)

						local Range = SceneMan:ShortestDistance(self.MuzzlePos, pulseexplosion.Pos, false)
						local angle = Range.AbsRadAngle
						local distance = Range.Magnitude

						local i = 0
						while i < 6 do
							local trail = CreateMOPixel("Gauss Lightning Particle")
							trail.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.970, 0))
							trail.Vel = Vector(distance * 0.03, 0):RadRotate(angle)

							MovableMan:AddParticle(trail)

							i = i + 1
						end

						local trail = CreateMOSRotating("SD Brain Zap")
						trail.Pos = self.MuzzlePos + self:RotateOffset(Vector(distance * 0.780, 0))
						trail.Vel = Vector(distance * 0.03, 0):RadRotate(angle)

						MovableMan:AddParticle(trail)

						for actor in MovableMan.Actors do
							local dist =
								SceneMan:ShortestDistance(SceneMan:GetLastRayHitPos(), actor.Pos, true).Magnitude
							if
								dist < 25
								and actor.PresetName ~= "Charred Skeleton"
								and actor.Team ~= self.parent.Team
								and actor:HasObjectInGroup("Brains") == false
							then
								local i = 0
								while i < 8 do
									local e = CreateMOPixel("Gauss Lightning Static Particle")
									e.Vel.X = math.random(-5, 5)
									e.Vel.Y = math.random(-5, 5)

									local randx = math.random(-5, 5)
									local randy = math.random(-15, -5)

									local headOffset = Vector(randx, randy)
									e.Pos = actor.Pos + headOffset:RadRotate(self.RotAngle)

									MovableMan:AddMO(e)
									i = i + 1
								end

								ToActor(actor).Health = ToActor(actor).Health - 15
							end
						end
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
end
