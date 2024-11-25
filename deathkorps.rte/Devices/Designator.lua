function Create(self)
	self.ScanTimer = Timer()

	self.scanDelay = self:GetNumberValue("ScanDelay")
	self.maxScanRange = self:GetNumberValue("MaxScanRange")
	self.scanDisruption = self:GetNumberValue("ScanDisruption")
	self.scanSpacing = self:GetNumberValue("ScanSpacing")
	self.numberOfScans = self:GetNumberValue("NumberOfScans")

	self.scanSpreadAngle = self.ParticleSpreadRange --Degrees!
end

function Update(self)
	if self:IsActivated() then
		if self.ScanTimer:IsPastSimMS(self.scanDelay) then
			self.ScanTimer:Reset()
			local pactor = MovableMan:GetMOFromID(self.RootID)
			if MovableMan:IsActor(pactor) then
				self.parent = ToActor(pactor)
				local vect = Vector(1905, 0)
				local urot = 0
				if self.HFlipped then
					urot = self.RotAngle + math.pi
				else
					urot = self.RotAngle
				end

				vect = vect:RadRotate(urot)
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
				print("castray")
				if rayL > 0 then
					local hitvect = SceneMan:GetLastRayHitPos()
					PrimitiveMan:DrawLinePrimitive(self.MuzzlePos, hitvect, 147, 1)

					for actor in MovableMan:GetMOsInRadius(self.Pos, 3500) do
						if
							IsActor(actor)
							and actor.Team == self.Team
							and actor.ID ~= self.RootID
							and (
								ToActor(actor):NumberValueExists("ArtilleryRequested") == false
								or ToActor(actor):GetNumberValue("ArtilleryRequested") == 0
							)
						then
							local getact = ToActor(actor)
							--
							--local uang = findang*getact.FlipFactor
							local sfx = CreateMOSRotating("Target Control Node", "deathkorps.rte")
							--getact:SetNumberValue("ArtilleryRequested",1)
							sfx.Pos = getact.Pos
							--sfx:SetStringValue("FindTarg",getact.PresetName)
							--sfx:SetNumberValue("PassAng",uang);
							sfx:SetNumberValue("TargX", hitvect.X)
							sfx:SetNumberValue("TargY", hitvect.Y)
							sfx.Team = self.Team
							sfx.IgnoresTeamHits = true
							MovableMan:AddParticle(sfx)

							local targetmarker = CreateMOPixel("Artillery Designator", "deathkorps.rte")
							targetmarker.Pos = hitvect
							targetmarker.Team = self.Team
							MovableMan:AddParticle(targetmarker)
						end
					end
				end
			end
		end
	end
end
