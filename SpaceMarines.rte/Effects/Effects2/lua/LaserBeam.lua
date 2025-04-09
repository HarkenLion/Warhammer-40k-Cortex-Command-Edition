function Create(self)
	self.dots = 40 -- length/"speed" of laser beam
	self.dots = self.Sharpness
	self.glow = 1 -- glow strength phase of laser, 1 = highest, 12 = lowest/delete

	self.Vel = Vector(0, 0)

	self.negativeNum = 1
	if self.HFlipped == true then
		self.negativeNum = -1
	end

	local initPos = self.Pos
	self.oldPos = initPos
	local newPos = Vector(0, 0)

	for i = 1, self.dots do
		local glow = CreateMOPixel("untitled.rte/Laser Glow " .. self.glow)

		posVector = Vector(2 * self.negativeNum, 0):RadRotate(self.RotAngle)
		newPos = newPos + posVector
		glow.Pos = initPos + newPos
		glow.Vel = Vector(0, 0)
		local endPos = Vector(0, 0)
		if i > 2 then
			local randomRay = SceneMan:CastMORay(self.oldPos, posVector, glow.ID, self.Team, 0, false, 0)
			endPos = SceneMan:GetLastRayHitPos()
			local trueLength = SceneMan:ShortestDistance(self.oldPos, endPos, true).Magnitude
			if trueLength < posVector.Magnitude then
				local impact = CreateAEmitter("Laser Hit " .. self.dots)
				impact.Pos = endPos - Vector(self.negativeNum, 0):RadRotate(self.RotAngle)
				impact.Vel = Vector(0, 0)
				impact.HFlipped = self.HFlipped
				impact.RotAngle = self.RotAngle
				impact.Team = self.Team
				impact.IgnoresTeamHits = true
				MovableMan:AddMO(impact)

				self.ToDelete = true
				break
			end
		end
		MovableMan:AddMO(glow)
		self.oldPos = glow.Pos
	end
	self.glow = self.glow + 1
end

function Update(self)
	--self.Vel = Vector(0,0);

	local initPos = self.oldPos
	self.oldPos = initPos
	local newPos = Vector(0, 0)

	for i = 1, self.dots do
		local glow = CreateMOPixel("untitled.rte/Laser Glow " .. self.glow)

		posVector = Vector(2 * self.negativeNum, 0):RadRotate(self.RotAngle)
		newPos = newPos + posVector
		glow.Pos = initPos + newPos
		glow.Vel = Vector(0, 0)
		local endPos = Vector(0, 0)
		if i > 2 then
			local randomRay = SceneMan:CastMORay(self.oldPos, posVector, glow.ID, self.Team, 0, false, 0)
			endPos = SceneMan:GetLastRayHitPos()
			local trueLength = SceneMan:ShortestDistance(self.oldPos, endPos, true).Magnitude
			if trueLength < posVector.Magnitude then
				local impact = CreateAEmitter("Laser Hit " .. self.dots)
				impact.Pos = endPos - Vector(self.negativeNum, 0):RadRotate(self.RotAngle)
				impact.Vel = Vector(0, 0)
				impact.HFlipped = self.HFlipped
				impact.RotAngle = self.RotAngle
				impact.Team = self.Team
				impact.IgnoresTeamHits = true
				MovableMan:AddMO(impact)

				self.ToDelete = true
				break
			end
		end
		MovableMan:AddMO(glow)
		self.oldPos = glow.Pos
	end
	self.glow = self.glow + 1
	if self.glow > 12 then
		self.ToDelete = true
	end
end
