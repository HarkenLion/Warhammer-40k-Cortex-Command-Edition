dofile("Base.rte/Constants.lua")
dofile("necrons.rte/Scripts/AI/NativeNecronAI.lua")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
end

function Update(self)
	local rotangle = self.RotAngle
	if rotangle < -0.15 then
		self.RotAngle = -0.15
	elseif rotangle > 0.15 then
		self.RotAngle = 0.15
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
