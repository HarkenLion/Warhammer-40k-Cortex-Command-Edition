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

--VERLET COLLISIONS
function verletcollide(h, nextX, nextY)
	self.apx[h] = self.apx[h] + nextX
	self.apy[h] = self.apy[h] + nextY
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
	self.cablelength = self.RoundCount * 0.06 --0.02

	local hookedin = false
	if self.RoundCount > 70 then
		hookedin = true
	end

	--HANDLE CABLE
	local i = 6
	--HANDLE ALL CABLE JOINTS
	while i > -1 do
		if i == 6 and hookedin == true then
			local FlipFactor = 1
			if self.HFlipped then
				FlipFactor = -1
			end
			local usepos = self.Pos + Vector(-5 * FlipFactor, -8):RadRotate(self.RotAngle)
			self.apx[i] = usepos.X
			self.apy[i] = usepos.Y
			self.lastX[i] = usepos.X
			self.lastY[i] = usepos.Y
		elseif i == 0 or i <= 5 - self.RoundCount * 0.05 then
			local FlipFactor = 1
			if self.HFlipped then
				FlipFactor = -1
			end
			local usepos = self.Pos + Vector(1 * FlipFactor, -1):RadRotate(self.RotAngle)
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

		--CONSTRAINTS
		local j = 0
		while j < 3 do
			if not i == 11 then
				local diffX = self.apx[i] - self.apx[i + 1]
				local diffY = self.apy[i] - self.apy[i + 1]

				local diffmag = Vector(diffX, diffY).Magnitude
				local diffFactor = (cablelength - diffmag) / diffmag * 0.5
				local offset = Vector(diffX * diffFactor, diffY * diffFactor)

				verletcollide(i, offset.X, offset.Y)
				verletcollide(i + 1, -offset.X, -offsest.Y)
			end
			j = j + 1
		end

		i = i - 1
	end

	--DRAW CABLE

	self.drawcable()
end
