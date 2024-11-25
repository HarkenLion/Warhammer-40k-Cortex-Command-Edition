dofile("Base.rte/Constants.lua")
require("AI/NativeCrabAI") --dofile("Base.rte/AI/NativeCrabAI.lua")

function Create(self)
	self.c = self:GetController()
	self.setalt = 7

	local MoObj4
	for i = 1, MovableMan:GetMOIDCount() - 1 do
		MoObj4 = MovableMan:GetMOFromID(i)
		if MoObj4.PresetName == "Leman Russ Tank Tread" and MoObj4.RootID == self.ID then
			self.treads = ToAttachable(MovableMan:GetMOFromID(MoObj4.ID))
		end
	end

	local MoObj4
	for i = 1, MovableMan:GetMOIDCount() - 1 do
		MoObj4 = MovableMan:GetMOFromID(i)
		if MoObj4.PresetName == "LemanRuss Turret" and MoObj4.RootID == self.ID then
			self.turret = ToAttachable(MovableMan:GetMOFromID(MoObj4.ID))
		end
	end

	--self.treads.GetsHitByMOs = false;

	self.AI = NativeCrabAI:Create(self)
end

function Update(self)
	if self.Health < 1 then
		self.AngularVel = self.AngularVel * 0.85
	end

	self.Scale = 0.95
	self.treads.Scale = 0.95
	self:MoveOutOfTerrain(-0.5)

	--propulsion, stabilisation

	local terrcheck = Vector(0, 0)

	local groundray = SceneMan:CastStrengthRay(
		self.Pos + Vector(-28, 7):RadRotate(self.RotAngle),
		Vector(55, 0):RadRotate(self.RotAngle),
		0,
		terrcheck,
		1,
		0,
		true
	)
	local groundray2 = SceneMan:CastStrengthRay(
		self.Pos + Vector(-85, 0):RadRotate(self.RotAngle),
		Vector(55, 7):RadRotate(self.RotAngle),
		0,
		terrcheck,
		1,
		0,
		true
	)
	local groundray3 = SceneMan:CastStrengthRay(
		self.Pos + Vector(28, 7):RadRotate(self.RotAngle),
		Vector(-55, 0):RadRotate(self.RotAngle),
		0,
		terrcheck,
		1,
		0,
		true
	)
	local groundray4 = SceneMan:CastStrengthRay(
		self.Pos + Vector(85, 0):RadRotate(self.RotAngle),
		Vector(-55, 7):RadRotate(self.RotAngle),
		0,
		terrcheck,
		1,
		0,
		true
	)

	if groundray == true then
		self:AddAbsForce(Vector(0, -7000), self.Pos + Vector(-28, 0):RadRotate(self.RotAngle))
	end
	if groundray2 == true then
		self:AddAbsForce(Vector(0, -7000), self.Pos + Vector(-85, -15):RadRotate(self.RotAngle))
	end
	if groundray3 == true then
		self:AddAbsForce(Vector(0, -7000), self.Pos + Vector(28, 0):RadRotate(self.RotAngle))
	end
	if groundray4 == true then
		self:AddAbsForce(Vector(0, -7000), self.Pos + Vector(85, -15):RadRotate(self.RotAngle))
	end
	-- if (groundray == true and self.HFlipped == true) or (groundray2 == true and self.HFlipped == true) then
	-- 	self.RotAngle = self.RotAngle - 0.005;
	-- else
	-- 	self.RotAngle = self.RotAngle + 0.001;
	-- end
	-- if (groundray3 == true and self.HFlipped == false) or (groundray4 == true and self.HFlipped == false) then
	-- 	self.RotAngle = self.RotAngle + 0.005;
	-- else
	-- 	self.RotAngle = self.RotAngle - 0.001;
	-- end

	self.alt = self:GetAltitude(0, 1)

	if self.alt < self.setalt and self.Vel.Y > -5 then
		self.Vel.Y = self.Vel.Y - 0.25 --0.5;
	end

	if self.Vel.Y > 1 then
		self.Vel.Y = self.Vel.Y - 0.05
	end
	self.Vel.Y = 0.985 * self.Vel.Y

	local frame = self.treads.Frame

	if self.Vel.X < 8 and self.c:IsState(3) then
		self.Vel.X = self.Vel.X + (math.cos(self.RotAngle) * 0.07)
		self.Vel.Y = self.Vel.Y - (math.sin(self.RotAngle) * 0.07)
		frame = frame + 1
	elseif self.Vel.X > -8 and self.c:IsState(4) then
		self.Vel.X = self.Vel.X - (math.cos(self.RotAngle) * 0.07)
		self.Vel.Y = self.Vel.Y + (math.sin(self.RotAngle) * 0.07)
		frame = frame + 1
	else
		self.Vel.X = self.Vel.X * 0.80
	end

	if frame > 5 then
		self.treads.Frame = 0
	else
		self.treads.Frame = frame
	end

	if self:IsPlayerControlled() and UInputMan:KeyHeld(24) then
		self.RotAngle = self.RotAngle - 0.1
		if self.AngularVel > 30 then
			self.angularVel = self.AngularVel - 2
		end
		if self.angularVel < -30 then
			self.AngularVel = self.AngularVel + 2
		end
	end

	if self:IsPlayerControlled() and UInputMan:KeyHeld(26) then
		self.RotAngle = self.RotAngle + 0.1
		if self.AngularVel > 30 then
			self.angularVel = self.AngularVel - 2
		end
		if self.angularVel < -30 then
			self.AngularVel = self.AngularVel + 2
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
