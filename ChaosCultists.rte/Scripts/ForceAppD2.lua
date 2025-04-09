dofile("Base.rte/Constants.lua")
dofile("spacemarines.rte/Scripts/AI/NativeBroadsideAI.lua")
require("AI/NativeHumanAI")

function Create(self)
	self.enableselect = true
	self.Turret = {}

	local TurretOffsets = {
		{ Position = Vector(6, -60), Weapon = "Broadsidee Shoulder Plasma Pod" }, -- Turret 1
		{ Position = Vector(-1, -29), Weapon = "Broadsidd Shoulder Plasma Pod" }, -- Turret 2
		{ Position = Vector(-1, -29), Weapon = "Broadsidd Shoulder Plasma Pod" }, -- Turret 3
	}

	for i, Turrets in pairs(TurretOffsets) do
		self.Turret[i] = CreateACrab(Turrets.Weapon)
		self.Turret[i].Team = self.Team
		self.Turret[i].Offset = Turrets.Position
		MovableMan:AddActor(self.Turret[i])
	end

	self.AI = NativeBroadsideAI:Create(self)
	self.c = self:GetController()

	self.triggerang = math.pi / 3 --4
	self.musclemult = 0.5 -- --1.25 --2.5 --1.5
	self.pscale = GetPPM() * self.musclemult
	self.FGFootPrevPos = self.FGFoot.Pos.X - self.Pos.X
	self.BGFootPrevPos = self.BGFoot.Pos.X - self.Pos.X
	self.kneedist = 12

	self.c = self:GetController()
	self.AI = NativeHumanAI:Create(self)

	self.triggerang = math.pi / 3 --4 --4
	self.triggerangBG = math.pi / 3 --4
	self.musclemult = 0.5 --1 --2 --4 --1.5; --1.25 --2.5 --1.5
	self.pscale = GetPPM() * self.musclemult
	self.FGFootPrevPos = self.FGFoot.Pos.X - self.Pos.X
	self.BGFootPrevPos = self.BGFoot.Pos.X - self.Pos.X
	self.kneedist = 12 --2
	self.footheight = 6 --4

	self.fglegpushed = 0
	self.bglegpushed = 0
	self.BGFoot.getsHitByMOs = 1
	self.FGFoot.getsHitByMOs = 1
end

function Update(self)
	if self.c:IsState(3) then
		local terrcheck = Vector(0, 0)
		--MOVING RIGHT
		if self.FlipFactor == 1 then
			--FORWARD LEG PULL
			if self.FGLeg and self.FGFoot and self.FGLeg.RotAngle < self.triggerang then
				if self.fglegpushed < 5 then
					local groundray = SceneMan:CastStrengthRay(
						self.FGFoot.Pos,
						Vector(3 * self.FlipFactor, self.footheight):RadRotate(self.FGFoot.RotAngle),
						0,
						terrcheck,
						1,
						0,
						true
					)
					if groundray == true then
						local up1 = Vector(self.FGFootPrevPos, 0)
						local up2 = Vector(self.FGFoot.Pos.X - self.Pos.X, 0)
						local xchange = SceneMan:ShortestDistance(up1, up2, true).Magnitude
						local usemass = (self.FGLeg.Mass + self.FGFoot.Mass)
						local addforce = self.pscale * xchange * usemass
						local addforcey = -1 * self.pscale * usemass * self.FlipFactor
						local usepos = self.FGLeg.Pos + Vector(2 * self.FlipFactor, -self.kneedist * 2)
						local getang = SceneMan:ShortestDistance(self.Pos, usepos, true).AbsRadAngle
						self:AddAbsForce(
							Vector(addforce, addforcey):RadRotate(getang),
							self.Pos + Vector(2 * self.FlipFactor, -10)
						)
						self.FGLeg:AddAbsForce(Vector(addforce, -addforcey * 0.5):RadRotate(getang), self.FGLeg.Pos)
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13);
						self.fglegpushed = self.fglegpushed + 1
					end
				end
			end
			if self.BGLeg and self.BGFoot and self.BGLeg.RotAngle < self.triggerang then
				if self.bglegpushed < 5 then
					local groundray = SceneMan:CastStrengthRay(
						self.BGFoot.Pos,
						Vector(3 * self.FlipFactor, self.footheight):RadRotate(self.BGFoot.RotAngle),
						0,
						terrcheck,
						1,
						0,
						true
					)
					if groundray == true then
						local up1 = Vector(self.BGFootPrevPos, 0)
						local up2 = Vector(self.BGFoot.Pos.X - self.Pos.X, 0)
						local xchange = SceneMan:ShortestDistance(up1, up2, true).Magnitude
						local usemass = (self.BGLeg.Mass + self.BGFoot.Mass)
						local addforce = self.pscale * xchange * usemass
						local addforcey = -1 * self.pscale * usemass * self.FlipFactor
						local usepos = self.BGLeg.Pos + Vector(2 * self.FlipFactor, -self.kneedist * 2)
						local getang = SceneMan:ShortestDistance(self.Pos, usepos, true).AbsRadAngle
						self:AddAbsForce(
							Vector(addforce, addforcey):RadRotate(getang),
							self.Pos + Vector(2 * self.FlipFactor, -10)
						)
						self.BGLeg:AddAbsForce(Vector(addforce, -addforcey * 0.5):RadRotate(getang), self.BGLeg.Pos)
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13);
						self.bglegpushed = self.bglegpushed + 1
					end
				end
			end
			--BACK LEG PUSH
			if self.FGLeg and self.FGFoot and self.FGLeg.RotAngle > self.triggerangBG then
				if self.fglegpushed > 0 then
					local groundray = SceneMan:CastStrengthRay(
						self.FGFoot.Pos,
						Vector(3 * self.FlipFactor, self.footheight):RadRotate(self.FGFoot.RotAngle),
						0,
						terrcheck,
						1,
						0,
						true
					)
					if groundray == true then
						local up1 = Vector(self.FGFootPrevPos, 0)
						local up2 = Vector(self.FGFoot.Pos.X - self.Pos.X, 0)
						local xchange = SceneMan:ShortestDistance(up1, up2, true).Magnitude
						local usemass = (self.FGLeg.Mass + self.FGFoot.Mass)
						local addforce = self.pscale * xchange * usemass
						--local addforcey = -1*self.pscale*usemass*self.FlipFactor
						local usepos = self.FGLeg.Pos --+Vector(2*self.FlipFactor,self.footheight):RadRotate(self.FGLeg.RotAngle)
						local getang = SceneMan:ShortestDistance(usepos, self.Pos, true).AbsRadAngle
						self:AddAbsForce(Vector(addforce, 0):RadRotate(getang), self.Pos)
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5);
						self.fglegpushed = self.fglegpushed - 1
					end
				end
			end
			if self.BGLeg and self.BGFoot and self.BGLeg.RotAngle > self.triggerangBG then
				if self.bglegpushed > 0 then
					local groundray = SceneMan:CastStrengthRay(
						self.BGFoot.Pos,
						Vector(3 * self.FlipFactor, self.footheight):RadRotate(self.BGFoot.RotAngle),
						0,
						terrcheck,
						1,
						0,
						true
					)
					if groundray == true then
						local up1 = Vector(self.BGFootPrevPos, 0)
						local up2 = Vector(self.BGFoot.Pos.X - self.Pos.X, 0)
						local xchange = SceneMan:ShortestDistance(up1, up2, true).Magnitude
						local usemass = (self.BGLeg.Mass + self.BGFoot.Mass)
						local addforce = self.pscale * xchange * usemass
						--local addforcey = -1*self.pscale*usemass*self.FlipFactor
						local usepos = self.BGLeg.Pos --+Vector(2*self.FlipFactor,self.footheight):RadRotate(self.BGLeg.RotAngle)
						local getang = SceneMan:ShortestDistance(usepos, self.Pos, true).AbsRadAngle
						self:AddAbsForce(Vector(addforce, 0):RadRotate(getang), self.Pos)
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5);
						self.bglegpushed = self.bglegpushed - 1
					end
				end
			end
		end
	elseif self.c:IsState(4) then
		local terrcheck = Vector(0, 0)
		--MOVING LEFT
		if self.FlipFactor == -1 then
			--FRONT LEG PULL
			if
				self.FGLeg
				and self.FGFoot
				and self.FGFoot.Pos.X < self.Pos.X
				and self.FGLeg.RotAngle > math.pi + self.triggerang
			then
				if self.fglegpushed < 5 then
					local groundray = SceneMan:CastStrengthRay(
						self.FGFoot.Pos,
						Vector(3 * self.FlipFactor, self.footheight):RadRotate(self.FGFoot.RotAngle),
						0,
						terrcheck,
						1,
						0,
						true
					)
					if groundray == true then
						local xchange = SceneMan:ShortestDistance(
							Vector(self.FGFootPrevPos, 0),
							Vector(self.FGFoot.Pos.X - self.Pos.X, 0),
							true
						).Magnitude
						local usemass = (self.FGLeg.Mass + self.FGFoot.Mass)
						local addforce = self.pscale * xchange * usemass
						local addforcey = -1 * self.pscale * usemass * self.FlipFactor
						local usepos = self.FGLeg.Pos + Vector(2 * self.FlipFactor, -self.kneedist * 2)
						local getang = SceneMan:ShortestDistance(self.Pos, usepos, true).AbsRadAngle
						self:AddAbsForce(
							Vector(addforce, addforcey):RadRotate(getang),
							self.Pos + Vector(2 * self.FlipFactor, -10)
						)
						self.FGLeg:AddAbsForce(Vector(addforce, -addforcey * 0.5):RadRotate(getang), self.FGLeg.Pos)
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13);
						self.fglegpushed = self.fglegpushed + 1
					end
				end
			end
			if
				self.BGLeg
				and self.BGFoot
				and self.BGFoot.Pos.X < self.Pos.X
				and self.BGLeg.RotAngle > math.pi + self.triggerang
			then
				if self.bglegpushed < 5 then
					local groundray = SceneMan:CastStrengthRay(
						self.BGFoot.Pos,
						Vector(3 * self.FlipFactor, self.footheight):RadRotate(self.BGFoot.RotAngle),
						0,
						terrcheck,
						1,
						0,
						true
					)
					if groundray == true then
						local xchange = SceneMan:ShortestDistance(
							Vector(self.BGFootPrevPos, 0),
							Vector(self.BGFoot.Pos.X - self.Pos.X, 0),
							true
						).Magnitude
						local usemass = (self.BGLeg.Mass + self.BGFoot.Mass)
						local addforce = self.pscale * xchange * usemass
						local addforcey = -1 * self.pscale * usemass * self.FlipFactor
						local usepos = self.BGLeg.Pos + Vector(2 * self.FlipFactor, -self.kneedist * 2)
						local getang = SceneMan:ShortestDistance(self.Pos, usepos, true).AbsRadAngle
						self:AddAbsForce(
							Vector(addforce, addforcey):RadRotate(getang),
							self.Pos + Vector(2 * self.FlipFactor, -10)
						)
						self.BGLeg:AddAbsForce(Vector(addforce, -addforcey * 0.5):RadRotate(getang), self.BGLeg.Pos)
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13);
						self.bglegpushed = self.bglegpushed + 1
					end
				end
			end
			--BACK LEG PUSH
			if
				self.FGLeg
				and self.FGFoot
				and self.FGFoot.Pos.X > self.Pos.X + 1
				and self.FGLeg.RotAngle < math.pi + self.triggerangBG
			then
				if self.fglegpushed > 0 then
					local groundray = SceneMan:CastStrengthRay(
						self.FGFoot.Pos,
						Vector(3 * self.FlipFactor, self.footheight):RadRotate(self.FGFoot.RotAngle),
						0,
						terrcheck,
						1,
						0,
						true
					)
					if groundray == true then
						local xchange = SceneMan:ShortestDistance(
							Vector(self.FGFootPrevPos, 0),
							Vector(self.FGFoot.Pos.X - self.Pos.X, 0),
							true
						).Magnitude
						local usemass = (self.FGLeg.Mass + self.FGFoot.Mass)
						local addforce = self.pscale * xchange * usemass
						--local addforcey = -1*self.pscale*usemass*self.FlipFactor
						local usepos = self.FGLeg.Pos --+Vector(2*self.FlipFactor,self.footheight):RadRotate(self.FGLeg.RotAngle)
						local getang = SceneMan:ShortestDistance(usepos, self.Pos, true).AbsRadAngle
						self:AddAbsForce(Vector(addforce, 0):RadRotate(getang), self.Pos)
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5);
						self.fglegpushed = self.fglegpushed - 1
					end
				end
			end
			if
				self.BGLeg
				and self.BGFoot
				and self.BGFoot.Pos.X > self.Pos.X + 1
				and self.BGLeg.RotAngle < math.pi + self.triggerangBG
			then
				if self.bglegpushed > 0 then
					local groundray = SceneMan:CastStrengthRay(
						self.BGFoot.Pos,
						Vector(3 * self.FlipFactor, self.footheight):RadRotate(self.BGFoot.RotAngle),
						0,
						terrcheck,
						1,
						0,
						true
					)
					if groundray == true then
						local xchange = SceneMan:ShortestDistance(
							Vector(self.BGFootPrevPos, 0),
							Vector(self.BGFoot.Pos.X - self.Pos.X, 0),
							true
						).Magnitude
						local usemass = (self.BGLeg.Mass + self.BGFoot.Mass)
						local addforce = self.pscale * xchange * usemass
						--local addforcey = -1*self.pscale*usemass*self.FlipFactor
						local usepos = self.BGLeg.Pos --+Vector(2*self.FlipFactor,self.footheight):RadRotate(self.BGLeg.RotAngle)
						local getang = SceneMan:ShortestDistance(usepos, self.Pos, true).AbsRadAngle
						self:AddAbsForce(Vector(addforce, 0):RadRotate(getang), self.Pos)
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5);
						self.bglegpushed = self.bglegpushed - 1
					end
				end
			end
		end
	end

	--STORE CURRENT LEG POSITIONS TO USE AS FORCE CHECKS NEXT TIME
	if self.FGFoot then
		self.FGFootPrevPos = self.FGFoot.Pos.X - self.Pos.X
	end
	if self.BGFoot then
		self.BGFootPrevPos = self.BGFoot.Pos.X - self.Pos.X
	end
	--PrimitiveMan:DrawCircleFillPrimitive(self.Pos+Vector(2*self.FlipFactor,-10):RadRotate(self.RotAngle), 2, 147);
	if self:IsPlayerControlled() == true then
		if self.enableselect == true then
			self.selected = CreateAEmitter("Tau Broadside Select")
			self.selected.Pos = self.Pos
			self.selected.PinStrength = 1000
			MovableMan:AddParticle(self.selected)
			self.enableselect = false
		end
	else
		self.enableselect = true
	end

	for i = 1, #self.Turret do
		if MovableMan:IsActor(self.Turret[i]) == true and self.Turret[1].Team == self.Team then
			self.Turret[i].Vel.X = 0
			self.Turret[i].Vel.Y = 0
			self.Turret[i].RotAngle = self.RotAngle
			self.Turret[i].Pos = self.Pos + self:RotateOffset(self.Turret[i].Offset)
			self.Turret[i].HFlipped = self.HFlipped
			self.Turret[i].PinStrength = 1000
		end
	end

	if self.Health <= 0 then
		local rotangle = self.RotAngle

		if rotangle > 0.15 then
			self.RotAngle = 0.15
		elseif rotangle < -0.15 then
			self.RotAngle = -0.15
		end

		self:ClearForces()
		self.AngularVel = self.AngularVel * 0.97

		self.alt = self:GetAltitude(0, 1)
		if self.alt < 18 then
			local decompress = CreateAEmitter("Bolter Casing", "spacemarines.rte")
			decompress.Pos = self.Pos
			decompress.Vel = self.Vel

			if self.HFlipped == false then
				decompress.RotAngle = self.RotAngle - 0.35
			else
				decompress.RotAngle = self.RotAngle + math.pi + 0.35
			end

			decompress:SetWhichMOToNotHit(self, -1)
			MovableMan:AddParticle(decompress)
		end

		self.Flight = false
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	if MovableMan:IsActor(self) == true then
		self.AngularVel = 0
		local decompress = CreateAEmitter("Bolter Casing", "spacemarines.rte")
		decompress.Pos = self.Pos
		decompress.Vel = self.Vel

		if self.HFlipped == false then
			decompress.RotAngle = self.RotAngle - 0.35
		else
			decompress.RotAngle = self.RotAngle + math.pi + 0.35
		end

		decompress:SetWhichMOToNotHit(self, -1)
		MovableMan:AddParticle(decompress)
	end

	for i = 1, #self.Turret do
		if MovableMan:IsParticle(self.Turret[i]) == true then
			if self.Health < 1 then
				self.Turret[i]:GibThis()
			else
				self.Turret[i].ToDelete = true
			end
		end
	end
end
