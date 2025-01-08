function Create(self)
	--the distance you trace to to find the parent
	self.userRange = 20

	--determine range via sharpness

	self.laserRange = self.Sharpness

	--do not determine colour via mass :p

	--find the parent actor
	local checkVect = Vector(-self.userRange, 0)
	local userID = SceneMan:CastMORay(self.Pos, checkVect, self.ID, -2, -1, false, 0)
	local baseUserID

	--if the actor is facing left we have to flip things
	if userID == 255 then
		checkVect.X = self.userRange
		userID = SceneMan:CastMORay(self.Pos, checkVect, self.ID, -2, -1, false, 0)
	end

	--if we've found a viable parent
	if userID ~= 255 then
		baseUserID = MovableMan:GetRootMOID(userID)
		local user = MovableMan:GetMOFromID(baseUserID)

		--if the parent exists and is an actor
		if user:IsActor() then
			local strikePoint = Vector(0, 0)
			local lastPoint = Vector(0, 0)
			local dist = 0
			local aimAngle = ToActor(user):GetAimAngle(true)

			checkVect.X = math.cos(aimAngle) * self.laserRange
			checkVect.Y = math.sin(aimAngle) * self.laserRange * -1
			dist = SceneMan:CastObstacleRay(self.Pos, checkVect, strikePoint, lastPoint, baseUserID, self.Team, -1, 0)

			--if our obstacle ray has cast correctly and found where it should hit, make a dot there
			if dist >= 0 then
				local point = CreateMOPixel("Laser Pointer Dot Red A", "Untitled.rte")
				point.Pos = strikePoint
				MovableMan:AddParticle(point)
			end
		end
	end
	--Remove the particle every frame
	self.LifeTime = 1
end
function Update(self) end
function Destroy(self) end
