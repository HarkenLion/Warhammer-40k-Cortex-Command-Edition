dofile("Base.rte/Constants.lua")
dofile("tau.rte/Scripts/AI/NativeTauAI.lua")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	if MovableMan:IsActor(self) == true then
		self.AngularVel = 0
	end
end
