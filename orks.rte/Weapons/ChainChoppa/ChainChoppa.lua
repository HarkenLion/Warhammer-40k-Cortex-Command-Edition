function Create(self)
	self.ammoCounter = 100
	self.recoil = 0

	self.ff = false

	-- print(self.Magazine)
	self.f0 = ToMagazine(self.Magazine).RoundCount

	self.f1 = ToMagazine(self.Magazine).RoundCount
	self.firetimer = Timer()
end

function Update(self)
	if self.ID ~= self.RootID then
		if MovableMan:IsActor(self.parent) then
			if self.parent.HFlipped then
				self.RotAngle = self.RotAngle + self.recoil
			else
				self.RotAngle = self.RotAngle - self.recoil
			end

			if self.Magazine ~= nil then
				self.Magazine.RoundCount = self.ammoCounter

				if self.ff then
					self.f0 = ToMagazine(self.Magazine).RoundCount

					self.ff = false
				else
					self.f1 = ToMagazine(self.Magazine).RoundCount

					self.ff = true
				end

				local recoil = self.recoil

				if recoil > 0 then
					self.recoil = recoil - 0.06
				elseif recoil < 0 then
					self.recoil = 0
				end

				if self:IsActivated() and self.ammoCounter > 1 then
					self.firetimer:Reset()

					if self.Magazine.Frame == 0 then
						self.Magazine.Frame = 1
					elseif self.Magazine.Frame == 1 then
						self.Magazine.Frame = 2
					else
						self.Magazine.Frame = 0
					end

					local soundfx = CreateAEmitter("ChainChoppa Rev")
					soundfx.Pos = SceneMan:GetLastRayHitPos()
					MovableMan:AddParticle(soundfx)

					local rayL = 0
					local rands = math.random(-4, 4)
					local vect = Vector(rands, -41)

					vect = vect:RadRotate(self.RotAngle)

					local chaincut = CreateMOPixel("Particle ChainChoppa", "Orks.rte")
					chaincut.Vel = vect
					chaincut.Team = self.Team
					chaincut.Pos = self.MuzzlePos
					chaincut.IgnoresTeamHits = true
					MovableMan:AddParticle(chaincut)

					rands = math.random(-4, 4)
					vect = Vector(rands, -41)

					vect = vect:RadRotate(self.RotAngle)

					local chaincut2 = CreateMOPixel("Particle ChainChoppa", "Orks.rte")
					chaincut2.Vel = vect
					chaincut2.Team = self.Team
					chaincut2.Pos = self.MuzzlePos
					chaincut2.IgnoresTeamHits = true
					MovableMan:AddParticle(chaincut2)

					local recoil2 = self.recoil
					if recoil2 < 1.25 then
						local user
						user = MovableMan:GetMOFromID(self.RootID)

						self.recoil = recoil2 + 0.13 * user.Sharpness
					end

					self.ammoCounter = self.ammoCounter - 1
				end

				if not self:IsActivated() and self.firetimer:IsPastSimMS(100) and self.ammoCounter <= 199 then
					self.ammoCounter = self.ammoCounter + 2
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
