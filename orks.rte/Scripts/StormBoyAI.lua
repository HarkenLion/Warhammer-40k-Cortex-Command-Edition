require("AI/NativeHumanAI")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.c = self:GetController()

	local hook = CreateHDFirearm("Choppa")
	local rand = math.random(0, 4)

	if rand == 0 then
		hook = CreateHDFirearm("Mean Choppa")
	elseif rand == 1 then
		hook = CreateHDFirearm("Worn Choppa")
	elseif rand == 2 then
		hook = CreateHDFirearm("Slab Choppa")
	elseif rand == 3 then
		hook = CreateHDFirearm("Taxi Choppa")
	else
		hook = CreateHDFirearm("Choppa")
	end

	self:AddInventoryItem(hook)
end

function Update(self) end

function UpdateAI(self)
	self.AI:Update(self)

	if self.Health < 1 then
		local Payload = CreateMOSRotating("Ork Jet Pack Explosion", "Orks.rte")
		if Payload then
			Payload.Pos = self.Pos
			Payload.Vel = self.Vel
			Payload.RotAngle = self.RotAngle
			Payload.AngularVel = self.AngularVel
			MovableMan:AddParticle(Payload)
		end
	end
end

function Destroy(self)
	if MovableMan:IsActor(self) == true then
		self.AngularVel = 0
	end
end
