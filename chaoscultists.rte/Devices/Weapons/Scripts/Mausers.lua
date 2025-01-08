---------------------------------------------------------------------------------------------
----------------------- Mauser animation + reload animation --------------------------------
---------------------------------------------------------------------------------------------

function Create(self)
	--Animation stuff--

	self.Frame = 0
	self.animTimer = Timer()
	self.canAnim = true
	self.fullyEmpty = false

	self.animDelay = 35

	--Reload Stuff--

	self.parent = nil

	self.reloadAngleSize = 0.2 --Change this if you feel the gun rotates a bit too much or too litle

	self.origReloadTime = self.BaseReloadTime
	self.reloadNum = 0

	self.reloading = false
end

function Update(self)
	--Mauser animation Stuff--

	if self.Magazine then
		if self.FiredFrame and self.Magazine.RoundCount > 0 then
			self.Frame = 1 --Fired then change frame
			if self.canAnim == true then
				self.animTimer:Reset() --Timer delay to change back to original frame
				self.canAnim = false
			end
		elseif self.Magazine.RoundCount == 0 then --Fully empty frame change
			self.Frame = 2
		end
		if self.animTimer:IsPastSimMS(self.animDelay) then
			self.canAnim = true
			self.Frame = 0
		end

		if self.Magazine.RoundCount < 1 then
			self.fullyEmpty = true
		else
			self.fullyEmpty = false
		end
	else
		self.animTimer:Reset()
		if self.fullyEmpty == true then --Making sure we are completley empry
			self.Frame = 2
		end
	end

	--Reload Stuff--

	if self.Magazine ~= nil then
		self.reloading = false
	else
		self.reloading = true
		if self.parent then
			self.parent:GetController():SetState(Controller.AIM_SHARP, false)
		end
	end

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
		if self.reloading == true then --Yo we reloading, better grab my weapon better
			if self.reloadNum < 1 then
				self.reloadNum = self.reloadNum + 1 / self.Mass
			elseif self.reloadNum > 1 then
				self.reloadNum = 1
			end
		elseif self.reloading == false then --Let's get back into it
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
end
