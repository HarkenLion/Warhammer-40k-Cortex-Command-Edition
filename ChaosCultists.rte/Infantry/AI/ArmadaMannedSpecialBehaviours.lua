GuardMannedSpecialBehaviours = {}

function GuardMannedSpecialBehaviours.manTheGuns(self)
	if self.gotGunner == false then
		local gunner = CreateAHuman("Guardsman", "GrandGuard.rte")
		gunner.Pos = self.Pos
		gunner.Team = self.Team
		gunner.Vel = self.Vel
		gunner.AIMode = Actor.AIMODE_SENTRY
		gunner:AddScript("Base.rte/Scripts/Shared/NoCasualty.lua")

		local sidearm = RandomHDFirearm("Weapons - Secondary", "GrandGuard.rte")
		local mainarm = nil
		if math.random() < 0.5 then
			mainarm = RandomHDFirearm("Weapons - Light", "GrandGuard.rte")
		end

		gunner:AddInventoryItem(sidearm)
		if mainarm then
			gunner:AddInventoryItem(mainarm)
		end

		MovableMan:AddActor(gunner)

		self.gotGunner = true
	end
end

function GuardMannedSpecialBehaviours.checkGuns(self)
	if self.actorType == "Human" then
		if not self.EquippedItem and self.hasEngine then
			--			self.Health = 0;
			GuardMannedSpecialBehaviours.explodeEngine(self)
		end
	end
end

function GuardMannedSpecialBehaviours.explodeEngine(self)
	if self.engine and self.engine:IsAttached() then
		if self.canExplode == false then
			self.canExplode = true
			self.deathTimer:Reset()
		elseif self.deathTimer:IsPastSimMS(self.deathDelay) then
			if self.deathBlinks > 0 then
				self.deathTimer:Reset()
				self.deathBlinks = self.deathBlinks - 1
				self:FlashWhite(25)
			else
				self.engine:GibThis()
			end
		end
	end
end

function GuardMannedSpecialBehaviours.checkEngine(self)
	if not (self.engine and self.engine:IsAttached()) then
		self.Health = 0
	end
end
