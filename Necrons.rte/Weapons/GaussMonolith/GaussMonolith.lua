function Create(self)
	self.Mass = 1
	self.Sharpness = 17

	local speed = math.abs(self.Vel.Magnitude)

	if speed > 10 then
		local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
		local checkVect = self.Vel * velFactor
		local moid = SceneMan:CastMORay(self.Pos, checkVect, self.ID, self.Team, 0, false, 0)

		if moid ~= 255 and moid ~= 0 then
			self.Mass = 0.85
			self.Sharpness = 14
			local hitMO = MovableMan:GetMOFromID(moid)
			local root = MovableMan:GetMOFromID(hitMO.RootID)

			local swishfx = CreateAEmitter("Gauss Impact")
			swishfx.Vel = self.Vel
			swishfx.Pos = SceneMan:GetLastRayHitPos()
			MovableMan:AddParticle(swishfx)

			--KILLING HIT

			if root:IsActor() and root.ClassName == "AHuman" and root.Mass < 180 then
				local part1 = (850 / root.Mass)

				ToActor(root).Health = ToActor(root).Health - part1

				local swishfx = CreateAEmitter("Gauss Impact")
				swishfx.RotAngle = (self.Vel * GetPPM() * TimerMan.DeltaTimeSecs).AbsRadAngle
				swishfx.Vel = self.Vel
				swishfx.Pos = SceneMan:GetLastRayHitPos()
				MovableMan:AddParticle(swishfx)

				for i = 1, 2 do
					local lightfx = CreateMOPixel("Gauss Lightning Particle")
					lightfx.Vel = self.Vel * 0.08
					lightfx.Pos = self.Pos
					MovableMan:AddParticle(lightfx)
				end

				ToActor(root):ClearMovePath()
				ToActor(root):SetAimAngle(ToActor(root):GetAimAngle(true) + 0.35)
				self.ToDelete = true
			end
		else
			self.Mass = 0.1
			self.Sharpness = 17
		end
	end
end

function Update(self)
	local velrand = math.random(85, 117)
	self.Vel = self.Vel * (velrand * 0.01)

	local rand1 = math.random(36, 67)
	local rand2 = math.random(-47, 47)

	if self.Vel.X > 0 then
		rand1 = math.random(36, 67)
		rand2 = math.random(-47, 47)
	else
		rand1 = math.random(-67, -36)
		rand2 = math.random(-47, 47)
	end

	local rand1 = math.random(-4, 4)
	local rand2 = math.random(-4, 4)

	local rand3 = math.random(-4, 4)
	local rand4 = math.random(-4, 4)

	local chain = CreateMOPixel("Lightning Particle B")
	chain.Pos = Vector(self.Pos.X + rand3, self.Pos.Y + rand4)
	chain.Vel = Vector(rand1 * 4.5, rand2 * 4.5)
	MovableMan:AddParticle(chain)

	local chain2 = CreateMOPixel("Lightning Particle B")
	chain2.Pos = Vector(self.Pos.X + rand1, self.Pos.Y + rand2)
	chain2.Vel = Vector(rand3 * 4.5, rand3 * 4.5)
	MovableMan:AddParticle(chain2)

	local speed = math.abs(self.Vel.Magnitude)

	if speed > 10 then
		local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
		local checkVect = self.Vel * velFactor
		local moid = SceneMan:CastMORay(self.Pos, checkVect, self.ID, self.Team, 0, false, 0)

		if moid ~= 255 and moid ~= 0 then
			self.Mass = 0.65
			self.Sharpness = 13
			local hitMO = MovableMan:GetMOFromID(moid)
			local root = MovableMan:GetMOFromID(hitMO.RootID)

			local swishfx = CreateAEmitter("Gauss Impact")
			swishfx.RotAngle = (self.Vel * GetPPM() * TimerMan.DeltaTimeSecs).AbsRadAngle
			swishfx.Vel = self.Vel
			swishfx.Pos = SceneMan:GetLastRayHitPos()
			MovableMan:AddParticle(swishfx)

			local rand3 = math.random(-4, 4)
			local rand4 = math.random(-4, 4)

			local i = 0

			while i < 13 do
				local lightfx = CreateMOPixel("Gauss Lightning Static Particle")
				lightfx.Vel.X = math.random(-35, 35)
				lightfx.Vel.Y = math.random(-35, 35)
				lightfx.Pos = self.Pos
				MovableMan:AddParticle(lightfx)

				i = i + 1
			end

			--KILLING HIT

			if root:IsActor() and root.ClassName == "AHuman" and root.Mass < 180 then
				local part1 = (450 / root.Mass)

				ToActor(root).Health = ToActor(root).Health - part1

				local swishfx = CreateAEmitter("Gauss Impact")
				swishfx.Vel = self.Vel
				swishfx.Pos = SceneMan:GetLastRayHitPos()
				MovableMan:AddParticle(swishfx)
			end

			self.ToDelete = true
		else
			self.Mass = 1
			self.Sharpness = 1
		end
	end
end
