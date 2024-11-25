function Create(self)
	self.trailSeparation = 1

	self.velThreshold = 60

	self.forceMult = 5

	local speed = math.sqrt(self.Vel.X ^ 2 + self.Vel.Y ^ 2)
	if speed >= self.velThreshold then
		local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
		local maxDist = speed * velFactor
		local checkVect = self.Vel * velFactor * -1 * 0.9
		local strikeVect = Vector(0, 0)
		local lastVect = Vector(0, 0)
		local trailDist = SceneMan:CastObstacleRay(self.Pos, checkVect, strikeVect, lastVect, self.ID, self.Team, -1, 0)
		if trailDist >= 0 then
			--something found, check if it's not terrain
			local targetID = SceneMan:CastMORay(self.Pos, checkVect, -1, -1, false, 0)
			if targetID ~= 255 then
				--not terrain, apply force
				self.Mass = 2.5
				local target = MovableMan:GetMOFromID(targetID)
				local strikePoint = Vector(0, 0)

				if SceneMan:CastFindMORay(self.Pos, checkVect, targetID, strikePoint, -1, false, 0) then
					target:AddAbsForce((checkVect / velFactor) * self.Mass * (target.Mass * 24), strikePoint)
					self.Mass = 0.25
				end
			end
		else
			trailDist = maxDist
		end

		local trailAngle = math.atan2(checkVect.Y, -checkVect.X)
		for i = 0, trailDist, self.trailSeparation do
			local trail = CreateAEmitter("Rail Rifle Trail")
			trail.Pos = self.Pos + (checkVect * (i / maxDist))
			trail.RotAngle = trailAngle
			trail.Team = self.Team
			trail.IgnoresTeamHits = true
			trail.Vel = self.Vel * 0.2
			MovableMan:AddParticle(trail)
		end
	end
end

function Update(self)
	local speed = math.sqrt(self.Vel.X ^ 2 + self.Vel.Y ^ 2)
	if speed >= self.velThreshold then
		local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
		local maxDist = speed * velFactor
		local checkVect = self.Vel * velFactor
		local strikeVect = Vector(0, 0)
		local lastVect = Vector(0, 0)
		local trailDist = SceneMan:CastObstacleRay(self.Pos, checkVect, strikeVect, lastVect, self.ID, self.Team, -1, 0)
		if trailDist >= 0 then
			--something found, check if it's not terrain
			local targetID = SceneMan:CastMORay(self.Pos, checkVect, -1, -1, false, 0)
			if targetID ~= 255 then
				--not terrain, apply force
				local target = MovableMan:GetMOFromID(targetID)
				local root = MovableMan:GetMOFromID(target.RootID)
				local strikePoint = Vector(0, 0)

				if SceneMan:CastFindMORay(self.Pos, checkVect, targetID, strikePoint, -1, false, 0) then
					target:AddAbsForce((checkVect / velFactor) * self.Mass * self.forceMult, strikePoint)
					root:AddAbsForce((checkVect / velFactor) * root.Mass * self.forceMult * 19, strikePoint)
				end
			end
		else
			trailDist = maxDist
		end

		local trailAngle = math.atan2(-checkVect.Y, checkVect.X)
		for i = trailDist, 0, -self.trailSeparation do
			local trail = CreateAEmitter("Rail Rifle Trail")
			trail.Pos = self.Pos + (checkVect * (i / maxDist))
			trail.RotAngle = trailAngle
			trail.Team = self.Team
			trail.IgnoresTeamHits = true
			trail.Vel = self.Vel * 0.2
			MovableMan:AddParticle(trail)
		end
	end
end
