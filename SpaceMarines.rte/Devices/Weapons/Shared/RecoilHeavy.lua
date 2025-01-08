function Create(self)

	self.recoil = 0;

	self.firecounter = 0;
	self.recoilcooldown = 0.0002;
	self.firetimer = Timer();
	self.cablesegs = 5;

	function self.drawcable()
		for i = 0, self.cablesegs-1 do
			PrimitiveMan:DrawLinePrimitive(Vector(self.apx[i],self.apy[i]),Vector(self.apx[i+1],self.apy[i+1]),89,3)
			PrimitiveMan:DrawLinePrimitive(Vector(self.apx[i],self.apy[i]),Vector(self.apx[i+1],self.apy[i+1]),245,1)
		end
	end

	--ESTABLISH CABLE
	self.apx = {};
	self.apy = {};

	self.lastX = {};
	self.lastY = {}

	self.usefriction = 0.96;

	local px = self.Pos.X
	local py = self.Pos.Y
	for i = 0, self.cablesegs do
		self.apx[i] = px
		self.apy[i] = py
		self.lastX[i] = px
		self.lastY[i] = py
	end
end

function OnReload(self)
	self.recoil = 0;
	local px = self.Pos.X
	local py = self.Pos.Y
	for i = 0, self.cablesegs do
		self.apx[i] = px
		self.apy[i] = py
		self.lastX[i] = px
		self.lastY[i] = py
	end
end

function OnAttach(self)
	local px = self.Pos.X
	local py = self.Pos.Y
	for i = 0, self.cablesegs do
		self.apx[i] = px
		self.apy[i] = py
		self.lastX[i] = px
		self.lastY[i] = py
	end
end

function OnFire(self)
	local recoil2 = self.recoil;
	if recoil2 < 0.022 then
		local user 
		user = MovableMan:GetMOFromID(self.RootID);

		self.recoil = recoil2 + 0.004 + (4 - user.Sharpness) * 0.65 * 0.0055;
		self.firetimer:Reset();
	end

	local i = math.random(1,self.cablesegs-1)
	self.lastX[i] =self.lastX[i]+math.random(-1,1)
	self.lastY[i] =self.lastY[i]+math.random(-1,1)

end

function OnReload(self)
	self.recoil = 0;
end

function Update(self)
	if self.RootID ~= self.ID then
		if self:IsReloading() then
			if self.ReloadProgress == 1 then
				local px = self.Pos.X
				local py = self.Pos.Y
				for i = 0, self.cablesegs do
					self.apx[i] = px
					self.apy[i] = py
					self.lastX[i] = px
					self.lastY[i] = py
				end
			end
		else
			--HANDLE CABLE
			local i = self.cablesegs
			--HANDLE ALL CABLE JOINTS
			while i > -1 do
				if i == 0 or i == self.cablesegs then
					if i == self.cablesegs then
						local FlipFactor = 1
						if self.HFlipped then FlipFactor = -1 end
						local usepos = self.Pos + Vector((7)*FlipFactor,7):RadRotate(self.RotAngle)
						self.apx[i] = usepos.X
						self.apy[i] = usepos.Y
					else
						if MovableMan:ValidMO(MovableMan:GetMOFromID(self.RootID)) then
							local root = ToActor(MovableMan:GetMOFromID(self.RootID))
							local FlipFactor = 1
							if MovableMan:ValidMO(root) then
								if root.HFlipped then FlipFactor = -1 end
								local rootpos = root.Pos
								if root.ClassName == "ACrab" then 
									rootpos = self.Pos
								end
								local usepos = rootpos + Vector((-8)*FlipFactor,4):RadRotate(root.RotAngle)
								self.apx[i] = usepos.X
								self.apy[i] = usepos.Y
							end
						end
					end
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
					if i < self.cablesegs then
					local cablelength = 6;
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
	
			--DRAW CABLE
			self.drawcable()
	
		end

		--if not self:IsAtRest() then
			if self.Magazine then
					local randb = math.random(-3,3);
					local recoil = self.recoil
					local recoilrand = randb * recoil;
					self.RotAngle = self.RotAngle + recoilrand;

				if self.firetimer:IsPastSimMS(100) then
					if recoil > 0 then
						local user 
						user = MovableMan:GetMOFromID(self.RootID);
						self.recoil = recoil - self.recoilcooldown * user.Sharpness;

					elseif recoil < 0 then
						self.recoil = 0;
					end
				end
			end
		--end
	end


end 