function Create(self)
	self.fireTimer = Timer()
	self.gunfrontkick = 0
	self.gunaccel = 0
	self.shellejected = false
	self.hatchopen = false
	self.prevRot = self.RotAngle
	self.headname = "Earth Shaker Cannon"

	for attachable in self.Attachables do
		if attachable.PresetName == "Earth Shaker Cannon" then
			self.GunFront = attachable
			self.GunFront.GetsHitByMOs = false
			actor = self:GetRootParent() --MovableMan:GetMOFromID(attachable.RootID)
			self.operator = ToActor(actor)
			break
		end
	end

	for attachable in self.Attachables do
		if attachable.PresetName == "Earth Shaker Inner Cannon" then
			self.GunFront2 = attachable
			self.GunFront2.GetsHitByMOs = false
			break
		end
	end

	self.GetsHitByMOs = false
	self.ejectSound = CreateSoundContainer("Tank Eject", "deathkorps.rte")
end

function OnFire(self)
	self.fireTimer:Reset()
	self.gunfrontkick = -12 ---9
	self.gunaccel = 0
	self.shellejected = false

	if MovableMan:ValidMO(self.operator) then
		self.operator:AddAbsForce(
			Vector(-10120 * self.operator.FlipFactor, 0):RadRotate(self.RotAngle),
			Vector(-10 * self.operator.FlipFactor, -15):RadRotate(self.operator.RotAngle)
		)
		self.operator:AddAbsForce(
			Vector(0, 5120 * self.operator.FlipFactor),
			Vector(25 * self.operator.FlipFactor, -5):RadRotate(self.operator.RotAngle)
		)
		CameraMan:AddScreenShake(25, self.Pos)
	end

	for i = 0, 4 do
		local e = CreateMOSParticle("Fire Puff Large")
		e.Vel.X = math.random(-5, 5)
		e.Vel.Y = math.random(-5, 5)
		e.Pos = self.MuzzlePos + Vector(55 * self.FlipFactor, 0):RadRotate(self.RotAngle)
		MovableMan:AddMO(e)
	end
end

function Update(self)
	if self.RotAngle ~= self.prevRot then
		if MovableMan:ValidMO(self.operator) and MovableMan:ValidMO(self.operator.Turret) then
			self.operator.Turret.Frame = self.operator.Turret.Frame + 1
		end
	end

	--TRACK OUTER BARREL
	if self.GunFront then
		self.GunFront.ParentOffset = Vector(8 + self.gunfrontkick, -1)
	else
		for attachable in self.Attachables do
			if attachable.PresetName == "Earth Shaker Cannon" then
				self.GunFront = attachable
				self.GunFront.GetsHitByMOs = false

				actor = self:GetRootParent() --MovableMan:GetMOFromID(attachable.RootID)
				self.operator = ToActor(actor)
				break
			end
		end
	end
	--TRACK INNER BARREL
	if self.GunFront2 then
		self.GunFront2.ParentOffset = Vector(40 + self.gunfrontkick * 2.5, -2)
	else
		for attachable in self.Attachables do
			if attachable.PresetName == "Earth Shaker Inner Cannon" then
				self.GunFront2 = attachable
				self.GunFront2.GetsHitByMOs = false
				break
			end
		end
	end

	if self.gunfrontkick < 0 then
		if not self.fireTimer:IsPastSimMS(15) then
			self.gunaccel = self.gunaccel - 0.0125
		end
		if self.fireTimer:IsPastSimMS(35) then
			if self.gunaccel < 2 then
				self.gunaccel = self.gunaccel + 0.003125
			end

			if self.shellejected == false and self.fireTimer:IsPastSimMS(850) then
				if MovableMan:ValidMO(self.operator) then
					local cannoncasing = CreateMOSRotating("Cannon Casing", "deathkorps.rte")
					cannoncasing.Pos = self.operator.Pos
						+ Vector(-10 * self.operator.FlipFactor, -39):RadRotate(
							self.operator.RotAngle
						)
						+ Vector(-25 * self.operator.FlipFactor, 0):RadRotate(self.RotAngle)
					cannoncasing.Team = self.Team
					cannoncasing.Vel = Vector(-7 * self.operator.FlipFactor, -3):RadRotate(self.RotAngle)
					cannoncasing.IgnoresTeamHits = true
					MovableMan:AddParticle(cannoncasing)
					self.ejectSound:Play(self.Pos)
				end
				if self.GunFront then --MovableMan:ValidMO(self.GunFront) then
					self.GunFront.Frame = 1
					self.hatchopen = true
					print("openhatch")
				end
				self.shellejected = true
			end
		end
		self.gunfrontkick = self.gunfrontkick + self.gunaccel
	end

	if self.hatchopen == true and self.shellejected == true and self.fireTimer:IsPastSimMS(3350) then
		if self.GunFront then --MovableMan:ValidMO(self.GunFront) then
			self.GunFront.Frame = 0
			self.hatchopen = false
			print("closehatch")
		end
	end
	self.prevRot = self.RotAngle
end
