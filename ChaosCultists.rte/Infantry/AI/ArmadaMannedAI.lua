dofile("Base.rte/Constants.lua")
package.path = package.path .. ";GrandGuard.rte/?.lua"
require("Actors/AI/NativeGuardAI")
require("Actors/Manned/AI/GuardMannedSpecialBehaviours")

function Create(self)
	self.AI = NativeGuardAI:Create(self)

	self.gotGunner = false

	self.actorType = nil
	self.hasEngine = false

	if self.PresetName == "MA-AW" then
		self.actorType = "Human"
		self.crewSize = 1

		self.hasEngine = true
		for attachable in self.Attachables do
			if attachable.PresetName == "Grand MA-AW Engine" then
				self.engine = attachable
			end
		end
	end

	self.deathTimer = Timer()
	self.canExplode = false

	self.deathDelay = 100
	self.deathBlinks = 4

	self.IsPlayer = ActivityMan:GetActivity():IsHumanTeam(self.Team)

	self.autoGame = false --For when the activity automatically spawns them on your side :)
end

function Update(self)
	if self.IsPlayer == false or self.autoGame == true then
		GuardMannedSpecialBehaviours.manTheGuns(self)
	end

	if not self:IsDead() then
		GuardMannedSpecialBehaviours.checkGuns(self)

		if self.hasEngine == true then
			GuardMannedSpecialBehaviours.checkEngine(self)
		end
	else
		GuardMannedSpecialBehaviours.explodeEngine(self)
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	self.AI:Destroy(self)
end
