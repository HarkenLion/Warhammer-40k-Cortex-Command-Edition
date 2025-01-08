require("AI/NativeHumanAI")

function Create(self)
	self.AI = NativeHumanAI:Create(self)

	self.RearmTimer = Timer()
	self.garbTimer = Timer()
	self.WTime = Timer()

	self.mapwrapx = SceneMan.SceneWrapsX
	self.activeCamo = false
	self.CloakTimer = Timer()
end

function Update(self)
	local health = self.Health
	if health > 0 then
		--IF THE UNIT IS NOT DEAD...
		if not (self:IsDead()) then
			--IF ACTIVE CAMO IS ON, DO THESE THINGS
			if self.activeCamo == true then
				if self.WTime:IsPastSimMS(75) then
					--DETECTOR CHECK
					for actor in MovableMan.Actors do
						if actor.Team ~= self.Team then
							local parvector = SceneMan:ShortestDistance(self.Pos, actor.Pos, self.mapwrapx)
							local pardist = parvector.Magnitude
							local percep = ToActor(actor).Perceptiveness

							local shieldradius = 225
							if pardist < shieldradius * percep then
								self.CloakTimer:Reset()
								self.change = true
							end
						end
					end
					--END DETECTOR CHECK
				end

				if self.Vel.Magnitude > 15 then
					self.CloakTimer:Reset()
					self.change = true
				end

				--SEE IF UNIT IS FIRING
				if
					self:GetController():IsState(Controller.WEAPON_FIRE)
					or self:GetController():IsState(Controller.WEAPON_RELOAD)
				then
					self.CloakTimer:Reset()
					self.change = true
				end
			end

			--SYSTEM OF CHECKS TO INFORM INVISIBLITY SYSTEM WHETHER OR NOT IT SHOULD ACTIVATE
			if not self.CloakTimer:IsPastSimMS(135) and self.Scale == 0 then
				self.change = true
				self.HUDVisible = true
			end
			if self.CloakTimer:IsPastSimMS(975) and not self.CloakTimer:IsPastSimMS(1175) then
				self.change = true
			end
			if self.CloakTimer:IsPastSimMS(1175) and self.activeCamo == false then
				self.change = true
				self.HUDVisible = false
			end

			--INVISIBILITY SYSTEM: HANDLE ACTUAL INVISIBILITY CHANGE
			if self.change == true then
				for i = 0, MovableMan:GetMOIDCount() do
					if MovableMan:GetRootMOID(i) == self.ID then
						local object = MovableMan:GetMOFromID(i)
						if
							not (object:IsDevice())
							or (
								object:IsDevice()
								and ((object.PresetName == "Stealth Shoota") or (object.PresetName == "Choppa"))
							)
						then
							if self.activeCamo == true then
								object.Scale = 1
							else
								object.Scale = 0
							end
						end
					end
				end

				if self.activeCamo == true then
					self.activeCamo = false
				else
					self.activeCamo = true
				end

				self.change = false
			end
		else
			--...IF THE UNIT IS DEAD, PERFORM END LIFE FUNCTIONS
			for i = 0, MovableMan:GetMOIDCount() do
				if MovableMan:GetRootMOID(i) == self.ID then
					local object = MovableMan:GetMOFromID(i)
					if
						not (object:IsDevice())
						or (
							object:IsDevice()
							and ((object.PresetName == "Stealth Shoota") or (object.PresetName == "Choppa"))
						)
					then
						object.Scale = 1
						self.HUDVisible = true
					end
				end
			end
			self.RotAngle = self.RotAngle * 0.98
		end

		if not self:HasObject("Stikk Bomb") and self.RearmTimer:IsPastSimMS(2350) then
			local hook = CreateTDExplosive("Stikk Bomb")
			self:AddInventoryItem(hook)
			self.RearmTimer:Reset()
		end

		self:ClearForces()
		self.AngularVel = self.AngularVel * 0.97

		if self.garbTimer:IsPastSimMS(3000 - (100 - health) * 10) then
			self.garbTimer:Reset()
			if health < 100 then
				self.Health = health + 1
			end
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
