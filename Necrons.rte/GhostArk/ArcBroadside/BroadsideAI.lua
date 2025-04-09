dofile("Base.rte/Constants.lua")
require("AI/NativeCrabAI") --dofile("Base.rte/AI/NativeCrabAI.lua")

function Create(self)
	self.enableselect = true
	self.selectTimer = Timer()
	self.AI = NativeCrabAI:Create(self)
end

function Update(self)
	if self:IsPlayerControlled() == true then
		if self.enableselect == true then
			self.selectTimer:Reset()
			self.enableselect = false
		end
	else
		self.enableselect = true
	end

	if not self.selectTimer:IsPastSimMS(1200) then
		if not self.selectTimer:IsPastSimMS(600) then
			self.selected = CreateMOPixel("Ghost Ark Broadside Diagram 2")
			self.selected.Pos = self.Pos
			self.selected.PinStrength = 1000
			MovableMan:AddParticle(self.selected)
		else
			self.selected = CreateMOPixel("Ghost Ark Broadside Diagram")
			self.selected.Pos = self.Pos
			self.selected.PinStrength = 1000
			MovableMan:AddParticle(self.selected)
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
