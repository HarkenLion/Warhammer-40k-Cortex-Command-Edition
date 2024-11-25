function Create(self)
	self.fireTimer = Timer()
	self.gunfrontkick = 0
	self.gunaccel = 0
	self.shellejected = false

	self.headname = "Battle Cannon Front"
	for attachable in self.Attachables do
		if attachable.PresetName == self.headname then
			self.GunFront = attachable
			self.GunFront.GetsHitByMOs = false
			actor = MovableMan:GetMOFromID(attachable.RootID)
			self.operator = ToActor(actor)
			break
		end
	end

	self.GetsHitByMOs = false
	self.ejectSound = CreateSoundContainer("Tank Eject", "deathkorps.rte")
end

function OnFire(self)
	self.fireTimer:Reset()
	self.gunfrontkick = -9
	self.gunaccel = 0
	self.shellejected = false

	if MovableMan:ValidMO(self.operator) then
		self.operator:AddAbsForce(
			Vector(-40500 * self.operator.FlipFactor, 0):RadRotate(self.RotAngle),
			Vector(-10 * self.operator.FlipFactor, -30):RadRotate(self.operator.RotAngle)
		)
	end
end

function Update(self)
	if self.GunFront then
		self.GunFront.ParentOffset = Vector(5 + self.gunfrontkick, 0)
	else
		for attachable in self.Attachables do
			if attachable.PresetName == self.headname then
				self.GunFront = attachable
				self.GunFront.GetsHitByMOs = false
				actor = MovableMan:GetMOFromID(attachable.RootID)
				self.operator = ToActor(actor)
				break
			end
		end
	end
	if self.gunfrontkick < 0 then
		if not self.fireTimer:IsPastSimMS(55) then
			self.gunaccel = self.gunaccel - 0.0125
			self.GunFront.Frame = 2
		else
			self.GunFront.Frame = 0
		end
		if self.fireTimer:IsPastSimMS(205) then
			if self.gunaccel < 2 then
				self.gunaccel = self.gunaccel + 0.00625
			end

			if self.shellejected == false and self.fireTimer:IsPastSimMS(650) then
				if self.operator then
					local cannoncasing = CreateMOSRotating("Cannon Casing", "deathkorps.rte")
					cannoncasing.Pos = self.operator.Pos
						+ Vector(-5 * self.operator.FlipFactor, -45):RadRotate(self.operator.RotAngle)
					cannoncasing.Team = self.Team
					cannoncasing.Vel = Vector(-7 * self.operator.FlipFactor, -3):RadRotate(self.operator.RotAngle)
					cannoncasing.IgnoresTeamHits = true
					MovableMan:AddParticle(cannoncasing)
					self.ejectSound:Play(self.Pos)
				end
				self.shellejected = true
			end
		end
		self.gunfrontkick = self.gunfrontkick + self.gunaccel
	end
end
