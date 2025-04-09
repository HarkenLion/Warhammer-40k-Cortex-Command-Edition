ArmadaSpecialBehaviours = {}

function ArmadaSpecialBehaviours.humanExpressionsSystem(self)
	if self.FGArm == nil or self.BGArm == nil or self.FGLeg == nil or self.BGLeg == nil then
		self.bleeding = true
	else
		self.bleeding = false
	end

	if self.Head then
		if self.blinkingTimer:IsPastSimMS(self.blinkingDelay) then --Le blinking
			if self.hurted == true then
				self.blinkingDelay = (math.random(200, 400) * 10) --Change depending of hurt/firing status
			else
				self.blinkingDelay = (math.random(200, 800) * 10)
			end

			self.blinkingTimer:Reset()
			self.blinkingOpeningTimer:Reset()
			self:SetNumberValue("Blinking", 1)
		else
			if self.blinkingOpeningTimer:IsPastSimMS(self.blinkingOpeningDelay) then
				self:SetNumberValue("Blinking", 0)
			end
		end

		if self.Health < self.preHealth then --Ouchie
			if self.Health < (self.preHealth - 1) then
				self.hurtTimer:Reset()
				self:SetNumberValue("Damaged", 1)
				self.hurtSize = self.preHealth - self.Health
			end

			self.preHealth = self.Health
		else
			if self.hurtTimer:IsPastSimMS(self.hurtDelay + (self.hurtSize * 10)) then
				self:SetNumberValue("Damaged", 0)
			end
		end

		if (self.Health < 50 and self.Health > 0) or self.bleeding == true then --We are hurt!
			self:SetNumberValue("Hurt", 1)
			self.hurted = true
		elseif self.bleeding == false then
			self:SetNumberValue("Hurt", 0)
			self.hurted = false
		end

		if self.Health < 1 then --I am DED
			self:SetNumberValue("Ded", 1)
		else
			self:SetNumberValue("Ded", 0)
		end

		if self.EquippedItem then
			local item = ToHeldDevice(self.EquippedItem)
			if item:IsTool() then
				self.hasDigger = true
			else
				self.hasDigger = false
			end
		else
			self.hasDigger = false
		end

		if self.hasDigger == false then
			if self:GetController():IsState(Controller.WEAPON_FIRE) then --Firing angery face
				self:SetNumberValue("Firing", 1)
				self.firingTimer:Reset()
			end
		end

		if self.firingTimer:IsPastSimMS(self.firingDelay) then
			self:SetNumberValue("Firing", 0)
		end
	end
end

function ArmadaSpecialBehaviours.moraleSystem(self) --Right now only the banner can give morale to whomever wields it. More stuff soon:tm:
	--------------- To add morale giving stuff::
	-- Banner (Active)				2
	-- Flare gun (Active)			2
	-- Offizer (Passive)			1
	-- Offizer Whistle (Active) 	1
	-- Bayonet?/Melee weapon	 	1

	self.morale = self.origMorale
		+ self.officerMorale
		+ self.commanderMorale
		+ self.bannerMorale
		+ self.flareMorale
		+ self.flagMorale
		+ self.airshipMorale
		+ self.gasMorale

	--	self:SetNumberValue("Morale Value",	self.morale)	--Afects guns

	if self.IsPlayer == true and self.HUDVisible == true then
		local ctrl = self:GetController()
		local screen = ctrl.Player

		local moraleIcon = CreateMOSRotating("Armada Morale HUD Icon", "ImporianArmada.rte")
		local moraleIconPos = self.AboveHUDPos + Vector(2, -10) --self.Pos + Vector(2,-77)

		PrimitiveMan:DrawBitmapPrimitive(screen, moraleIconPos, moraleIcon, 3.14, self.morale, true, true)
	end

	if self.morale > 0 then
		if self.morale > 9 then
			self.morale = 9
		end

		--TODO: It might be better to have each morale giver give certain bonuses instead of the current semi-flat progression
		--Exmaple: The banner, being a defensive thing, gives 2 notches on the defense stuff
		if self.morale == 9 then
			self.moraleHasteStage = 3
			self.moraleDefenseStage = 3
			self.moraleRegenStage = 3
		elseif self.morale == 8 then
			self.moraleHasteStage = 3
			self.moraleDefenseStage = 3
			self.moraleRegenStage = 2
		elseif self.morale == 7 then
			self.moraleHasteStage = 3
			self.moraleDefenseStage = 2
			self.moraleRegenStage = 2
		elseif self.morale == 6 then
			self.moraleHasteStage = 2
			self.moraleDefenseStage = 2
			self.moraleRegenStage = 2
		elseif self.morale == 5 then
			self.moraleHasteStage = 2
			self.moraleDefenseStage = 2
			self.moraleRegenStage = 1
		elseif self.morale == 4 then
			self.moraleHasteStage = 2
			self.moraleDefenseStage = 1
			self.moraleRegenStage = 1
		elseif self.morale == 3 then
			self.moraleHasteStage = 1
			self.moraleDefenseStage = 1
			self.moraleRegenStage = 1
		elseif self.morale == 2 then
			self.moraleHasteStage = 1
			self.moraleDefenseStage = 1
			self.moraleRegenStage = 0
		elseif self.morale == 1 then
			self.moraleHasteStage = 1
			self.moraleDefenseStage = 0
			self.moraleRegenStage = 0
		end
	else
		self.moraleHasteStage = 0
		self.moraleDefenseStage = 0
		self.moraleRegenStage = 0
	end

	if self.moraleHasteStage > 0 then --Hard Weapon haste. Thanks to Zeta for the concept of the script. Every time we reload, we take the RT and then we change it. This system allows for multi reload guns to work as well (Like the bolt rifles)
		--Also afects fire-rate, making it the most important atribute
		local gun = ToAHuman(self).EquippedItem
		if gun ~= nil and gun.ClassName == "HDFirearm" then
			local gun = ToHDFirearm(gun)
			if gun:HasObjectInGroup("Weapons") then
				if gun:IsReloading() then
					if
						not gun:NumberValueExists("IA Reload Stat")
						or (gun:NumberValueExists("IA Reload Stat") and gun:GetNumberValue("IA Reload Stat") == 0)
					then
						gun:SetNumberValue("IA ReloadTime", gun.BaseReloadTime)
						gun.BaseReloadTime = gun.BaseReloadTime
							- gun.BaseReloadTime * self.hasteReloadMultiplier * self.moraleHasteStage

						gun:SetNumberValue("IA Reload Stat", 1)
					end
				elseif gun:NumberValueExists("IA Reload Stat") and gun:GetNumberValue("IA Reload Stat") == 1 then
					gun.BaseReloadTime = gun:GetNumberValue("IA ReloadTime")
					gun:SetNumberValue("IA Reload Stat", 0)
				end

				if gun:HasScript("ImporianArmada.rte/Actors/Shared/HasteReloadStatRestore.lua") == false then
					gun:AddScript("ImporianArmada.rte/Actors/Shared/HasteReloadStatRestore.lua")
				else
					gun:EnableScript("ImporianArmada.rte/Actors/Shared/HasteReloadStatRestore.lua")
				end

				if
					not gun:NumberValueExists("IA RoF Stat")
					or (
						gun:NumberValueExists("IA RoF Stat")
						and (
							gun:GetNumberValue("IA RoF Stat") == 0
							or gun:GetNumberValue("IA RoF Stat") ~= self.moraleHasteStage
						)
					)
				then
					if not gun:NumberValueExists("IA RateOfFire") then
						gun:SetNumberValue("IA RateOfFire", gun.RateOfFire)
					end

					local origRoF = gun:NumberValueExists("IA RateOfFire") and gun:GetNumberValue("IA RateOfFire")

					if gun.FullAuto == false then
						gun.RateOfFire = origRoF + origRoF * self.hasteRoFMultiplier * self.moraleHasteStage
					else
						gun.RateOfFire = origRoF + origRoF * self.hasteRoFMultiplier * self.moraleHasteStage * 0.4
					end

					gun:SetNumberValue("IA RoF Stat", self.moraleHasteStage)
				end

				if gun:HasScript("ImporianArmada.rte/Actors/Shared/HasteRoFStatRestore.lua") == false then
					gun:AddScript("ImporianArmada.rte/Actors/Shared/HasteRoFStatRestore.lua")
				else
					gun:EnableScript("ImporianArmada.rte/Actors/Shared/HasteRoFStatRestore.lua")
				end
			end
		end
	else
		local gun = ToAHuman(self).EquippedItem
		if gun ~= nil and gun.ClassName == "HDFirearm" then
			local gun = ToHDFirearm(gun)
			if gun:HasObjectInGroup("Weapons") then
				if gun:NumberValueExists("IA Reload Stat") and gun:GetNumberValue("IA Reload Stat") == 1 then
					gun.BaseReloadTime = gun:GetNumberValue("IA ReloadTime")
					gun:SetNumberValue("IA Reload Stat", 0)
				end

				if gun:NumberValueExists("IA RoF Stat") and gun:GetNumberValue("IA RoF Stat") == 1 then
					gun.RateOfFire = gun:GetNumberValue("IA RateOfFire")
					gun:SetNumberValue("IA RoF Stat", 0)
				end
			end
		end
	end

	if self.moraleDefenseStage > 0 then --Medium damage resistance. Essentially returns some of the health lost to the actor (10 damage with 20% defense => we return 2 hp)
		--Also has the same chance of removing a wound
		local healthReduction = self.defenseDamageMultiplier * self.moraleDefenseStage

		if self.Health < self.damagePreHealth - 1 then
			local damage = self.damagePreHealth - self.Health

			local nuHealth = damage * healthReduction

			self.Health = self.Health + nuHealth

			self.damagePreHealth = self.Health
		else
			self.damagePreHealth = self.Health
		end

		local woundCount = self.WoundCount
		local woundProbability = self.defenseWoundMultiplier * self.moraleDefenseStage

		if woundCount > self.totalWoundCount then
			if math.random() <= woundProbability then
				self:RemoveWounds(1, true, false, false)
			end
			self.totalWoundCount = self.WoundCount
		end
	else
		self.totalWoundCount = self.WoundCount
		self.damagePreHealth = self.Health
	end

	if self.moraleRegenStage > 0 then --Gives a passive regen bonus, with the chance of removing a certain ammount of wounds
		local MaxHealth = self.regenMaxHealthBase + self.regenMaxHealthIncrease * self.moraleRegenStage
		local MaxWoundChance = self.regenWoundChanceBase + self.regenWoundChanceIncrease * self.moraleRegenStage
		local MaxWoundLimit = self.regenMaxWoundBase - self.regenMaxWoundDecrease * self.moraleRegenStage
		local RegenDelay = self.regenDelayBase - self.regenDelayDecrease * self.moraleRegenStage

		if self.regenTimer:IsPastSimMS(RegenDelay) then
			if self.Health < MaxHealth then
				self.Health = self.Health + 1
			end

			if self.WoundCount > MaxWoundLimit and math.random() <= MaxWoundChance then
				self:RemoveWounds(1, true, false, false)
			end
			self.regenTimer:Reset()
		end
	else
		self.regenTimer:Reset()
	end

	----------------------------- Objects and stuff that give morale --------------------------------------------

	if self:NumberValueExists("Officer Morale") then --Neutral
		if self:GetNumberValue("Officer Morale") > 0 then
			self.officerMorale = 1
			if self.officerMoraleTimer:IsPastSimMS(self.officerMoraleDelay) then
				self.officerMoraleTimer:Reset()
				self:SetNumberValue("Officer Morale", (self:GetNumberValue("Officer Morale") - 1))
			end
		elseif self:GetNumberValue("Officer Morale") == 0 then
			self.officerMorale = 0
		end
	else
		self.officerMorale = 0
	end

	if self:NumberValueExists("Gas Morale") then --Neutral/Defensive
		if self:GetNumberValue("Gas Morale") > 0 then
			self.gasMorale = 1
			if self.gasMoraleTimer:IsPastSimMS(self.gasMoraleDelay) then
				self.gasMoraleTimer:Reset()
				self:SetNumberValue("Gas Morale", (self:GetNumberValue("Gas Morale") - 1))
			end
		elseif self:GetNumberValue("Gas Morale") == 0 then
			self.gasMorale = 0
		end
	else
		self.gasMorale = 0
	end

	if self:NumberValueExists("Commander Morale") then --Defensive
		if self:GetNumberValue("Commander Morale") > 0 then
			self.commanderMorale = 2
			if self.commanderMoraleTimer:IsPastSimMS(self.commanderMoraleDelay) then
				self.commanderMoraleTimer:Reset()
				self:SetNumberValue("Commander Morale", (self:GetNumberValue("Commander Morale") - 1))
			end
		elseif self:GetNumberValue("Commander Morale") == 0 then
			self.commanderMorale = 0
		end
	else
		self.commanderMorale = 0
	end

	if self:NumberValueExists("Flag Morale") then --Neutral
		if self:GetNumberValue("Flag Morale") > 0 then
			self.flagMorale = 2
			if self.flagMoraleTimer:IsPastSimMS(self.flagMoraleDelay) then
				self.flagMoraleTimer:Reset()
				self:SetNumberValue("Flag Morale", (self:GetNumberValue("Flag Morale") - 1))
			end
		elseif self:GetNumberValue("Flag Morale") == 0 then
			self.flagMorale = 0
		end
	else
		self.flagMorale = 0
	end

	if self:NumberValueExists("Airship Morale") then --Defensive
		if self:GetNumberValue("Airship Morale") > 0 then
			self.airshipMorale = 2
			if self.airshipMoraleTimer:IsPastSimMS(self.airshipMoraleDelay) then
				self.airshipMoraleTimer:Reset()
				self:SetNumberValue("Airship Morale", (self:GetNumberValue("Airship Morale") - 1))
			end
		elseif self:GetNumberValue("Airship Morale") == 0 then
			self.airshipMorale = 0
		end
	else
		self.airshipMorale = 0
	end

	if self:NumberValueExists("Banner Morale") then --Defensive
		if self:GetNumberValue("Banner Morale") > 0 then
			self.bannerMorale = 3
			if self.bannerMoraleTimer:IsPastSimMS(self.bannerMoraleDelay) then
				self.bannerMoraleTimer:Reset()
				self:SetNumberValue("Banner Morale", (self:GetNumberValue("Banner Morale") - 1))
			end
		elseif self:GetNumberValue("Banner Morale") == 0 then
			self.bannerMorale = 0
		end
	else
		self.bannerMorale = 0
	end

	if self:NumberValueExists("Flare Morale") then --Neutral
		if self:GetNumberValue("Flare Morale") > 0 then
			self.flareMorale = 3
			if self.flareMoraleTimer:IsPastSimMS(self.flareMoraleDelay) then
				self.flareMoraleTimer:Reset()
				self:SetNumberValue("Flare Morale", (self:GetNumberValue("Flare Morale") - 1))
			end
		elseif self:GetNumberValue("Flare Morale") == 0 then
			self.flareMorale = 0
		end
	else
		self.flareMorale = 0
	end
end

function ArmadaSpecialBehaviours.officerMorale(self)
	if self.officerMoraleTargetsTimer:IsPastSimMS(self.officerMoraleTargetsDelay) then
		self.officerMoraleTargetsTimer:Reset()
		for i = 1, #self.officerMoraleTargets do
			local testMoraleTarget = self.officerMoraleTargets[i]
			if testMoraleTarget and IsActor(testMoraleTarget) then
				testMoraleTarget:SetNumberValue("Officer Morale", 2)
			end
		end

		self.officerMoraleTargets = {}

		for mo in MovableMan:GetMOsInRadius(self.Pos, self.officerMaxMoraleRange) do
			if IsActor(mo) then
				act = ToActor(mo)
				if
					act.Team == self.Team
					and act.UniqueID ~= self.UniqueID
					and (act.PresetName == "Rifleman" or act.PresetName == "Marine")
				then
					local trace = SceneMan:ShortestDistance(self.Pos, act.Pos, false)
					local strSumCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + trace, 3, rte.airID)
					if strSumCheck < 10 then
						table.insert(self.officerMoraleTargets, act)
					end
				end
			end
		end
	end
end

function ArmadaSpecialBehaviours.commanderMorale(self)
	if self.commanderMoraleTargetsTimer:IsPastSimMS(self.commanderMoraleTargetsDelay) then
		self.commanderMoraleTargetsTimer:Reset()
		for i = 1, #self.commanderMoraleTargets do
			local testMoraleTarget = self.commanderMoraleTargets[i]
			if testMoraleTarget and IsActor(testMoraleTarget) then
				testMoraleTarget:SetNumberValue("Commander Morale", 2)
			end
		end

		self.commanderMoraleTargets = {}

		for mo in MovableMan:GetMOsInRadius(self.Pos, self.commanderMaxMoraleRange) do
			if IsActor(mo) then
				act = ToActor(mo)
				if
					act.Team == self.Team
					and act.UniqueID ~= self.UniqueID
					and (act.PresetName == "Rifleman" or act.PresetName == "Marine" or act.PresetName == "Officer")
				then
					local trace = SceneMan:ShortestDistance(self.Pos, act.Pos, false)
					local strSumCheck = SceneMan:CastStrengthSumRay(self.Pos, self.Pos + trace, 3, rte.airID)
					if strSumCheck < 10 then
						table.insert(self.commanderMoraleTargets, act)
					end
				end
			end
		end
	end
end

function ArmadaSpecialBehaviours.useDeployables(self) --Decoys, banners, mines, anything placeable (+ flare gun)
	--It used to equip item from inventory and then do weapon fire, but device-switching + dissapearing item = unstable game
	--So now only the signal pistol works that way since it doesn't get deleted when placed
	--The other items have they separate specialBehaviour, that replicates the deploy script the original items have.
	--That way they don't have to equip anything, if they have the item just place it automatically from their inventory

	if self.EquippedItem and self.EquippedItem.PresetName == "Signal Pistol" then
		self:GetController():SetState(Controller.WEAPON_FIRE, true)
	elseif self.deployGearTimer:IsPastSimMS(self.deployGearGrabDelay) then
		local deployed = false

		if self:HasObject("Tripwire Mine") then
			if math.random() <= 0.02 and deployed == false then
				ArmadaSpecialBehaviours.placeMine(self)
				deployed = true
			end
		end

		if self:HasObject("Sniper Decoy") then
			if math.random() <= 0.025 and deployed == false then
				ArmadaSpecialBehaviours.placeDecoy(self)
				deployed = true
			end
		end

		if self:HasObject("Imporian Banner") then
			if math.random() <= 0.02 and deployed == false then
				ArmadaSpecialBehaviours.placeBanner(self)
				deployed = true
			end
		end

		if self:HasObject("Signal Pistol") then
			if math.random() <= 0.025 and deployed == false then
				self:EquipNamedDevice("Signal Pistol", true)
				--				print("Signal Pistol Used - 4")
				deployed = true
			end
		end
		self.deployGearGrabDelay = 4000
		self.deployGearTimer:Reset()
	end
end

function ArmadaSpecialBehaviours.placeBanner(self)
	local defaultPos = Vector()
	local defaultCheck = SceneMan:CastObstacleRay(
		self.Pos,
		Vector(0, 25),
		defaultPos,
		Vector(),
		self.ID,
		self.Team,
		rte.airID,
		0
	)

	if defaultCheck ~= -1 then
		if self.EquippedItem and self.EquippedItem.PresetName == "Imporian Banner" then
			self:UnequipFGArm()
		end

		self:RemoveInventoryItem("Imporian Banner")

		local banner = CreateActor("Armada Banner", "ImporianArmada.rte")

		banner.Pos = defaultPos + Vector(0, -32)
		banner.Team = self.Team
		banner.IgnoresTeamHits = true
		banner.HFlipped = self.HFlipped
		MovableMan:AddParticle(banner)
		--		print("Imporian Banner Placed - 3")

		self:EquipDeviceInGroup("Weapons - Primary", true)
	end
end

function ArmadaSpecialBehaviours.placeDecoy(self)
	local defaultPos = Vector()
	local defaultCheck = SceneMan:CastObstacleRay(
		self.Pos,
		Vector(0, 25),
		defaultPos,
		Vector(),
		self.ID,
		self.Team,
		rte.airID,
		0
	)

	if defaultCheck ~= -1 then
		if self.EquippedItem and self.EquippedItem.PresetName == "Sniper Decoy" then
			self:UnequipFGArm()
		end

		self:RemoveInventoryItem("Sniper Decoy")

		local decoy = CreateActor("Armada Decoy Head", "ImporianArmada.rte")

		decoy.Pos = defaultPos + Vector(0, -25)
		decoy.Team = self.Team
		decoy.IgnoresTeamHits = true
		decoy.HFlipped = self.HFlipped
		MovableMan:AddParticle(decoy)
		--		print("Sniper Decoy Placed - 2")

		self:EquipDeviceInGroup("Weapons - Primary", true)
	end
end

function ArmadaSpecialBehaviours.placeMine(self)
	local defaultPos = Vector()
	local defaultCheck = SceneMan:CastObstacleRay(
		self.Pos,
		Vector(0, 25),
		defaultPos,
		Vector(),
		self.ID,
		self.Team,
		rte.airID,
		0
	)

	if defaultCheck ~= -1 then
		if self.EquippedItem and self.EquippedItem.PresetName == "Tripwire Mine" then
			self:UnequipFGArm()
		end

		self:RemoveInventoryItem("Tripwire Mine")

		local mine = CreateMOSRotating("Armada Tripwire Mine Armed", "ImporianArmada.rte")

		mine.Pos = defaultPos + Vector(0, -2)
		mine.Team = self.Team
		mine.IgnoresTeamHits = true
		mine.HFlipped = self.HFlipped
		MovableMan:AddParticle(mine)
		--		print("Tripwire Mine Placed - 1")

		self:EquipDeviceInGroup("Weapons - Primary", true)
	end
end

function ArmadaSpecialBehaviours.offhandFixer(self)
	if
		not self.EquippedItem
		and self.EquippedBGItem
		and self.EquippedBGItem:HasObjectInGroup("Weapons - Secondary")
		and self.FGArm
	then
		local bgItem = self.EquippedBGItem.PresetName
		self:UnequipBGArm()
		self:EquipNamedDevice(bgItem, true)
	end
end

function ArmadaSpecialBehaviours.teleBoxItem(self)
	local telebox = false
	local hasTelebox

	for attachable in self.Attachables do
		if attachable.PresetName == "TeleBox Attachable" then
			telebox = true
		end
	end

	if self:HasObject("LD-CM Telebox") and telebox == false then
		hasTelebox = true
	elseif not self:HasObject("LD-CM Telebox") then
		hasTelebox = false
	end

	if hasTelebox == true then
		if self.EquippedItem and self.EquippedItem.PresetName == "LD-CM Telebox" then
			self:UnequipFGArm()
		end

		self:RemoveInventoryItem("LD-CM Telebox")

		self:AddAttachable(CreateAttachable("TeleBox Attachable", "ImporianArmada.rte"), Vector(-8, -4))
		self:SetGoldValue(self:GetGoldValue(self.ModuleID, 1, 1) + 100)

		self:AddInventoryItem(CreateHDFirearm("LD-CM Telebox Phone"))

		--		self:EquipNamedDevice("LD-CM Telebox Phone", true)
	end
end

function ArmadaSpecialBehaviours.moreArmor(self)
	local hasArmor = false

	if self:HasObject("Armor Upg.") then
		if self:NumberValueExists("Armor Upgrade") then --Do we has armor?
			hasArmor = true
		end

		if self.EquippedItem and self.EquippedItem.PresetName == "Armor Upg." then
			self:UnequipFGArm()
		end

		self:RemoveInventoryItem("Armor Upg.")
		if hasArmor == false then
			if self.PresetName == "Rifleman" then
				if self.Head then
					if math.random() <= 0.65 then
						self.Head:AddAttachable(
							CreateAttachable("Imporian Armada Gas Mask Heavy A", "ImporianArmada.rte"),
							Vector(3, 3)
						)
						self:SetNumberValue("Heavy Mask", 1)
					end

					self.Head:AddAttachable(
						CreateAttachable("Imporian Armada Helmet A", "ImporianArmada.rte"),
						Vector(1, -5)
					)
					self:SetNumberValue("Helmet Metal", 1)
				end
			elseif self.PresetName == "Marine" then
				self.Head:AddAttachable(
					CreateAttachable("Imporian Armada Gas Mask Heavy B", "ImporianArmada.rte"),
					Vector(3, 2)
				)
				self:SetNumberValue("Heavy Mask", 1)

				self.Head:AddAttachable(
					CreateAttachable("Imporian Armada Helmet Heavy B", "ImporianArmada.rte"),
					Vector(0, -5)
				)

				self:AddAttachable(
					CreateAttachable("Imporian Armada Pouches Heavy B", "ImporianArmada.rte"),
					Vector(2, -2)
				)
			elseif self.PresetName == "Officer" then
				if math.random() <= 0.85 then
					self.Head:AddAttachable(
						CreateAttachable("Imporian Armada Gas Mask Heavy C", "ImporianArmada.rte"),
						Vector(3, 3)
					)
					self:SetNumberValue("Heavy Mask", 1)
				end

				self.Head:AddAttachable(
					CreateAttachable("Imporian Armada Hat C Base", "ImporianArmada.rte"),
					Vector(0, -4)
				) --Since new mask, we have to re-add the hat

				self:AddAttachable(
					CreateAttachable("Imporian Armada Armored Chestpiece", "ImporianArmada.rte"),
					Vector(2, -2)
				)
			elseif self.PresetName == "Field Commander" then
				self.Head:AddAttachable(
					CreateAttachable("Imporian Armada Gas Mask Full D", "ImporianArmada.rte"),
					Vector(4, 4)
				)

				self.Head:AddAttachable(
					CreateAttachable("Imporian Armada Hat D Base", "ImporianArmada.rte"),
					Vector(0, -4)
				)

				self:AddAttachable(
					CreateAttachable("Imporian Armada Armored Chestpiece", "ImporianArmada.rte"),
					Vector(2, -2)
				)
			end

			self:SetNumberValue("Armor Upgrade", 1)
			self:SetGoldValue(self:GetGoldValue(self.ModuleID, 1, 1) + 25)
		elseif hasArmor == true then --We got armor, we refund it
			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Add gold for extras
			ActivityMan:GetActivity():SetTeamFunds(founds + 25, self.Team)
		end
		self:EquipDeviceInGroup("Weapons - Primary", true)
	end
end

function ArmadaSpecialBehaviours.enemyGear(self)
	-------------	Possibility Variables  -----------------

	local gearDecoyProbability = 0
	local gearBannerProbability = 0
	local gearSignalProbability = 0
	local gearTurretProbability = 0

	local gearPeriscopeProbability = 0
	local gearSurplusProbability = 0

	if self.PresetName == "Rifleman" then
		self.gearSyringeProbability = 0.45
		self.gearArmorProbability = 0.3

		gearDecoyProbability = 0.25
		gearBannerProbability = 0.1
		gearSignalProbability = 0.1

		gearPeriscopeProbability = 0.2
		gearSurplusProbability = 0.25
	elseif self.PresetName == "Marine" then
		self.gearSyringeProbability = 0.65
		self.gearArmorProbability = 0.25

		gearDecoyProbability = 0.15
		gearBannerProbability = 0.4
		gearSignalProbability = 0
		gearTurretProbability = 0.06

		gearPeriscopeProbability = 0
		gearSurplusProbability = 0.1
	elseif self.PresetName == "Officer" then
		self.gearSyringeProbability = 0.5
		self.gearArmorProbability = 0.15

		gearDecoyProbability = 0.1
		gearBannerProbability = 0
		gearSignalProbability = 0.35

		gearPeriscopeProbability = 0.1
		gearSurplusProbability = 0.4
	elseif self.PresetName == "Field Commander" then
		self.gearSyringeProbability = 0.25
		self.gearArmorProbability = 0.35

		gearDecoyProbability = 0.1
		gearBannerProbability = 0.35
		gearSignalProbability = 0.5
		gearTurretProbability = 0.1

		gearPeriscopeProbability = 0
		gearSurplusProbability = 0.5
	end

	------------- Probability of Armor Upgrade -------------------

	if math.random() <= self.gearArmorProbability then
		self:AddInventoryItem(CreateHDFirearm("Armor Upg.", "ImporianArmada.rte"))

		local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Remove gold
		ActivityMan:GetActivity():SetTeamFunds(founds - 25, self.Team)
	end

	------------- Possibility of Health Syringe ------------------

	if math.random() <= self.gearSyringeProbability then
		self:AddInventoryItem(CreateHDFirearm("Health Syringe", "ImporianArmada.rte"))

		local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Remove gold
		ActivityMan:GetActivity():SetTeamFunds(founds - 10, self.Team)

		if math.random() <= (self.gearSyringeProbability * 0.5) then
			self:AddInventoryItem(CreateHDFirearm("Health Syringe", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Remove gold
			ActivityMan:GetActivity():SetTeamFunds(founds - 10, self.Team)
		end
	end

	if math.random() <= gearDecoyProbability then
		self:AddInventoryItem(CreateHDFirearm("Sniper Decoy", "ImporianArmada.rte"))

		local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Remove gold
		ActivityMan:GetActivity():SetTeamFunds(founds - 15, self.Team)
	end
	if math.random() <= gearBannerProbability then
		self:AddInventoryItem(CreateHDFirearm("Imporian Banner", "ImporianArmada.rte"))

		local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Remove gold
		ActivityMan:GetActivity():SetTeamFunds(founds - 40, self.Team)
	end
	if math.random() <= gearSignalProbability then
		self:AddInventoryItem(CreateHDFirearm("Signal Pistol", "ImporianArmada.rte"))

		local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Remove gold
		ActivityMan:GetActivity():SetTeamFunds(founds - 60, self.Team)
	end
	if math.random() <= gearPeriscopeProbability then
		self:AddInventoryItem(CreateHDFirearm("Trench Periscope", "ImporianArmada.rte"))
	end
	if math.random() <= gearSurplusProbability then
		self:AddInventoryItem(CreateHDFirearm("Surplus Mask", "ImporianArmada.rte"))
	end

	-------------	Possibility of Deployable Turret -----------------

	if math.random() <= gearTurretProbability then
		if self.PresetName ~= "Field Commander" and math.random() <= 0.2 then
			self:AddInventoryItem(CreateHDFirearm("AT-EG Gun Bag", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Remove gold
			ActivityMan:GetActivity():SetTeamFunds(founds - 200, self.Team)
		else
			self:AddInventoryItem(CreateHDFirearm("M-EM Gun Bag", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Remove gold
			ActivityMan:GetActivity():SetTeamFunds(founds - 145, self.Team)
		end
	end

	------------------- Reels for the TeleBox -----------------------

	if self:HasObject("LD-CM Telebox") or self:HasObject("LD-CM Telebox Phone") then
		self.hasTelebox = true
	elseif
		self.EquippedItem
		and (self.EquippedItem.PresetName == "LD-CM Telebox" or self.EquippedItem.PresetName == "LD-CM Telebox Phone")
	then
		self.hasTelebox = true
	end

	if self.hasTelebox == true then
		self:AddInventoryItem(CreateHDFirearm("Heavy Artillery Reel", "ImporianArmada.rte"))

		local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team)
		ActivityMan:GetActivity():SetTeamFunds(founds - 50, self.Team)

		if math.random() <= 0.3 then
			self:AddInventoryItem(CreateHDFirearm("Heavy Artillery Reel", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team)
			ActivityMan:GetActivity():SetTeamFunds(founds - 50, self.Team)
		end

		if math.random() <= 0.3 then
			self:AddInventoryItem(CreateHDFirearm("Massive Barrage Reel", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team)
			ActivityMan:GetActivity():SetTeamFunds(founds - 80, self.Team)
		end

		if math.random() <= 0.15 then
			self:AddInventoryItem(CreateHDFirearm("Massive Barrage Reel", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team)
			ActivityMan:GetActivity():SetTeamFunds(founds - 80, self.Team)
		end

		if math.random() <= 0.25 then
			self:AddInventoryItem(CreateHDFirearm("Precise Artillery Reel", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team)
			ActivityMan:GetActivity():SetTeamFunds(founds - 125, self.Team)
		end

		if math.random() <= 0.4 then
			self:AddInventoryItem(CreateHDFirearm("Gas Artillery Reel", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team)
			ActivityMan:GetActivity():SetTeamFunds(founds - 125, self.Team)
		end
	end

	--------------- Extra ammunition for Lazarus  ------------------

	local hasLazarus = false

	if self:HasObject('BS-GT "Lazarus"') then
		hasLazarus = true
	elseif self.EquippedItem and self.EquippedItem.PresetName == 'BS-GT "Lazarus"' then
		hasLazarus = true
	end

	if hasLazarus == true then
		--		print("flame tiem")

		self:AddInventoryItem(CreateHDFirearm("Lazarus Ammo", "ImporianArmada.rte"))

		local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Remove gold
		ActivityMan:GetActivity():SetTeamFunds(founds - 40, self.Team)

		if math.random() <= 0.5 then --Extra pouch
			self:AddInventoryItem(CreateHDFirearm("Lazarus Ammo", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team) --Remove gold
			ActivityMan:GetActivity():SetTeamFunds(founds - 40, self.Team)
		end
	end

	------------------- Reels for the TeleBox -----------------------

	if self:HasObject('ATR-39 "Dominatus"') then
		self.hasDominatus = true
	elseif self.EquippedItem and self.EquippedItem.PresetName == 'ATR-39 "Dominatus"' then
		self.hasDominatus = true
	end

	if self.hasDominatus == true then
		self:AddInventoryItem(CreateHDFirearm("Dominatus Ammo", "ImporianArmada.rte"))

		local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team)
		ActivityMan:GetActivity():SetTeamFunds(founds - 30, self.Team)

		if math.random() <= 0.45 then
			self:AddInventoryItem(CreateHDFirearm("Dominatus Ammo", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team)
			ActivityMan:GetActivity():SetTeamFunds(founds - 30, self.Team)
		end

		if math.random() <= 0.25 then
			self:AddInventoryItem(CreateHDFirearm("Dominatus Ammo", "ImporianArmada.rte"))

			local founds = ActivityMan:GetActivity():GetTeamFunds(self.Team)
			ActivityMan:GetActivity():SetTeamFunds(founds - 30, self.Team)
		end
	end
end
