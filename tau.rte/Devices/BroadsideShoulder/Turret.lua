dofile("Base.rte/Constants.lua")
require("AI/NativeCrabAI") --dofile("Base.rte/Actors/AI/NativeCrabAI.lua")

function Create(self)
	self.AI = NativeCrabAI:Create(self)
end

function Destroy(self)
	ActivityMan:GetActivity():ReportDeath(self.Team, -1)
end

function UpdateAI(self)
	self.AI:Update(self)
end
