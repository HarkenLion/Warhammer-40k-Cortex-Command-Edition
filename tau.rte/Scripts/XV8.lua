dofile("Base.rte/Constants.lua")
dofile("Tau.rte/Scripts/AI/NativeTauAI.lua")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.enableselect = true

	self.c = self:GetController()
	self.triggerang = math.pi / 3 --4
	self.musclemult = 0.5 -- --1.25 --2.5 --1.5
	self.pscale = GetPPM() * self.musclemult
	self.FGFootPrevPos = self.FGFoot.Pos.X - self.Pos.X
	self.BGFootPrevPos = self.BGFoot.Pos.X - self.Pos.X
	self.kneedist = 12

	self.fglegpushed = false
	self.bglegpushed = false
end

function ThreadedUpdate(self)
	local fgfoot = self.FGFoot
	local bgfoot = self.BGFoot

	if self.c:IsState(3) and not self.c:IsState(5)  then
		local terrcheck = Vector(0, 0)
		local fgleg = self.FGLeg
		local bgleg = self.BGLeg
		--MOVING RIGHT
		if self.FlipFactor == 1 then
			--FORWARD LEG PULL
			if
				fgleg
				and fgfoot
				and self.FGFoot.Pos.X > self.Pos.X
				and self.FGLeg.RotAngle < self.triggerang
			then
				local groundray = SceneMan:CastStrengthRay(
					self.FGFoot.Pos,
					Vector(3 * self.FlipFactor, 21):RadRotate(self.FGFoot.RotAngle),
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
					--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13);
				end
			end
			if
				bgleg
				and bgfoot
				and self.BGFoot.Pos.X > self.Pos.X
				and self.BGLeg.RotAngle < self.triggerang
			then
				local groundray = SceneMan:CastStrengthRay(
					self.BGFoot.Pos,
					Vector(3 * self.FlipFactor, 21):RadRotate(self.BGFoot.RotAngle),
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
					--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13);
				end
			end
			--BACK LEG PUSH
			if fgleg and fgfoot and self.FGFoot.Pos.X < self.Pos.X - 1 then
				if self.fglegpushed == false then
					local groundray = SceneMan:CastStrengthRay(
						self.FGFoot.Pos,
						Vector(3 * self.FlipFactor, 21):RadRotate(self.FGFoot.RotAngle),
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
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5);
						self.fglegpushed = true
					end
				end
			else
				self.fglegpushed = false
			end
			if bgleg and bgfoot and self.BGFoot.Pos.X < self.Pos.X - 1 then
				if self.bglegpushed == false then
					local groundray = SceneMan:CastStrengthRay(
						self.BGFoot.Pos,
						Vector(3 * self.FlipFactor, 21):RadRotate(self.BGFoot.RotAngle),
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
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5);
						self.bglegpushed = true
					end
				end
			else
				self.bglegpushed = false
			end
		end
	elseif self.c:IsState(4) and not self.c:IsState(5)  then
		local terrcheck = Vector(0, 0)
		local fgleg = self.FGLeg
		local bgleg = self.BGLeg
		--MOVING LEFT
		if self.FlipFactor == -1 then
			--FRONT LEG PULL
			if
				fgleg
				and fgfoot
				and self.FGFoot.Pos.X < self.Pos.X
				and self.FGLeg.RotAngle > self.triggerang
			then
				local groundray = SceneMan:CastStrengthRay(
					self.FGFoot.Pos,
					Vector(3 * self.FlipFactor, 21):RadRotate(self.FGFoot.RotAngle),
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
					--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13);
				end
			end
			if
				bgleg
				and bgfoot
				and self.BGFoot.Pos.X < self.Pos.X
				and self.BGLeg.RotAngle > self.triggerang
			then
				local groundray = SceneMan:CastStrengthRay(
					self.BGFoot.Pos,
					Vector(3 * self.FlipFactor, 21):RadRotate(self.BGFoot.RotAngle),
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
					--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 13);
				end
			end
			--BACK LEG PUSH
			if fgleg and fgfoot and self.FGFoot.Pos.X > self.Pos.X + 1 then
				if self.fglegpushed == false then
					local groundray = SceneMan:CastStrengthRay(
						self.FGFoot.Pos,
						Vector(3 * self.FlipFactor, 21):RadRotate(self.FGFoot.RotAngle),
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
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5);
						self.fglegpushed = true
					end
				end
			else
				self.fglegpushed = false
			end
			if bgleg and bgfoot and self.BGFoot.Pos.X > self.Pos.X + 1 then
				if self.bglegpushed == false then
					local groundray = SceneMan:CastStrengthRay(
						self.BGFoot.Pos,
						Vector(3 * self.FlipFactor, 21):RadRotate(self.BGFoot.RotAngle),
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
						--PrimitiveMan:DrawCircleFillPrimitive(usepos, 2, 5);
						self.bglegpushed = true
					end
				end
			else
				self.bglegpushed = false
			end
		end
	end


	--STORE CURRENT LEG POSITIONS TO USE AS FORCE CHECKS NEXT TIME
	if fgfoot then 
		self.FGFootPrevPos = self.FGFoot.Pos.X - self.Pos.X 
	end
	if bgfoot then
		self.BGFootPrevPos = self.BGFoot.Pos.X - self.Pos.X
	end
	--PrimitiveMan:DrawCircleFillPrimitive(self.Pos+Vector(2*self.FlipFactor,-10):RadRotate(self.RotAngle), 2, 147);

	if not (self:IsDead()) and self.Health > 0 then
		if self:IsPlayerControlled() == true then
			if self.enableselect == true then
				self.selected = CreateAEmitter("Tau Crisis Select")
				self.selected.Pos = self.Pos
				self.selected.PinStrength = 1000
				MovableMan:AddParticle(self.selected)
				self.enableselect = false
			end
		else
			self.enableselect = true
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	if MovableMan:IsActor(self) == true then
		self.AngularVel = 0
		local decompress = CreateAEmitter("Battlesuit Splatter", "Tau.rte")
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
end
