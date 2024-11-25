dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI") --dofile("Base.rte/AI/NativeHumanAI.lua")

function Create(self)

	function self.drawcape()
		local drawverts = {}
		for i = 0, 9 do
			drawverts[i]=Vector(self.apx[i+1]-self.apx[0],self.apy[i+1]-self.apy[0])
		end
		drawverts[10]=Vector(0,0)
		local startpos=Vector(self.apx[0],self.apy[0])
		PrimitiveMan:DrawPolygonFillPrimitive(startpos, 6, drawverts);
	end

	self.AI = NativeHumanAI:Create(self)

	--ESTABLISH CAPE
	self.apx = {};
	self.apy = {};

	self.lastX = {};
	self.lastY = {}

	self.usefriction = 0.96;

	local px = self.Pos.X
	local py = self.Pos.Y
	for i = -2, 16 do
		self.apx[i] = px
		self.apy[i] = py
		self.lastX[i] = px
		self.lastY[i] = py
	end
	--slots 0 and 11 are ANCHOR POINTS
end

function Update(self)
--HANDLE CAPE
	local i = 11
	--HANDLE ALL CAPE JOINTS
	while i > -1 do
		if i == 0 or i == 10 then
			local usenum = math.max(i,4)
			local usepos = self.Pos + Vector((1-usenum)*self.FlipFactor,7):RadRotate(self.RotAngle)
			self.apx[i] = usepos.X
			self.apy[i] = usepos.Y
			--self.lastX[i] = usepos.X
			--self.lastY[i] = usepos.Y
		else
			--CALCULATE BASIC PHYSICS
				local accX = 0;
				local accY = 0.05;
		
				local velX = self.apx[i] - self.lastX[i];
			local velY = self.apy[i] - self.lastY[i];
		
			local nextX = self.apx[i] + (velX + accX) * self.usefriction;
			local nextY = self.apy[i] + (velY + accY) * self.usefriction;
				
				self.lastX[i] = self.apx[i]
				self.lastY[i] = self.apy[i]

			self.apx[i] = nextX
				self.apy[i] = nextY
		end

		local j = 0

		while j < 2 do
			if i < 11 then
			local cablelength = 4;

				if i == 5 then cablelength = 5 end

					--FROM i+1
					-- calculate the distance
					local diffX = self.apx[i+1] - self.apx[i]
					local diffY = self.apy[i+1] - self.apy[i]
					local d = math.sqrt(math.abs((diffX * diffX) + (diffY * diffY)) )
					local dmin = math.max(d,0.000001)
	
					-- difference scalar
					local difference = (cablelength - d) / dmin;
	
					-- translation for each PointMass. They'll be pushed 1/2 the required distance to match their resting distances.
					local usespring = 0.4 --0.05 + cablespring * 2

					local translateX = diffX * usespring * difference * self.usefriction;
					local translateY = diffY * usespring * difference * self.usefriction;
	
					self.apx[i+1] = self.apx[i+1]+translateX
					self.apy[i+1] = self.apy[i+1]+translateY
					self.apx[i+1] = self.apx[i+1]-translateX
					self.apy[i+1] = self.apy[i+1]-translateY

					--TO i+1
					-- calculate the distance
					local diffX = self.apx[i] - self.apx[i+1]
					local diffY = self.apy[i] -self. apy[i+1]
					local d = math.sqrt(math.abs((diffX * diffX) + (diffY * diffY)) )
					local dmin = math.max(d,0.000001)
	
					-- difference scalar
					local difference = (cablelength - d) / dmin;
					local usespring = 0.45 --0.05 + cablespring * 2

					local translateX = diffX * usespring * difference * self.usefriction;
					local translateY = diffY * usespring * difference * self.usefriction;
	
					local nextX = self.apx[i] + translateX
					local nextY = self.apy[i] + translateY
					self.apx[i] = nextX
					self.apy[i] = nextY

					local nextX = self.apx[i+1] - translateX
					local nextY = self.apy[i+1] - translateY
					self.apx[i+1] = nextX
					self.apy[i+1] = nextY
		
				end
				j=j+1
			end
			i = i-1
	end

--DRAW CAPE

		self.drawcape()

end
