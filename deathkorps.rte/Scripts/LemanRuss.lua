dofile("Base.rte/Constants.lua")
require("AI/NativeCrabAI") --dofile("Base.rte/AI/NativeCrabAI.lua")

function Create(self)
	self.c = self:GetController()
	self.setalt = 7
	self.moveSound = CreateSoundContainer("Tank Move", "DeathKorps.rte")
	self.idleSound = CreateSoundContainer("Tank Idle", "DeathKorps.rte")

	for attachable in self.Attachables do
		if attachable.PresetName == "Leman Russ Tank Tread" then
			self.treads = attachable
			self.treads.CollidesWithTerrainWhileAttached = false
			self.treads.HitsMOs = true
			self.treads.GetsHitByMOs = false
			break
		end
	end

	self.AI = NativeCrabAI:Create(self)
end

function ThreadedUpdate(self)
	if MovableMan:ValidMO(self) then
		if self.Health < 1 then
			self.AngularVel = self.AngularVel * 0.85
			if self.idleSound:IsBeingPlayed() then
				self.idleSound:Stop()
			end
		else
			if not self.idleSound:IsBeingPlayed() then
				self.idleSound:Play(self.Pos)
			end
			if not self.treads then
				for attachable in self.Attachables do
					if attachable.PresetName == "Leman Russ Tank Tread" then
						self.treads = attachable
						self.treads.CollidesWithTerrainWhileAttached = false
						self.treads.HitsMOs = true
						self.treads.GetsHitByMOs = false
						break
					end
				end
			end
		end

		self.Scale = 0.95
		self.treads.Scale = 0.95
		self:MoveOutOfTerrain(-0.5)

		--propulsion, stabilisation
		if self.Vel.Y > -1 then
			local terrcheck = Vector(0, 0)

			local groundray = SceneMan:CastStrengthRay(
				self.Pos + Vector(-28 * self.FlipFactor, 3):RadRotate(self.RotAngle),
				Vector(55 * self.FlipFactor, 3):RadRotate(self.RotAngle),
				0,
				terrcheck,
				1,
				0,
				true
			)
			local groundray2 = SceneMan:CastStrengthRay(
				self.Pos + Vector(-85 * self.FlipFactor, 0):RadRotate(self.RotAngle),
				Vector(55 * self.FlipFactor, 3):RadRotate(self.RotAngle),
				0,
				terrcheck,
				1,
				0,
				true
			)
			local groundray3 = SceneMan:CastStrengthRay(
				self.Pos + Vector(28 * self.FlipFactor, 3):RadRotate(self.RotAngle),
				Vector(-55 * self.FlipFactor, 3):RadRotate(self.RotAngle),
				0,
				terrcheck,
				1,
				0,
				true
			)
			local groundray4 = SceneMan:CastStrengthRay(
				self.Pos + Vector(55 * self.FlipFactor, 0):RadRotate(self.RotAngle),
				Vector(-55 * self.FlipFactor, 3):RadRotate(self.RotAngle),
				0,
				terrcheck,
				1,
				0,
				true
			)

			if groundray == true then
				self:AddAbsForce(Vector(0, -6000), self.Pos + Vector(-28 * self.FlipFactor, 0):RadRotate(self.RotAngle))
			end
			if groundray2 == true then
				self:AddAbsForce(
					Vector(0, -7000),
					self.Pos + Vector(-85 * self.FlipFactor, -15):RadRotate(self.RotAngle)
				)
			end
			if groundray3 == true then
				self:AddAbsForce(Vector(0, -6000), self.Pos + Vector(28 * self.FlipFactor, 0):RadRotate(self.RotAngle))
			end
			if groundray4 == true then
				self:AddAbsForce(
					Vector(0, -7000),
					self.Pos + Vector(85 * self.FlipFactor, -15):RadRotate(self.RotAngle)
				)
			end
		end

		local frame = self.treads.Frame

		if self.Vel.X < 8 and self.c:IsState(3) then
			self.Vel.X = self.Vel.X + (math.cos(self.RotAngle) * 0.07)
			self.Vel.Y = self.Vel.Y - (math.sin(self.RotAngle) * 0.07)
			frame = frame + 1 * self.FlipFactor
			if not self.moveSound:IsBeingPlayed() then
				self.moveSound:Play(self.Pos)
			end
		elseif self.Vel.X > -8 and self.c:IsState(4) then
			self.Vel.X = self.Vel.X - (math.cos(self.RotAngle) * 0.07)
			self.Vel.Y = self.Vel.Y + (math.sin(self.RotAngle) * 0.07)
			frame = frame - 1 * self.FlipFactor
			if not self.moveSound:IsBeingPlayed() then
				self.moveSound:Play(self.Pos)
			end
		else
			self.Vel.X = self.Vel.X * 0.80
			if self.moveSound:IsBeingPlayed() then
				self.moveSound:Stop()
			end
		end

		if frame > 5 then
			self.treads.Frame = 0
		else
			self.treads.Frame = frame
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
