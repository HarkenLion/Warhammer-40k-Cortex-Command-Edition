function Create(self)
	-- self.lastRoundCount = self.RoundCount;
	-- self.loopFrames = 3;
	self.cablelength = 7
	self.inventoryTimer = Timer()

	function self.drawcable()
		for i = 0, 5 do
			PrimitiveMan:DrawLinePrimitive(
				Vector(self.apx[i], self.apy[i]),
				Vector(self.apx[i + 1], self.apy[i + 1]),
				86,
				2
			)
		end
		for i = 0, 5 do
			PrimitiveMan:DrawLinePrimitive(
				Vector(self.apx[i], self.apy[i]),
				Vector(self.apx[i + 1], self.apy[i + 1]),
				21,
				1
			)
		end
	end

	--ESTABLISH CABLE
	self.apx = {}
	self.apy = {}

	self.lastX = {}
	self.lastY = {}

	self.usefriction = 0.96

	local px = self.Pos.X
	local py = self.Pos.Y
	for i = 0, 6 do
		self.apx[i] = px
		self.apy[i] = py
		self.lastX[i] = px
		self.lastY[i] = py
	end
	--slots 0 and 11 are ANCHOR POINTS
end

function Update(self)
	if self.inventoryTimer:IsPastSimMS(TimerMan.DeltaTimeMS) then
		local px = self.Pos.X
		local py = self.Pos.Y
		for i = 0, 6 do
			self.apx[i] = px
			self.apy[i] = py
			self.lastX[i] = px
			self.lastY[i] = py
		end
	end
	self.inventoryTimer:Reset()

	self.cablelength = self.RoundCount * 0.05 --0.02
	--HANDLE CABLE
	local i = 6
	--HANDLE ALL CABLE JOINTS
	while i > -1 do
		if i <= 5 - self.RoundCount * 0.05 then
			local FlipFactor = 1
			if self.HFlipped then
				FlipFactor = -1
			end
			local usepos = self.Pos + Vector(-3 * FlipFactor, 2):RadRotate(self.RotAngle)
			self.apx[i] = usepos.X
			self.apy[i] = usepos.Y
		else
			--CALCULATE BASIC PHYSICS
			local accX = 0
			local accY = 0.05

			local velX = self.apx[i] - self.lastX[i]
			local velY = self.apy[i] - self.lastY[i]

			local nextX = self.apx[i] + (velX + accX) * self.usefriction
			local nextY = self.apy[i] + (velY + accY) * self.usefriction

			self.lastX[i] = self.apx[i]
			self.lastY[i] = self.apy[i]

			self.apx[i] = nextX
			self.apy[i] = nextY
		end

		local j = 0

		while j < 2 do
			if i < 6 then
				local cablelength = self.cablelength
				--FROM i+1
				-- calculate the distance
				local diffX = self.apx[i + 1] - self.apx[i]
				local diffY = self.apy[i + 1] - self.apy[i]
				local d = math.sqrt(math.abs((diffX * diffX) + (diffY * diffY)))
				local dmin = math.max(d, 0.000001)

				-- difference scalar
				local difference = (cablelength - d) / dmin

				-- translation for each PointMass. They'll be pushed 1/2 the required distance to match their resting distances.
				local usespring = 0.2 --0.05 + cablespring * 2

				local translateX = diffX * usespring * difference * self.usefriction
				local translateY = diffY * usespring * difference * self.usefriction

				self.apx[i + 1] = self.apx[i + 1] + translateX
				self.apy[i + 1] = self.apy[i + 1] + translateY
				self.apx[i + 1] = self.apx[i + 1] - translateX
				self.apy[i + 1] = self.apy[i + 1] - translateY

				--TO i+1
				-- calculate the distance
				local diffX = self.apx[i] - self.apx[i + 1]
				local diffY = self.apy[i] - self.apy[i + 1]
				local d = math.sqrt(math.abs((diffX * diffX) + (diffY * diffY)))
				local dmin = math.max(d, 0.000001)

				-- difference scalar
				local difference = (cablelength - d) / dmin
				local usespring = 0.25 --0.05 + cablespring * 2

				local translateX = diffX * usespring * difference * self.usefriction
				local translateY = diffY * usespring * difference * self.usefriction

				local nextX = self.apx[i] + translateX
				local nextY = self.apy[i] + translateY
				self.apx[i] = nextX
				self.apy[i] = nextY

				local nextX = self.apx[i + 1] - translateX
				local nextY = self.apy[i + 1] - translateY
				self.apx[i + 1] = nextX
				self.apy[i + 1] = nextY
			end
			j = j + 1
		end
		i = i - 1
	end

	--DRAW CABLE

	self.drawcable()
end
