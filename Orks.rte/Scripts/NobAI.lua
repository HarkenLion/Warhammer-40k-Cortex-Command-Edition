require("AI/NativeHumanAI")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.WTime = Timer()
end
function Update(self) end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	if MovableMan:IsActor(self) == true then
		self.AngularVel = 0
	end
end
