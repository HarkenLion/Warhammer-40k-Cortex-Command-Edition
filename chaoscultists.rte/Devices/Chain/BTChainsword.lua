function Create(self)
	self.ammoCounter = 100
	self.recoil = 0
	self.firetimer = Timer()
end

function Update(self)
	if self.ID ~= self.RootID then
		self.RotAngle = self.RotAngle - self.recoil * self.FlipFactor
		if self.Magazine then
			local recoil = self.recoil
			if recoil > 0 then
				self.recoil = recoil - 0.04
			elseif recoil < 0 then
				self.recoil = 0
			end

			if self.ammoCounter > 2 then
				if self:IsActivated() then
					self.firetimer:Reset()

					local soundfx = CreateAEmitter("Chainsword Rev")
					soundfx.Pos = SceneMan:GetLastRayHitPos()
					MovableMan:AddParticle(soundfx)

					local rand = 3 * self.FlipFactor
					--local rayL = 0;
					local vect = Vector(rand, -35)

					vect = vect:RadRotate(self.RotAngle)

					local chaincut = CreateMOPixel("Particle CChainsword Hit", "SpaceMarines.rte")
					chaincut.Vel = vect
					chaincut.Team = self.Team
					chaincut.Pos = self.MuzzlePos
					chaincut.IgnoresTeamHits = true
					MovableMan:AddParticle(chaincut)

					local rand = 4 * self.FlipFactor
					--	local rayL = 0;
					local vect = Vector(rand, -35)

					vect = vect:RadRotate(self.RotAngle)

					local chaincut = CreateMOPixel("Particle CChainsword Hit", "SpaceMarines.rte")
					chaincut.Vel = vect
					chaincut.Team = self.Team
					chaincut.Pos = self.MuzzlePos
					chaincut.IgnoresTeamHits = true
					MovableMan:AddParticle(chaincut)

					local recoil2 = self.recoil
					if recoil2 < 1.25 then
						local user = MovableMan:GetMOFromID(self.RootID)
						self.recoil = recoil2 + 0.055 * user.Sharpness
					end
					self.ammoCounter = self.ammoCounter - 1
				else
					self:Deactivate()
				end
			end

			if not self:IsActivated() and self.firetimer:IsPastSimMS(175) and self.ammoCounter <= 99 then
				self.ammoCounter = self.ammoCounter + 2
			end
		end

		offset = Vector(16, 1):RadRotate(-0.25 - math.sin(self.recoil) * 1.2)
		self.Supportable = true

		self.StanceOffset = offset
		self.SharpStanceOffset = offset
	end
end
