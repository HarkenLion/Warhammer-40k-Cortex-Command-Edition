function Create(self)
	self.burst = false

	self.raylength = 6
	self.rayPixSpace = 2

	self.dots = math.floor(self.raylength / self.rayPixSpace)
end

function Update(self)
	self.ToSettle = false

	for i = 1, self.dots do
		local checkPos = self.Pos + Vector(self.Vel.X, self.Vel.Y):SetMagnitude((i / self.dots) * self.raylength)
		if SceneMan.SceneWrapsX == true then
			if checkPos.X > SceneMan.SceneWidth then
				checkPos = Vector(checkPos.X - SceneMan.SceneWidth, checkPos.Y)
			elseif checkPos.X < 0 then
				checkPos = Vector(SceneMan.SceneWidth + checkPos.X, checkPos.Y)
			end
		end
		local terrCheck = SceneMan:GetTerrMatter(checkPos.X, checkPos.Y)
		if terrCheck == 0 then
			local moCheck = SceneMan:GetMOIDPixel(checkPos.X, checkPos.Y)
			if moCheck ~= 255 then
				local actor = MovableMan:GetMOFromID(MovableMan:GetMOFromID(moCheck).RootID)
				if actor.Team ~= self.Team then
					self.burst = true
				end
			end
		else
			self.burst = true
		end
	end

	if self.burst == true then
		--[[
		local sfx = CreateAEmitter("Acid Sound Fizz");
		sfx.Pos = self.Pos;
		MovableMan:AddParticle(sfx);
]]
		--
		local part1 = CreateMOPixel("Acid 2")
		part1.Pos = self.Pos
		part1.Vel = self.Vel * 0.75
		MovableMan:AddParticle(part1)

		local part2 = CreateMOSParticle("Tiny Smoke Ball 1")
		part2.Pos = self.Pos
		part2.Vel = self.Vel * 0.25
		MovableMan:AddParticle(part2)

		self.ToDelete = true
	end
end
