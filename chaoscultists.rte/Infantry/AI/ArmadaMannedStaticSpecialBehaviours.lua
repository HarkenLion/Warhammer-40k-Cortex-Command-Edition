ArmadaMannedStaticSpecialBehaviours = {}

function ArmadaMannedStaticSpecialBehaviours.manTheGuns(self)
	if self.gotGunner == false then
		local gunner = CreateAHuman("Traitor Guardsman", "chaoscultists.rte")
		gunner.Pos = self.Pos
		gunner.Team = self.Team
		gunner.Vel = self.Vel
		gunner.AIMode = Actor.AIMODE_SENTRY
		gunner:AddScript("Base.rte/Scripts/Shared/NoCasualty.lua")

		local sidearm = RandomHDFirearm("Weapons - Secondary", "chaoscultists.rte")
		local mainarm = nil
		if math.random() < 0.35 then
			mainarm = RandomHDFirearm("Weapons - Light", "chaoscultists.rte")
		end

		gunner:AddInventoryItem(sidearm)
		if mainarm then
			gunner:AddInventoryItem(mainarm)
		end

		MovableMan:AddActor(gunner)

		self.gotGunner = true
	end

	if self.crewSpawnTimer:IsPastSimMS(self.crewReloaderDelay) then
		if self.crewSize > 1 and math.random() <= self.reloaderChance then
			if self.gotReloader == false then
				local reloader = CreateAHuman("Traitor Guardsman", "chaoscultists.rte")
				reloader.Pos = self.Pos
				reloader.Team = self.Team
				reloader.Vel = self.Vel
				reloader.AIMode = Actor.AIMODE_SENTRY
				reloader:AddScript("Base.rte/Scripts/Shared/NoCasualty.lua")

				local sidearm = RandomHDFirearm("Weapons - Secondary", "chaoscultists.rte")
				local mainarm = nil
				if math.random() < 0.35 then
					mainarm = RandomHDFirearm("Weapons - Light", "chaoscultists.rte")
				end

				reloader:AddInventoryItem(sidearm)
				if mainarm then
					reloader:AddInventoryItem(mainarm)
				end

				MovableMan:AddActor(reloader)

				self.gotReloader = true
			end
		else
			self.gotReloader = true
		end
	end

	if self.crewSpawnTimer:IsPastSimMS(self.crewSpotterDelay) then
		if self.crewSize > 2 and math.random() <= self.spotterChance then
			if self.gotSpotter == false then
				local spotter = CreateAHuman("Traitor Guard Heavy Gunner", "chaoscultists.rte")
				spotter.Pos = self.Pos
				spotter.Team = self.Team
				spotter.Vel = self.Vel
				spotter.AIMode = Actor.AIMODE_SENTRY
				spotter:AddScript("Base.rte/Scripts/Shared/NoCasualty.lua")

				local sidearm = RandomHDFirearm("Weapons - Secondary", "chaoscultists.rte")
				local mainarm = nil
				if math.random() < 0.35 then
					mainarm = RandomHDFirearm("Weapons - Light", "chaoscultists.rte")
				end

				spotter:AddInventoryItem(sidearm)
				if mainarm then
					spotter:AddInventoryItem(mainarm)
				end

				MovableMan:AddActor(spotter)

				self.gotSpotter = true
			end
		else
			self.gotSpotter = true
		end
	end
end
