function Create(self)
	self.fireTimer = Timer()
	self.negatore = 1
	self.fired = false
end

function Update(self)
	if self.ID ~= self.RootID and self.Magazine then
		if self.HFlipped == false then
			self.negatore = 1
		else
			self.negatore = -1
		end

		if self.beamSound then
			self.beamSound.ToDelete = false
			self.beamSound.ToSettle = false
			self.beamSound.PinStrength = 1000
			self.beamSound.Pos = self.MuzzlePos
			if self:IsActivated() and self.Magazine.RoundCount > 0 then
				self.beamSound:EnableEmission(true)
			else
				self.beamSound:EnableEmission(false)
			end
		else
			self.beamSound = CreateAEmitter("Space Marine Melta Gun Sound Beam")
			self.beamSound.Pos = self.MuzzlePos
			MovableMan:AddParticle(self.beamSound)
		end

		if self:IsActivated() and not self:IsReloading() then
			if self.Magazine.RoundCount > 0 then
				if self.fired == false then
					local soundfx = CreateAEmitter("Space Marine Melta Gun Sound Burst")
					soundfx.Pos = self.MuzzlePos
					MovableMan:AddParticle(soundfx)
				end

				if self.fireTimer:IsPastSimMS(20) then
					self.fireTimer:Reset()

					local effectPar = CreateMOPixel(
						"Space Marine Melta Gun Effect Particle " .. math.ceil(math.random() * 4)
					)
					effectPar.Pos = self.MuzzlePos
					effectPar.Team = self.Team
					effectPar.IgnoresTeamHits = true
					MovableMan:AddParticle(effectPar)

					local rayHit = false
					local laserPointVectorA = self.MuzzlePos
					local laserPointVectorB = self.MuzzlePos
					local rayLengthA = 0
					local rayLengthB = 0

					for i = 1, 117 do
						rayLengthB = rayLengthA
						rayLengthA = (i / 117) * 465
						local checkPos = self.MuzzlePos + Vector(rayLengthA * self.negatore, 0):RadRotate(self.RotAngle)
						if SceneMan.SceneWrapsX == true then
							if checkPos.X > SceneMan.SceneWidth then
								checkPos = Vector(checkPos.X - SceneMan.SceneWidth, checkPos.Y)
							elseif checkPos.X < 0 then
								checkPos = Vector(SceneMan.SceneWidth + checkPos.X, checkPos.Y)
							end
						end
						laserPointVectorB = laserPointVectorA
						laserPointVectorA = checkPos
						if SceneMan:GetTerrMatter(checkPos.X, checkPos.Y) ~= 0 then
							rayHit = true
							break
						else
							local checkMOPix = SceneMan:GetMOIDPixel(checkPos.X, checkPos.Y)
							if checkMOPix ~= 255 and checkMOPix ~= self.RootID then
								rayHit = true
								break
							end
						end
					end

					local beamEffectAmount = math.ceil(rayLengthB / 5) --NUMBER HERE CONTROLS BEAM EFFECT SPACING

					for i = 1, beamEffectAmount do
						local effectPar = CreateMOPixel(
							"Particle Space Marine Melta Gun Beam Effect "
								.. math.ceil((((i / beamEffectAmount) * rayLengthB) / 465) * 20)
						)
						local hitPos = self.MuzzlePos
							+ Vector((i / beamEffectAmount) * rayLengthB * self.negatore, 0):RadRotate(self.RotAngle)
						if SceneMan.SceneWrapsX == true then
							if hitPos.X > SceneMan.SceneWidth then
								hitPos = Vector(hitPos.X - SceneMan.SceneWidth, hitPos.Y)
							elseif hitPos.X < 0 then
								hitPos = Vector(SceneMan.SceneWidth + hitPos.X, hitPos.Y)
							end
						end

						effectPar.Team = self.Team
						effectPar.IgnoresTeamHits = true
						effectPar.Pos = hitPos
						MovableMan:AddParticle(effectPar)
					end

					if rayHit == true then
						for i = 1, 2 do --EXECUTE ORDER 66
							local damagePar = CreateMOPixel("Particle Space Marine Melta Gun Damage")
							damagePar.Pos = laserPointVectorB
							damagePar.Vel = Vector(math.random(35, 100), 0):RadRotate(math.random() * (math.pi * 2))
							damagePar.Team = self.Team
							damagePar.IgnoresTeamHits = true
							MovableMan:AddParticle(damagePar)

							local randa = math.random(-5, 5)
							local randb = math.random(-5, 5)
							local damagePar = CreateMOPixel("Melta Destroyer")
							damagePar.Pos = Vector(laserPointVectorB.X + randa, laserPointVectorB.Y + randb)

							local randc = math.random(-2, 2)
							damagePar.Vel = Vector(30 * self.negatore, randc):RadRotate(self.RotAngle)
							damagePar.Team = self.Team
							damagePar.IgnoresTeamHits = true
							MovableMan:AddParticle(damagePar)
						end

						local effectPar = CreateMOPixel("Particle Space Marine Melta Gun Splash Effect")
						effectPar.Pos = laserPointVectorB
						effectPar.Team = self.Team
						effectPar.IgnoresTeamHits = true
						MovableMan:AddParticle(effectPar)
					end
				end
			else
				if self.beamSound then
					self.beamSound.ToDelete = true
				end
			end
			self.fired = true
		else
			if self.fired == true then
				self.fired = false
			end
		end
	end
end

function Destroy(self)
	if MovableMan:IsParticle(self.beamSound) then
		self.beamSound.ToDelete = true
	end
end
