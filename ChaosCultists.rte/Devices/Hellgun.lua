function Create(self)
	self.recoil = 0
	self.firecounter = 0
	self.recoilcooldown = 0.00006
	self.firetimer = Timer()
	self.Scale = 0.95

	function self.drawcable()
		for i = 0, 10 do
			PrimitiveMan:DrawLinePrimitive(
				Vector(self.apx[i], self.apy[i]),
				Vector(self.apx[i + 1], self.apy[i + 1]),
				245,
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
	for i = 0, 11 do
		self.apx[i] = px
		self.apy[i] = py
		self.lastX[i] = px
		self.lastY[i] = py
	end
	--slots 0 and 11 are ANCHOR POINTS
end

function OnReload(self)
	local px = self.Pos.X
	local py = self.Pos.Y
	for i = 0, 11 do
		self.apx[i] = px
		self.apy[i] = py
		self.lastX[i] = px
		self.lastY[i] = py
	end
end

function OnAttach(self)
	local px = self.Pos.X
	local py = self.Pos.Y
	for i = 0, 11 do
		self.apx[i] = px
		self.apy[i] = py
		self.lastX[i] = px
		self.lastY[i] = py
	end
end

function OnFire(self)
	if self.RootID ~= self.ID then
		local recoil2 = self.recoil
		if recoil2 < 0.024 then
			local user
			user = MovableMan:GetMOFromID(self.RootID)

			self.recoil = recoil2 + 0.0009 + (4 - user.Sharpness) * 0.65 * 0.0005
			self.firetimer:Reset()
		end

		local sfx = CreateAEmitter("Las Muzzle Flash")
		sfx.Pos = self.MuzzlePos

		if self.HFlipped then
			sfx.RotAngle = self.RotAngle + math.pi
		else
			sfx.RotAngle = self.RotAngle
		end

		sfx.Team = self.Team
		sfx.IgnoresTeamHits = true

		MovableMan:AddParticle(sfx)

		local vect = Vector(1905, 0)
		vect = vect:RadRotate(sfx.RotAngle)
		vect = vect:SetMagnitude(1905)
		rayL = SceneMan:CastObstacleRay(
			Vector(self.MuzzlePos.X, self.MuzzlePos.Y),
			vect,
			vect,
			vect,
			self.ID,
			self.Team,
			0,
			2
		)

		--WEAPON DISCHARGE

		if rayL > -1 then
			local hitpos = SceneMan:GetLastRayHitPos()
			local Range = SceneMan:ShortestDistance(self.MuzzlePos, hitpos, false)
			local angle = Range.AbsRadAngle

			local pulseexplosion = CreateMOPixel("Rifle Las Particle Hit")
			pulseexplosion.Pos = hitpos
			pulseexplosion.Team = self.Team
			pulseexplosion.Vel = Vector(115, 0):RadRotate(angle)
			pulseexplosion.IgnoresTeamHits = true
			MovableMan:AddParticle(pulseexplosion)

			local pulseexplosion2 = CreateMOPixel("Rifle Las Particle Light Hit")
			pulseexplosion2.Pos = hitpos
			pulseexplosion2.Team = self.Team
			pulseexplosion2.Vel = Vector(120, 0):RadRotate(angle)
			pulseexplosion2.IgnoresTeamHits = true
			MovableMan:AddParticle(pulseexplosion2)

			PrimitiveMan:DrawLinePrimitive(self.MuzzlePos, hitpos, 13, 2)

			local smoke = CreateMOPixel("Rifle Las Contact Flash Hellgun")
			smoke.Pos = SceneMan:GetLastRayHitPos()
			MovableMan:AddParticle(smoke)

			local smoke2 = CreateMOSParticle("Small Smoke Ball 1", "Base.rte")
			smoke2.Pos = SceneMan:GetLastRayHitPos()
			MovableMan:AddParticle(smoke2)
		else
			PrimitiveMan:DrawLinePrimitive(self.MuzzlePos, self.MuzzlePos + self:RotateOffset(Vector(1900, 0)), 13, 2)
		end

		--END WEAPON DISCHARGE
	end
end

function OnReload(self)
	self.recoil = 0
end

function Update(self)
	if self.RootID ~= self.ID then
		--if not self:IsReloading() then
		if self:IsReloading() then
			if self.ReloadProgress == 1 then
				local px = self.Pos.X
				local py = self.Pos.Y
				for i = 0, 11 do
					self.apx[i] = px
					self.apy[i] = py
					self.lastX[i] = px
					self.lastY[i] = py
				end
			end
		end

		if self.Magazine then
			--HANDLE CABLE
			local i = 11
			--HANDLE ALL CABLE JOINTS
			while i > -1 do
				if i == 0 or i == 5 or i == 11 then
					if i == 5 then
						local FlipFactor = 1
						if self.HFlipped then
							FlipFactor = -1
						end
						local usepos = self.Pos + Vector(4 * FlipFactor, 4):RadRotate(self.RotAngle)
						self.apx[i] = usepos.X
						self.apy[i] = usepos.Y
					else
						if MovableMan:ValidMO(MovableMan:GetMOFromID(self.RootID)) then
							local root = ToActor(MovableMan:GetMOFromID(self.RootID))
							local FlipFactor = 1
							if MovableMan:ValidMO(root) then
								if root.HFlipped then
									FlipFactor = -1
								end
								local usepos = root.Pos + Vector(-7 * FlipFactor, -7):RadRotate(root.RotAngle)
								self.apx[i] = usepos.X
								self.apy[i] = usepos.Y
							end
						end
					end
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
					if i < 11 then
						local cablelength = 5
						--FROM i+1
						-- calculate the distance
						local diffX = self.apx[i + 1] - self.apx[i]
						local diffY = self.apy[i + 1] - self.apy[i]
						local d = math.sqrt(math.abs((diffX * diffX) + (diffY * diffY)))
						local dmin = math.max(d, 0.000001)

						-- difference scalar
						local difference = (cablelength - d) / dmin

						-- translation for each PointMass. They'll be pushed 1/2 the required distance to match their resting distances.
						local usespring = 0.4 --0.05 + cablespring * 2

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
						local usespring = 0.45 --0.05 + cablespring * 2

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

		local recoilrand = 0
		local recoil = self.recoil
		if recoil > 0 then
			local randb = math.random(-4, 4)
			recoilrand = randb * recoil
		end
		self.RotAngle = self.RotAngle + recoilrand

		if self.firetimer:IsPastSimMS(80) then
			if recoil > 0 then
				local user
				user = MovableMan:GetMOFromID(self.RootID)
				self.recoil = recoil - (self.recoilcooldown * user.Sharpness)
			elseif recoil < 0 then
				self.recoil = 0
			end
		end
		--end
	end
end
