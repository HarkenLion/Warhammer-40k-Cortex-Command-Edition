dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI") --dofile("Base.rte/AI/NativeHumanAI.lua")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.revived = 0
	self.saveteam = self.Team
	self.revivetime = math.random(1875, 2750)

	self.piecename = "Death Korps Coat Back"
	for attachable in self.Attachables do
		if attachable.PresetName == self.piecename then
			self.CoatBackMain = attachable
			break
		end
	end

	self.piecename = "Death Korps Coat Back FGLeg"
	for attachable in self.Attachables do
		if attachable.PresetName == self.piecename then
			self.CoatBackFG = attachable
			break
		end
	end

	self.piecename = "Death Korps Coat Back BGLeg"
	for attachable in self.Attachables do
		if attachable.PresetName == self.piecename then
			self.CoatBackBG = attachable
			break
		end
	end
end

function Update(self)
	local fgleg = self.FGLeg
	local bgleg = self.BGLeg


	if fgleg and self.CoatBackFG then
		self.CoatBackFG.RotAngle = self.FGLeg.RotAngle
		self.CoatBackFG.Frame = self.FGLeg.Frame
	end
	if bgleg and self.CoatBackBG then
		self.CoatBackBG.RotAngle = self.BGLeg.RotAngle
		self.CoatBackBG.Frame = self.BGLeg.Frame
	end
	if bgleg and fgleg and self.CoatBackMain then
		local avRot = (self.BGLeg.RotAngle + self.FGLeg.RotAngle) * 0.5
		self.CoatBackMain.RotAngle = avRot
	end
end

function ThreadedUpdate(self)
	local fgarm = self.FGarm
	local bgarm = self.BGarm
	--TRANSHUMAN PHYSIOLOGY
	if self.Health <= 0 and self.revived == 0 and self.Head and (fgarm or bgarm) then
		if self:NumberValueExists("SecondWinds") and self:GetNumberValue("SecondWinds") > 0 then
			self:SetNumberValue("SecondWinds", 0)
			self.revived = 1
			self.reviveTimer = Timer()
		end
	end

	if self.revived == 1 then
		self.Status = Actor.UNSTABLE
		self.ToSettle = false
		self.HUDVisible = false
		self.DeathSound:Stop()

		if self.reviveTimer:IsPastSimMS(self.revivetime) then
			self.revived = 2
			local clone = self:Clone()
			clone.Health = math.random(30, 60)
			clone.IsDead = false
			clone.Team = self.saveteam
			clone.Status = Actor.STABLE
			clone.AI_Mode = AI_MODE_SENTRY

			if clone:NumberValueExists("SecondWinds") then
				clone:SetNumberValue("SecondWinds", 0)
			end

			clone.HUDVisible = true
			MovableMan:AddActor(clone)

			self.ToDelete = true
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
