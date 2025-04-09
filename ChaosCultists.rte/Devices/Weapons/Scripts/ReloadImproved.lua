---------------------------------------------------------------------------------------------
-------------- Angle stuff definetley stolen from 4zK xD ----------------------------------
-------------- Standalone-er version for all your non-shotguns needs ----------------------
---------------------------------------------------------------------------------------------

function Create(self)
	self.parent = nil

	self.reloadAngleSize = 0.25 --Change this if you feel the gun rotates a bit too much or too litle

	self.origReloadTime = self.BaseReloadTime
	self.reloadNum = 0
end

function Update(self)
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
		if self:IsReloading() then --Yo we reloading, better grab my weapon better
			if self.reloadNum < 1 then
				self.reloadNum = self.reloadNum + 1 / self.Mass
			elseif self.reloadNum >= 1 then
				self.reloadNum = 1
			end
		else --Let's get back into it
			if self.reloadNum > 0 then
				self.reloadNum = self.reloadNum - 1 / self.Mass
			elseif self.reloadNum <= 0 then
				self.reloadNum = 0
			end
		end
		self.InheritedRotAngleOffset = self.reloadNum * self.reloadAngleSize --The numbers above affect the rotation operation here
	else
		self.reloadNum = 0
	end
end
