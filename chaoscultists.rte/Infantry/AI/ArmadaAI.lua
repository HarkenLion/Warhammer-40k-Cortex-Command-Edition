dofile("Base.rte/Constants.lua")
package.path = package.path .. ";ImporianArmada.rte/?.lua"
require("Actors/AI/NativeArmadaAI")
require("Actors/AI/ArmadaSpecialBehaviours")

function Create(self)
	self.AI = NativeArmadaAI:Create(self)

	self.Frame = math.random(0, self.FrameCount - 1)

	-----------------------End Non-Modded Code---------------------------------

	self.eyeAnimation = true --Disable to remove eye blinking and reacting

	----Morale stuff-------

	self.morale = 0
	self.origMorale = 0
	if self.PresetName == "Officer" or self.PresetName == "Field Commander" then
		self.origMorale = 1
	end

	self.regenTimer = Timer()
	self.regenDelayBase = 2000 --1600
	self.regenDelayDecrease = 500 --400
	self.regenMaxHealthBase = 100 --45
	self.regenMaxHealthIncrease = 0 --15
	self.regenWoundChanceBase = 0 --0
	self.regenWoundChanceIncrease = 0.2 --0.15
	self.regenMaxWoundBase = 0 --8
	self.regenMaxWoundDecrease = 0 --2

	self.defenseDamageMultiplier = 0.25
	self.defenseWoundMultiplier = 0.2

	self.hasteReloadMultiplier = 0.2
	self.hasteRoFMultiplier = 0.3

	self.origPerceptiveness = self.Perceptiveness
	self.moraleHealthReduction = 1
	self.damagePreHealth = self.Health
	self.totalWoundCount = 0

	self.moraleRegenStage = 0
	self.moraleDefenseStage = 0
	self.moraleHasteStage = 0

	---------- Morale givers ---------------------

	self.bannerMoraleTimer = Timer()
	self.bannerMoraleDelay = 1000
	self.bannerMorale = 0

	----------------------------------------------

	self.gasMoraleTimer = Timer()
	self.gasMoraleDelay = 500
	self.gasMorale = 0

	----------------------------------------------

	self.flagMoraleTimer = Timer()
	self.flagMoraleDelay = 1000
	self.flagMorale = 0

	----------------------------------------------

	self.flareMoraleTimer = Timer()
	self.flareMoraleDelay = 1000
	self.flareMorale = 0

	----------------------------------------------

	self.airshipMoraleTimer = Timer()
	self.airshipMoraleDelay = 500
	self.airshipMorale = 0

	-----------------------------------------------
	self.officerMoraleTimer = Timer()
	self.officerMoraleDelay = 800
	self.officerMorale = 0

	self.officerMoraleTargetsTimer = Timer()
	self.officerMoraleTargetsDelay = 450
	self.officerMoraleTargets = {}
	self.officerMaxMoraleRange = 160 + self.Radius

	------------------------------------------------
	self.commanderMoraleTimer = Timer()
	self.commanderMoraleDelay = 1200
	self.commanderMorale = 0

	self.commanderMoraleTargetsTimer = Timer()
	self.commanderMoraleTargetsDelay = 800
	self.commanderMoraleTargets = {}
	self.commanderMaxMoraleRange = 200 + self.Radius

	----- Human Expressions stuff --------

	self.blinkingTimer = Timer()
	self.blinkingDelay = 500
	self.blinkingOpeningTimer = Timer()
	self.blinkingOpeningDelay = 65

	self.preHealth = self.Health

	self.hurtTimer = Timer()
	self.hurtDelay = 350
	self.hurtSize = 0

	self.firingTimer = Timer()
	self.firingDelay = 450

	--Stuff for matching eyebrows. Very shitty probably as it has to check what head we have, and while most have the same eyebrow type, some are more unique
	-- 1 = Black, 3 = Brown, 5 = Red, 7 = Redish Brown, 9 = Jet Black, 11 = Jet brown, 13 = Scar black(Unique), 15 = Light grey
	--It's messy, I know, specially the Ranger and Enforcer

	if self.PresetName == "Rifleman" then
		self.headTable = { 0, 5, 10, 15, 20, 25, 30, 35 }

		if not self:NumberValueExists("Identity") then
			self.possibleHead = self.headTable[(math.ceil(math.random(1, 8)))]
			self:SetNumberValue("Identity", self.possibleHead)
		else
			self.possibleHead = self:GetNumberValue("Identity")
		end

		if
			self.possibleHead == self.headTable[1]
			or self.possibleHead == self.headTable[2]
			or self.possibleHead == self.headTable[3]
			or self.possibleHead == self.headTable[4]
			or self.possibleHead == self.headTable[5]
			or self.possibleHead == self.headTable[6]
		then
			self.eyebrowType = 1
		elseif self.possibleHead == self.headTable[7] or self.possibleHead == self.headTable[8] then
			self.eyebrowType = 3
		end
	elseif self.PresetName == "Marine" then
		self.headTable = { 0, 5, 10, 15, 20 }

		if not self:NumberValueExists("Identity") then
			self.possibleHead = self.headTable[(math.ceil(math.random(1, 5)))]
			self:SetNumberValue("Identity", self.possibleHead)
		else
			self.possibleHead = self:GetNumberValue("Identity")
		end

		if self.possibleHead == self.headTable[1] or self.possibleHead == self.headTable[3] then
			self.eyebrowType = 3
		elseif self.possibleHead == self.headTable[4] or self.possibleHead == self.headTable[5] then
			self.eyebrowType = 1
		elseif self.possibleHead == self.headTable[2] then
			self.eyebrowType = 13
		end
	elseif self.PresetName == "Officer" then
		self.headTable = { 0, 5, 10, 15 }

		if not self:NumberValueExists("Identity") then
			self.possibleHead = self.headTable[(math.ceil(math.random(1, 4)))]
			self:SetNumberValue("Identity", self.possibleHead)
		else
			self.possibleHead = self:GetNumberValue("Identity")
		end

		if
			self.possibleHead == self.headTable[1]
			or self.possibleHead == self.headTable[2]
			or self.possibleHead == self.headTable[3]
		then
			self.eyebrowType = 1
		elseif self.possibleHead == self.headTable[4] then
			self.eyebrowType = 3
		end
	elseif self.PresetName == "Field Commander" then
		self.headTable = { 0, 5 }

		if not self:NumberValueExists("Identity") then
			self.possibleHead = self.headTable[(math.ceil(math.random(1, 2)))]
			self:SetNumberValue("Identity", self.possibleHead)
		else
			self.possibleHead = self:GetNumberValue("Identity")
		end

		self.eyebrowType = 15
	end

	self:SetNumberValue("Head", self.possibleHead)
	self:SetNumberValue("Eyebrow", self.eyebrowType)

	--------------------------------------------------

	self.hasArmor = false
	self.removeArmorItem = false

	----- Enemy gear chance --------
	----- This needs to be under all that, otherwise it causes bugs, somehow... -----

	self.gearSyringeProbability = 0
	self.gearArmorProbability = 0

	self.extraGearProbability = 0 --For things like decoys, banners, etc

	self.deployGearTimer = Timer()
	self.deployGearGrabDelay = 12000 -- Initial spawn delay

	self.IsPlayer = ActivityMan:GetActivity():IsHumanTeam(self.Team)

	self.autoGame = false --For when the activity automatically spawns them on your side :)

	if self.IsPlayer == false or self.autoGame == true then
		ArmadaSpecialBehaviours.enemyGear(self)
	end
end

function Update(self)
	----------------------------Modded Code------------------------------------

	if not self:IsDead() then
		ArmadaSpecialBehaviours.moraleSystem(self)

		if self.PresetName == "Officer" then
			ArmadaSpecialBehaviours.officerMorale(self)
		end

		if self.PresetName == "Field Commander" then
			ArmadaSpecialBehaviours.commanderMorale(self)
		end

		ArmadaSpecialBehaviours.moreArmor(self)
		ArmadaSpecialBehaviours.teleBoxItem(self)
		ArmadaSpecialBehaviours.humanExpressionsSystem(self)
		--		ArmadaSpecialBehaviours.offhandFixer(self)

		---------- Deployable stuff ----------------

		if self.IsPlayer == false then
			if self:GetController():IsState(Controller.WEAPON_FIRE) then
				self.deployGearTimer:Reset()
			end

			if self.AIMode ~= Actor.AIMODE_NONE then --To ensure we don't do funny stuff when manning guns
				ArmadaSpecialBehaviours.useDeployables(self)
			end
		end
	end
	-------------------------Non-Modded code-----------------------------------

	self.controller = self:GetController()
end
function UpdateAI(self)
	self.AI:Update(self)
end
function Destroy(self)
	self.AI:Destroy(self)
end
