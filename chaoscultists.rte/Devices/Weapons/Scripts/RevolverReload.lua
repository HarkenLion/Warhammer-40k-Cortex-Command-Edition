---------------------------------------------------------------------------------------------
-------------- Angle stuff definetley stolen from 4zK xD ----------------------------------
---------------------------------------------------------------------------------------------

function Create(self)
	self.reloadTimer = Timer()
	self.loadedShell = false
	self.reloadCycle = false
	self.casing = false

	self.reloadDelay = 125 --Time between each reload. Dosen'r teally matter to the player as smashing "R" completley undermines it

	self.parent = nil

	self.reloadAngleSize = 0.2 --Change this if you feel the gun rotates a bit too much or too litle

	self.origReloadTime = self.BaseReloadTime
	self.firstShell = true
	self.firstShellDelay = 1.8 --How much is the reload time multiplied by for the first shell
	self.reloadNum = 0

	if self.Magazine then
		self.magCount = self.Magazine.RoundCount
		self.magTotal = self.Magazine.RoundCount
	end

	self.hasReloaded = false
	self.ammoCounter = self.Magazine.Capacity
end

function Update(self)
	if self:IsReloading() then
		self.hasReloaded = true
	end

	if self.hasReloaded == true and self.Magazine ~= nil then
		--		self.ammoCounter = self.Magazine.Capacity				This is a shotgun reload, so this part is somewhere below and added 1 by 1
		self.hasReloaded = false
	else
		if self.FiredFrame then
			self.ammoCounter = self.ammoCounter - 1
		end
	end

	-- shotgun reload starts here --
	if self.firstShell == true and self.reloadCycle == false then --First shell in? between the movement and such it takes a bit more
		self.BaseReloadTime = self.origReloadTime * self.firstShellDelay --Change if you want the first one to be way slwoer
	elseif self.firstShell == false then
		self.BaseReloadTime = self.origReloadTime --Change if you want the subsequent shells/bullets be slower/quicker
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
			self.ammoCounter = self.ammoCounter + 1
			self.Magazine.RoundCount = self.ammoCounter
			self.firstShell = false

			--Casing Stuff--

			if self.casing == true then
				casing = CreateMOSParticle("Casing Brass")
				casing.Pos = self.Pos + Vector(-4 * self.FlipFactor, -1):RadRotate(self.RotAngle)
				casing.Vel = self.Vel
					+ Vector(-math.random(3, 5) * self.FlipFactor, -math.random(0, 0)):RadRotate(self.RotAngle)
				MovableMan:AddParticle(casing)

				self.casing = false
			end
		end
	else
		self.reloadTimer:Reset()
		self.reloadCycle = true
		self.loadedShell = true
		self.casing = true
		if self.parent then
			self.parent:GetController():SetState(Controller.AIM_SHARP, false)
		end
	end

	if self:IsActivated() then
		if self.reloadCycle == false then --Please don't add the reload time if we need to fire.
			self.firstShell = true
		end
		self.reloadCycle = false
	end

	if self.reloadCycle == true and self.reloadTimer:IsPastSimMS(self.reloadDelay) and self:IsFull() == false then
		if self.parent then
			self:Reload()
		end
	end

	if self.magCount == self.magTotal then
		self.reloadCycle = false
		self.firstShell = true
	end

	-- shotgun reload ends here --

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
		end
	end
end
