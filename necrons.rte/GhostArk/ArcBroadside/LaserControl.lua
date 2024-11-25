function Create(self)
	self.LTimer = Timer()
	self.FireTimer = Timer()
	local curdist = 115
	local wep = nil

	for actor in MovableMan.Actors do
		if math.abs((self.Pos - actor.Pos).Magnitude) < curdist and actor.PresetName == "Necron Ghost Ark" then
			self.parent = actor
		end
	end

	for actor in MovableMan.Actors do
		if
			math.abs((self.Pos - actor.Pos).Magnitude) < curdist
			and actor.PresetName == "Necron Ghost Ark Broadside Control"
		then
			self.parent2 = actor
		end
	end

	local vect = Vector(1200, 0)
	local rayLockOn = 0

	if MovableMan:IsActor(self.parent2) and MovableMan:IsActor(self.parent) then
		vect = vect:RadRotate(self.parent2:GetAimAngle(true))
		vect = vect:SetMagnitude(1700)
		rayLockOn = SceneMan:CastObstacleRay(
			Vector(self.Pos.X, self.Pos.Y),
			vect,
			vect,
			vect,
			self.parent.ID,
			self.parent2.Team,
			0,
			3
		)

		if rayLockOn > 0 then
			self.LockOn = CreateMOPixel("GhostBoat Target Achieved")
			self.LockOn.Pos = SceneMan:GetLastRayHitPos()
			MovableMan:AddParticle(self.LockOn)
		else
			self.ToDelete = true
		end
	else
		self.ToDelete = true
	end
end

function Update(self)
	if self.LTimer:IsPastSimMS(300) then
		if
			MovableMan:IsActor(self.parent)
			and MovableMan:IsActor(self.parent2)
			and MovableMan:IsParticle(self.LockOn)
		then
			if self.FireTimer:IsPastSimMS(75) then
				self.LockOn2 = CreateMOPixel("GhostBoat Target Confirmation")
				self.LockOn2.Pos = self.LockOn.Pos
				MovableMan:AddParticle(self.LockOn2)

				local gunPosx = 0
				local gunPosy = 0

				local randgun = math.random(0, 5)

				if randgun == 0 then
					gunPosx = -15
					gunPosy = 0
				elseif randgun == 1 then
					gunPosx = -5
					gunPosy = 0
				elseif randgun == 2 then
					gunPosx = 5
					gunPosy = 0
				elseif randgun == 3 then
					gunPosx = 15
					gunPosy = 0
				elseif randgun == 4 then
					gunPosx = 25
					gunPosy = 0
				else
					gunPosx = 30
					gunPosy = 0
				end

				local shot = CreateMOPixel("Round Gauss1")
				shot.Pos = self.parent.Pos + self.parent:RotateOffset(Vector(gunPosx, gunPosy))

				shot.Team = self.parent2.Team
				shot.IgnoresTeamHits = true

				local sfx = CreateAEmitter("Ghost Boat STS Laser Fire Sound")
				sfx.Pos = shot.Pos

				local Range = SceneMan:ShortestDistance(shot.Pos, self.LockOn.Pos, false)
				local angle = Range.AbsRadAngle
				local distance = Range.Magnitude

				local spread = math.random(-4, 4)

				shot.Vel = Vector(70, spread):RadRotate(angle)

				sfx:SetWhichMOToNotHit(self.parent, -1)
				MovableMan:AddParticle(sfx)

				shot:SetWhichMOToNotHit(self.parent, -1)
				MovableMan:AddParticle(shot)

				self.FireTimer:Reset()
			end
		else
			self.ToDelete = true
		end
	end

	if self.LTimer:IsPastSimMS(1075) then
		self.ToDelete = true
	end
end
