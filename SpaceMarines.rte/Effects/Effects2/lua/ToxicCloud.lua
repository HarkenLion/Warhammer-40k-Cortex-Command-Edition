function Create(self)
	self.startLife = self.Lifetime
	self.lifeTimer = Timer()
	self.smokeCount = 3
	self.prob = 0.30

	self.GasTimer = Timer()
	self.GasInterval = 100 + math.random(100)
end

function Update(self)
	if self.lifeTimer:IsPastSimMS(self.startLife * 0.94) then
		self.prob = 0.05
	elseif self.lifeTimer:IsPastSimMS(self.startLife * 0.88) then
		self.smokeCount = 1
		self.prob = 0.10
	elseif self.lifeTimer:IsPastSimMS(self.startLife * 0.82) then
		self.prob = 0.15
	elseif self.lifeTimer:IsPastSimMS(self.startLife * 0.76) then
		self.smokeCount = 2
		self.prob = 0.20
	elseif self.lifeTimer:IsPastSimMS(self.startLife * 0.70) then
		self.prob = 0.25
	end

	if math.random() <= self.prob then
		local smoke = CreateMOSParticle("Untitled.rte.rte/Toxic Gas Ball " .. math.random(self.smokeCount))
		smoke.Pos = self.Pos + Vector(math.random(self.Sharpness * 10), 0):RadRotate(2 * math.pi * math.random())
		smoke.Vel = Vector(math.random(3), 0):RadRotate(2 * math.pi * math.random())
		MovableMan:AddParticle(smoke)
	end

	if self.GasTimer:IsPastSimMS(self.GasInterval) then
		self.Masked = {}
		local mask = {}
		local masked = {}
		for i = 1, MovableMan:GetMOIDCount() - 1 do
			mask[#mask + 1] = MovableMan:GetMOFromID(i)
		end
		for i = 1, #mask do
			if string.find(mask[i].PresetName, "Mask") and mask[i].ClassName == "Attachable" then
				--mask[i].ToDelete = true; --Uncomment to demask masked troops
				masked[i] = MovableMan:GetMOFromID(mask[i].RootID)
				if MovableMan:IsActor(masked[i]) and masked[i].ClassName == "AHuman" then
					self.Masked[#self.Masked + 1] = ToAHuman(masked[i])
				end
			end
		end
		for actor in MovableMan.Actors do
			if
				not string.find(actor.PresetName, "Robot")
				and not string.find(actor.PresetName, "Drone")
				and not string.find(actor.PresetName, "Actors - Turret")
				and not string.find(actor.PresetName, "Mech")
				and not string.find(actor.PresetName, "Dummy")
				and not string.find(actor.PresetName, "Dreadnought")
				and not string.find(actor.PresetName, "Whitebot")
				and not string.find(actor.PresetName, "Patchbot")
				and not string.find(actor.PresetName, "UA-")
				and actor.PresetName ~= "Techion Silver Man"
				and actor.PresetName ~= "Blast Runner"
				and actor.ClassName ~= "ACDropShip"
				and actor.ClassName ~= "ACRocket"
				and actor.ClassName ~= "ADoor"
				and not string.find(actor.PresetName, "Browncoat")
				and not string.find(actor.PresetName, "Specialist")
				and not string.find(actor.PresetName, "Federal Privateer")
			then
				if SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX).Magnitude < 60 then
					if TableCheck(self, actor) ~= true then
						if actor.Health > 0 then
							--actor:FlashWhite(150); --Uncomment to make them turn white as well
							actor.Health = actor.Health - (100 / ((actor.Mass ^ 2) / 30) + 0.0075)
						end
					end
				end
			end
		end
		self.GasTimer:Reset()
	end
end
function TableCheck(self, actor)
	for i = 1, #self.Masked do
		if actor.ID == self.Masked[i].ID then
			return true
		end
	end
end
