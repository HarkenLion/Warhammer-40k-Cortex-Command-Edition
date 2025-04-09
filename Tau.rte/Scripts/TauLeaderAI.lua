dofile("Base.rte/Constants.lua")
dofile("Tau.rte/Scripts/AI/NativeTauAI.lua")

function Create(self)
	self.enableselect = true
	self.AI = NativeHumanAI:Create(self)
end

function Update(self)
	if self:IsPlayerControlled() == true then
		if self.enableselect == true then
			self.selected = CreateAEmitter("Tau Leader Select")
			self.selected.Pos = self.Pos
			self.selected.PinStrength = 1000
			MovableMan:AddParticle(self.selected)
			self.enableselect = false
		end
	else
		self.enableselect = true
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	if MovableMan:IsActor(self) == true then
		self.AngularVel = 0
	end
end
