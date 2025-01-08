dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
end

function UpdateAI(self)
	self.AI:Update(self)
end
