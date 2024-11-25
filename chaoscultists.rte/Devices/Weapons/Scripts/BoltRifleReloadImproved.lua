---------------------------------------------------------------------------------------------
-------------- Angle stuff and lever animation originally by 4zk ---------------------------
---------------------------------------------------------------------------------------------

function Create(self)
	self.reloadFullSound = true
	self.reloadOpenSound = true
	self.reloadOpenTimer = Timer()
	self.reloadCloseSound = false
	self.lastCasing = false
	self.canEject = true

	self.reloadTimer = Timer()
	self.loadedShell = false
	self.reloadCycle = false

	self.reloadDelay = 120 --Time between each reload.

	self.parent = nil
	self.pullTimer = Timer()

	self.chamber = false
	self.casing = false
	self.angleSize = 0.35 --Angle size when pulling the lever
	self.reloadAngleSize = 0.35 --Change this if you feel the gun rotates a bit too much or too litle

	self.origReloadTime = self.BaseReloadTime
	self.firstShell = true
	self.firstShellDelay = 3 --How much is the reload time multiplied by for the first shell
	self.reloadNum = 0

	if self.Magazine then
		self.lastAmmo = self.Magazine.RoundCount
		self.magCount = self.Magazine.RoundCount
		self.magTotal = self.Magazine.RoundCount
	end
end

function Update(self)
	-- Lever action reload starts here --
	if self.firstShell == true and self.reloadCycle == false then --First shell in? between the movement and such it takes a bit more
		self.BaseReloadTime = self.origReloadTime * self.firstShellDelay --Change multiplier to change time of first shell.
	elseif self.firstShell == false then
		self.BaseReloadTime = self.origReloadTime
	end

	if self.parent then
		if self.reloadCycle == true then --Yo we reloading, better grab my weapon better
			if self.reloadNum < 1 then
				self.reloadNum = self.reloadNum + 1 / self.Mass
			elseif self.reloadNum > 1 then
				self.reloadNum = 1
			end
		elseif self.reloadCycle == false then --Let's get back into it
			if self.reloadNum > 0 then
				self.reloadNum = self.reloadNum - 1 / self.Mass
			elseif self.reloadNum < 0 then
				self.reloadNum = 0
			end
		end
		self.RotAngle = self.RotAngle + self.FlipFactor * self.reloadNum * self.reloadAngleSize --The numbers above affect the rotation operation here
	else
		self.reloadNum = 0
	end

	if self.Magazine ~= nil then
		if self.loadedShell == false then
			self.ammoCounter = self.Magazine.RoundCount
		else
			self.loadedShell = false
			self.Magazine.RoundCount = self.ammoCounter + 1
			self.firstShell = false
		end
	else
		if self.reloadOpenTimer:IsPastSimMS(50) then
			if self.reloadOpenSound == true then
				AudioMan:PlaySound("Loyalists.rte/Devices/Weapons/Shared/Sounds/Chamber.flac", self.Pos)
				self.reloadOpenSound = false
			end

			if self.lastCasing == true and self.canEject == true then --Last casing to eject in the whole gun
				local casing = CreateMOSParticle("Casing Long")
				casing.Pos = self.Pos + Vector(-4 * self.FlipFactor, -1):RadRotate(self.RotAngle)
				casing.Vel = self.Vel
					+ Vector(-math.random(5, 7) * self.FlipFactor, -math.random(4, 6)):RadRotate(self.RotAngle)
				MovableMan:AddParticle(casing)
				self.lastCasing = false
				self.canEject = false
			end
		end

		self.reloadTimer:Reset()
		self.reloadCycle = true
		self.loadedShell = true
		if self.parent then
			self.parent:GetController():SetState(Controller.AIM_SHARP, false)
		end
	end

	if self:IsActivated() then
		if self.reloadCycle == false then --Please don't add the reload time if we need to fire.
			self.firstShell = true
			self.reloadOpenSound = true
			self.canEject = true
		end
		self.reloadCycle = false
	end

	if self.reloadCycle == true then
		self.reloadOpenTimer:Reset()
		self.reloadCloseSound = true
	end

	if self.reloadCycle == true and self.reloadTimer:IsPastSimMS(self.reloadDelay) and self:IsFull() == false then
		if self.parent then
			self:Reload()
		end
	end

	if self.magCount == self.magTotal then
		self.reloadCycle = false
		self.firstShell = true
		self.reloadOpenSound = true
		self.canEject = true
	end

	if self.magCount <= 0 then
		self.lastCasing = true
	else
		self.lastCasing = false
	end

	-- Lever action reload ends here --

	if self:IsAttached() == true then --I think this is more performance friendly as it doesn't check the parent every frame, rather just when the gun is first taken.
		if self.parent == nil then
			if IsAHuman(self:GetRootParent()) then
				self.parent = ToAHuman(self:GetRootParent())
			end
		end
	else
		self.parent = nil
	end

	if self.parent then
		if self.Magazine then
			self.magCount = self.Magazine.RoundCount

			if self.Magazine.RoundCount < self.lastAmmo and self.magCount > 0 then --We fired and it's not the last round.
				self.chamber = true
				self.pullTimer:Reset()
				self.num = math.pi
				self.casing = true
				self.reloadFullSound = true
			end

			self.lastAmmo = self.Magazine.RoundCount

			if self.Magazine.RoundCount == 0 and self:IsActivated() then
				self:Reload()
			end
		end

		if self.chamber == true then --Time to pull the lever
			if self.pullTimer:IsPastSimMS(15000 / self.RateOfFire) then
				if self.casing == true then
					casing = CreateMOSParticle("Casing Long")
					casing.Pos = self.Pos + Vector(-4 * self.FlipFactor, -1):RadRotate(self.RotAngle)
					casing.Vel = self.Vel
						+ Vector(-math.random(7, 9) * self.FlipFactor, -math.random(5, 7)):RadRotate(self.RotAngle)
					MovableMan:AddParticle(casing)

					self.casing = false
				end

				if self.reloadFullSound == true then
					AudioMan:PlaySound("Loyalists.rte/Devices/Weapons/Shared/Sounds/Chamber.flac", self.Pos)
					self.reloadFullSound = false
				end

				self.RotAngle = self.RotAngle + self.FlipFactor * math.sin(self.num) / 2 * self.angleSize

				self.num = self.num - math.pi * 0.0005 * self.RateOfFire
			end

			if self.num <= 0 then
				self.num = 0
				self.chamber = false
			end
		end
	end
end
