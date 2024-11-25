dofile("Base.rte/Constants.lua")
dofile("necrons.rte/Scripts/AI/NativeNecronAI.lua")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
end

function UpdateAI(self)
	self.AI:Update(self)
end
