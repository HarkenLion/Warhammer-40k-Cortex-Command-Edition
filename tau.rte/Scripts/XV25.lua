dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI") --dofile("Base.rte/AI/NativeHumanAI.lua")

function Create(self)
	self.enableselect = true

	self.mapwrapx = SceneMan.SceneWrapsX
	self.activeCamo = false
	self.CloakTimer = Timer()
	self.WTime = Timer()

	self.redeyeOffset = Vector(13, -6)
	self.redeye = nil
	self.redeye = CreateMOPixel("XV25 Red Eye")
	self.redeye.Pos = self.Pos + self.redeyeOffset
	MovableMan:AddParticle(self.redeye)

	self.AI = NativeHumanAI:Create(self)
end

function ThreadedUpdate(self)
	if self:IsPlayerControlled() == true then
		if self.enableselect == true then
			self.selected = CreateAEmitter("Tau Stealth Select")
			self.selected.Pos = self.Pos
			self.selected.PinStrength = 1000
			MovableMan:AddParticle(self.selected)
			self.enableselect = false
		end
	else
		self.enableselect = true
	end

	--IF THE UNIT IS NOT DEAD...
	if not (self:IsDead()) then
		if MovableMan:ValidMO(self.redeye) then
			self.redeye.Pos = self.Pos + self.redeyeOffset:RadRotate(self.RotAngle)
			self.redeye:NotResting()
			self.redeye.Age = 0
			self.redeye.ToSettle = false
		end

		--IF ACTIVE CAMO IS ON, DO THESE THINGS
		if self.activeCamo == true then
			if self.WTime:IsPastSimMS(250) then
				self.WTime:Reset()
				--DETECTOR CHECK
				for actor in MovableMan:GetMOsInRadius(self.Pos, 165, self.Team) do
					--for actor in MovableMan.Actors do
					--if actor.Team ~= self.Team then
					if actor.ClassName == "Actor" then
						local parvector = SceneMan:ShortestDistance(self.Pos, actor.Pos, self.mapwrapx)
						--local pardist = parvector.Magnitude;
						local percep = ToActor(actor).Perceptiveness

						local shieldradius = 125
						--if pardist < shieldradius * percep then
						if parvector:MagnitudeIsLessThan(shieldradius * percep) then
							self.CloakTimer:Reset()
							self.change = true
						end
					end
				end
				--END DETECTOR CHECK
			end

			if self.Vel.Magnitude > 20 then
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

			--CREATE RED EYE EFFECT
			local redeyeOffset = Vector(13, -6)
			if self.HFlipped then
				redeyeOffset = Vector(-13, -6)
			end
			local redeye = CreateMOPixel("XV25 Red Eye")
			redeye.Pos = self.Pos + redeyeOffset:RadRotate(self.RotAngle)
			MovableMan:AddParticle(redeye)
		end

		--SYSTEM OF CHECKS TO INFORM INVISIBLITY SYSTEM WHETHER OR NOT IT SHOULD ACTIVATE
		if not self.CloakTimer:IsPastSimMS(135) and self.Scale == 0 then
			self.change = true
			self.HUDVisible = true
		end
		if self.CloakTimer:IsPastSimMS(575) and not self.CloakTimer:IsPastSimMS(775) then
			self.change = true
		end
		if self.CloakTimer:IsPastSimMS(775) and self.activeCamo == false then
			self.change = true
			self.HUDVisible = false
		end

		--INVISIBILITY SYSTEM: HANDLE ACTUAL INVISIBILITY CHANGE
		if self.change == true then
			for i = 0, MovableMan:GetMOIDCount() do
				if MovableMan:GetRootMOID(i) == self.ID then
					local object = MovableMan:GetMOFromID(i)
					if
						not (object:IsDevice()) or (object:IsDevice() and (object.PresetName == "Burst Cannon XV25"))
					then
						if self.activeCamo == true then
							object.Scale = 1
						else
							object.Scale = 0

							--CREATE RED EYE EFFECT
							local redeyeOffset = Vector(13, -6)
							if self.HFlipped then
								redeyeOffset = Vector(-13, -6)
							end
							local redeye = CreateMOPixel("XV25 Red Eye 2")
							redeye.Pos = self.Pos + redeyeOffset:RadRotate(self.RotAngle)
							MovableMan:AddParticle(redeye)
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
				if not (object:IsDevice()) or (object:IsDevice() and (object.PresetName == "Burst Cannon XV25")) then
					object.Scale = 1
					self.HUDVisible = true
				end
			end
		end
		self.RotAngle = self.RotAngle * 0.98
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end

function Destroy(self)
	if MovableMan:IsActor(self) == true then
		self.AngularVel = 0
	end
end
