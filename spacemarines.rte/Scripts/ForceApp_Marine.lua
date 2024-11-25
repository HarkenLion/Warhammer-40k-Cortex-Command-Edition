dofile("Base.rte/Constants.lua")

function Create(self)
	self.c = self:GetController()

	self.triggerang = math.pi / 4 --4 --4
	self.triggerangBG = math.pi / 4 --4
	self.musclemult = 2.25 --1.75 --1 --0.5 --1
	self.pscale = GetPPM() * self.musclemult
	self.FGFootPrevPos = self.FGFoot.Pos.X - self.Pos.X
	self.BGFootPrevPos = self.BGFoot.Pos.X - self.Pos.X
	self.kneedist = 8 --5 --12 --2
	self.footheight = 4 --6 --4

	self.fglegpushed = 0
	self.bglegpushed = 0
end

function ThreadedUpdate(self)
	local controller = self.c
	if controller:IsState(5) then
		self.footheight = 0
	else
		self.footheight = 6
	end

	if controller:IsState(3) and not controller:IsState(5) then
		local terrcheck = Vector(0, 0)
		local fgleg = self.FGLeg
		local bgleg = self.BGLeg
		local fgfoot = self.FGFoot
		local bgfoot = self.BGFoot
		--MOVING RIGHT
		if self.FlipFactor == 1 then
			--FORWARD LEG PULL
			if fgleg and fgfoot and self.FGLeg.RotAngle < self.triggerang then
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
						local addforcey = -2* self.pscale * usemass * self.FlipFactor
						local usepos = self.FGLeg.Pos + Vector(2 * self.FlipFactor, -self.kneedist * 2) --:RadRotate(self.FGLeg.RotAngle)
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
			if bgleg and bgfoot and self.BGLeg.RotAngle < self.triggerang then
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
						local addforcey = -2* self.pscale * usemass * self.FlipFactor
						local usepos = self.BGLeg.Pos + Vector(2 * self.FlipFactor, -self.kneedist * 2) --:RadRotate(self.BGLeg.RotAngle)
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
			if fgleg and fgfoot and self.FGLeg.RotAngle > self.triggerangBG then
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
			if bgleg and bgfoot and self.BGLeg.RotAngle > self.triggerangBG then
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
	elseif controller:IsState(4) and not controller:IsState(5) then
		local terrcheck = Vector(0, 0)
		local fgleg = self.FGLeg
		local bgleg = self.BGLeg
		local fgfoot = self.FGFoot
		local bgfoot = self.BGFoot

		--MOVING LEFT
		if self.FlipFactor == -1 then
			--FRONT LEG PULL
			if fgleg
				and fgfoot
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
						local addforcey = -2* self.pscale * usemass * self.FlipFactor
						local usepos = self.FGLeg.Pos + Vector(2 * self.FlipFactor, -self.kneedist * 2) --:RadRotate(self.FGLeg.RotAngle)
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
			if bgleg
				and bgfoot
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
						local addforcey = -2* self.pscale * usemass * self.FlipFactor
						local usepos = self.BGLeg.Pos + Vector(2 * self.FlipFactor, -self.kneedist * 2) --:RadRotate(self.BGLeg.RotAngle)
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
			if fgleg
				and fgfoot
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
			if bgleg
				and bgfoot
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

	local fgfoot = self.FGFoot
	local bgfoot = self.BGFoot

	--STORE CURRENT LEG POSITIONS TO USE AS FORCE CHECKS NEXT TIME
	if fgfoot then
		self.FGFootPrevPos = self.FGFoot.Pos.X - self.Pos.X
	end
	if bgfoot then
		self.BGFootPrevPos = self.BGFoot.Pos.X - self.Pos.X
	end
	--PrimitiveMan:DrawCircleFillPrimitive(self.Pos+Vector(2*self.FlipFactor,-10):RadRotate(self.RotAngle), 2, 147);
end
