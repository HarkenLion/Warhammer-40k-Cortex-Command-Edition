function Create(self)
	self.GasTimer = Timer()
	self.GasInterval = 100
end

function Update(self)
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
				and not string.find(actor.PresetName, "Brain")
				and not string.find(actor.PresetName, "Drone")
				and not string.find(actor.PresetName, "Actors - Turret")
				and not string.find(actor.PresetName, "Mech")
				and not string.find(actor.PresetName, "Dummy")
				and not string.find(actor.PresetName, "Dreadnought")
				and not string.find(actor.PresetName, "Whitebot")
				and not string.find(actor.PresetName, "Patchbot")
				and actor.PresetName ~= "Techion Silver Man"
				and actor.PresetName ~= "Browncoat Light"
				and actor.PresetName ~= "Blast Runner"
				and actor.PresetName ~= "Specialist"
				and actor.PresetName ~= "Behemoth"
				and actor.ClassName ~= "ACDropShip"
				and actor.ClassName ~= "ACRocket"
				and actor.ClassName ~= "ADoor"
			then
				if SceneMan:ShortestDistance(self.Pos, actor.Pos, SceneMan.SceneWrapsX).Magnitude < 60 then
					if TableCheck(self, actor) ~= true then
						if actor.Health > 0 then
							--actor:FlashWhite(150); --Uncomment to make them turn white as well
							actor.Health = actor.Health - (40 / actor.Mass + 0.3) / 2
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
