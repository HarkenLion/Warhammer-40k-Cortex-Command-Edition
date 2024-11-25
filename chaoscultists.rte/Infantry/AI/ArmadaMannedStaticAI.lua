dofile("Base.rte/Constants.lua")
package.path = package.path .. ";chaoscultists.rte/?.lua"
require("Infantry/AI/NativeArmadaTurretAI")
require("Infantry/AI/ArmadaMannedStaticSpecialBehaviours")

function Create(self)
	self.AI = NativeArmadaTurretAI:Create(self) --Emplacement AI for static weapons

	self.crewSpawnTimer = Timer()
	self.crewReloaderDelay = 150
	self.crewSpotterDelay = 300

	self.gotGunner = false
	self.gotReloader = false
	self.gotSpotter = false

	self.reloaderChance = 0
	self.spotterChance = 0

	if self.PresetName == "AutoCannon Turret" then
		self.crewSize = 1
		self.reloaderChance = 0.85
		self.spotterChance = 0.4
	elseif self.PresetName == "Bolter Turret" then
		self.crewSize = 1
		self.reloaderChance = 0.65
		self.spotterChance = 0
	end
	self.IsPlayer = ActivityMan:GetActivity():IsHumanTeam(self.Team)

	self.autoGame = false --For when the activity automatically spawns them on your side :)
end

function Update(self)
	if (self.IsPlayer == false or self.autoGame == true) and not self:NumberValueExists("Bag Spawn") then
		ArmadaMannedStaticSpecialBehaviours.manTheGuns(self)
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	self.AI:Destroy(self)
end
