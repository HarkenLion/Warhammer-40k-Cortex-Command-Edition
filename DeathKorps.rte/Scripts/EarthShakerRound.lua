function Create(self)
	self.AirResistance = 0 --0.025
	self.IgnoresTeamHits = true
end

function ThreadedUpdate(self)
	if self.MissionCritical == true then
		--print(self.Pos.Y)
		--RoundFloatToPrecision(floatValue, digitsPastDecimal, roundingMode)\
		--PrimitiveMan:DrawTextPrimitive(pos, text, bool useSmallFont, alignment, rotAngleInRadians)
		self.ToDelete = false
		local usey = 5
		if self.Vel.Y > 0 then
			usey = -5
		end
		local usevec = Vector(self.Pos.X, math.max(10, self.Pos.Y))
		local usevec2 = usevec + Vector(-5, usey)
		local usevec3 = usevec + Vector(5, usey)
		local printy = Vector(self.Pos.X, math.max(10, self.Pos.Y))
		local printvec = RoundFloatToPrecision(self.Pos.Y, 0, 1)
		PrimitiveMan:DrawLinePrimitive(usevec, usevec2, 13, 2)
		PrimitiveMan:DrawLinePrimitive(usevec, usevec3, 13, 2)
		PrimitiveMan:DrawTextPrimitive(printy, printvec, true, 0, 0)
	end

	if self.Pos.Y < 0 and self.MissionCritical == false then
		self.MissionCritical = true
		--self.AirResistance = 0.075
		--print("CRITICALED")
	end

	if self.MissionCritical == true and self.Pos.Y > 0 then
		self.MissionCritical = false
		--self.AirResistance = 0.025
	end
end
