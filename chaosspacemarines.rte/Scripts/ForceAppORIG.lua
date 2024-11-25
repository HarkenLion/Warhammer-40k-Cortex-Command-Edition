dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI") --dofile("Base.rte/AI/NativeHumanAI.lua")

function Create(self)
	self.c = self:GetController()
	self.AI = NativeHumanAI:Create(self)

	self.triggerang = math.pi / 3 --4
	self.musclemult = 0.5 -- --1.25 --2.5 --1.5
	self.pscale = GetPPM() * self.musclemult
	self.FGFootPrevPos = self.FGFoot.Pos.X - self.Pos.X
	self.BGFootPrevPos = self.BGFoot.Pos.X - self.Pos.X
	self.kneedist = 12

	self.fglegpushed = false
	self.bglegpushed = false
end

function Update(self)
	if self.c:IsState(3) then
		local terrcheck = Vector(0, 0)
		--MOVING RIGHT
		if self.FlipFactor == 1 then
			--FORWARD LEG PULL
			if
				MovableMan:ValidMO(self.FGLeg)
				and self.FGFoot.Pos.X > self.Pos.X
				and self.FGLeg.RotAngle < self.triggerang
			then
				local groundray = SceneMan:CastStrengthRay(
					self.FGFoot.Pos,
					Vector(3 * self.FlipFactor, 4):RadRotate(self.FGFoot.RotAngle),
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
					local usepos = self.FGLeg.Pos
						+ Vector(2 * self.FlipFactor, -self.kneedist):RadRotate(self.FGLeg.RotAngle)
					local getang = SceneMan:ShortestDistance(self.Pos, usepos, true).AbsRadAngle
					self:AddAbsForce(
						Vector(addforce, addforcey):RadRotate(getang),
						self.Pos + Vector(2 * self.FlipFactor, -10):RadRotate(self.RotAngle)
					)
					self.FGLeg:AddAbsForce(Vector(addforce, -addforcey * 0.5):RadRotate(getang), self.FGLeg.Pos)
					PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13)
				end
			end
			if
				MovableMan:ValidMO(self.BGLeg)
				and self.BGFoot.Pos.X > self.Pos.X
				and self.BGLeg.RotAngle < self.triggerang
			then
				local groundray = SceneMan:CastStrengthRay(
					self.BGFoot.Pos,
					Vector(3 * self.FlipFactor, 4):RadRotate(self.BGFoot.RotAngle),
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
					local usepos = self.BGLeg.Pos
						+ Vector(2 * self.FlipFactor, -self.kneedist):RadRotate(self.BGLeg.RotAngle)
					local getang = SceneMan:ShortestDistance(self.Pos, usepos, true).AbsRadAngle
					self:AddAbsForce(
						Vector(addforce, addforcey):RadRotate(getang),
						self.Pos + Vector(2 * self.FlipFactor, -10):RadRotate(self.RotAngle)
					)
					self.BGLeg:AddAbsForce(Vector(addforce, -addforcey * 0.5):RadRotate(getang), self.BGLeg.Pos)
					PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13)
				end
			end
			--BACK LEG PUSH
			if MovableMan:ValidMO(self.FGLeg) and self.FGFoot.Pos.X < self.Pos.X - 1 then
				local groundray = SceneMan:CastStrengthRay(
					self.FGFoot.Pos,
					Vector(3 * self.FlipFactor, 4):RadRotate(self.FGFoot.RotAngle),
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
					local usemass = (self.FGLeg.Mass + self.FGFoot.Mass + self.Mass * 0.5)
					local addforce = self.pscale * xchange * usemass
					--local addforcey = -1*self.pscale*usemass*self.FlipFactor
					local usepos = self.FGLeg.Pos --+Vector(2*self.FlipFactor,4):RadRotate(self.FGLeg.RotAngle)
					local getang = SceneMan:ShortestDistance(usepos, self.Pos, true).AbsRadAngle
					self:AddAbsForce(Vector(addforce, 0):RadRotate(getang), self.Pos)
					PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5)
				end
			end
			if MovableMan:ValidMO(self.BGLeg) and self.BGFoot.Pos.X < self.Pos.X - 1 then
				local groundray = SceneMan:CastStrengthRay(
					self.BGFoot.Pos,
					Vector(3 * self.FlipFactor, 4):RadRotate(self.BGFoot.RotAngle),
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
					local usemass = (self.BGLeg.Mass + self.BGFoot.Mass + self.Mass * 0.5)
					local addforce = self.pscale * xchange * usemass
					--local addforcey = -1*self.pscale*usemass*self.FlipFactor
					local usepos = self.BGLeg.Pos --+Vector(2*self.FlipFactor,4):RadRotate(self.BGLeg.RotAngle)
					local getang = SceneMan:ShortestDistance(usepos, self.Pos, true).AbsRadAngle
					self:AddAbsForce(Vector(addforce, 0):RadRotate(getang), self.Pos)
					PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5)
				end
			end
		end
	elseif self.c:IsState(4) then
		local terrcheck = Vector(0, 0)
		--MOVING LEFT
		if self.FlipFactor == -1 then
			--FRONT LEG PULL
			if
				MovableMan:ValidMO(self.FGLeg)
				and self.FGFoot.Pos.X < self.Pos.X
				and self.FGLeg.RotAngle > self.triggerang
			then
				local groundray = SceneMan:CastStrengthRay(
					self.FGFoot.Pos,
					Vector(3 * self.FlipFactor, 4):RadRotate(self.FGFoot.RotAngle),
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
					local usepos = self.FGLeg.Pos
						+ Vector(2 * self.FlipFactor, -self.kneedist):RadRotate(self.FGLeg.RotAngle)
					local getang = SceneMan:ShortestDistance(self.Pos, usepos, true).AbsRadAngle
					self:AddAbsForce(
						Vector(addforce, addforcey):RadRotate(getang),
						self.Pos + Vector(2 * self.FlipFactor, -10):RadRotate(self.RotAngle)
					)
					self.FGLeg:AddAbsForce(Vector(addforce, -addforcey * 0.5):RadRotate(getang), self.FGLeg.Pos)
					PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13)
				end
			end
			if
				MovableMan:ValidMO(self.BGLeg)
				and self.BGFoot.Pos.X < self.Pos.X
				and self.BGLeg.RotAngle > self.triggerang
			then
				local groundray = SceneMan:CastStrengthRay(
					self.BGFoot.Pos,
					Vector(3 * self.FlipFactor, 4):RadRotate(self.BGFoot.RotAngle),
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
					local usepos = self.BGLeg.Pos
						+ Vector(2 * self.FlipFactor, -self.kneedist):RadRotate(self.BGLeg.RotAngle)
					local getang = SceneMan:ShortestDistance(self.Pos, usepos, true).AbsRadAngle
					self:AddAbsForce(
						Vector(addforce, addforcey):RadRotate(getang),
						self.Pos + Vector(2 * self.FlipFactor, -10):RadRotate(self.RotAngle)
					)
					self.BGLeg:AddAbsForce(Vector(addforce, -addforcey * 0.5):RadRotate(getang), self.BGLeg.Pos)
					PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13)
				end
			end
			--BACK LEG PUSH
			if MovableMan:ValidMO(self.FGLeg) and self.FGFoot.Pos.X > self.Pos.X + 1 then
				local groundray = SceneMan:CastStrengthRay(
					self.FGFoot.Pos,
					Vector(3 * self.FlipFactor, 4):RadRotate(self.FGFoot.RotAngle),
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
					local usemass = (self.FGLeg.Mass + self.FGFoot.Mass + self.Mass * 0.5)
					local addforce = self.pscale * xchange * usemass
					--local addforcey = -1*self.pscale*usemass*self.FlipFactor
					local usepos = self.FGLeg.Pos --+Vector(2*self.FlipFactor,4):RadRotate(self.FGLeg.RotAngle)
					local getang = SceneMan:ShortestDistance(usepos, self.Pos, true).AbsRadAngle
					self:AddAbsForce(Vector(addforce, 0):RadRotate(getang), self.Pos)
					PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5)
				end
			end
			if MovableMan:ValidMO(self.BGLeg) and self.BGFoot.Pos.X > self.Pos.X + 1 then
				local groundray = SceneMan:CastStrengthRay(
					self.BGFoot.Pos,
					Vector(3 * self.FlipFactor, 4):RadRotate(self.BGFoot.RotAngle),
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
					local usemass = (self.BGLeg.Mass + self.BGFoot.Mass + self.Mass * 0.5)
					local addforce = self.pscale * xchange * usemass
					--local addforcey = -1*self.pscale*usemass*self.FlipFactor
					local usepos = self.BGLeg.Pos --+Vector(2*self.FlipFactor,4):RadRotate(self.BGLeg.RotAngle)
					local getang = SceneMan:ShortestDistance(usepos, self.Pos, true).AbsRadAngle
					self:AddAbsForce(Vector(addforce, 0):RadRotate(getang), self.Pos)
					PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5)
				end
			end
		end
	end

	--STORE CURRENT LEG POSITIONS TO USE AS FORCE CHECKS NEXT TIME
	self.FGFootPrevPos = self.FGFoot.Pos.X - self.Pos.X
	self.BGFootPrevPos = self.BGFoot.Pos.X - self.Pos.X
	PrimitiveMan:DrawCircleFillPrimitive(self.Pos + Vector(2 * self.FlipFactor, -10):RadRotate(self.RotAngle), 2, 147)
end

function UpdateAI(self)
	self.AI:Update(self)
end
