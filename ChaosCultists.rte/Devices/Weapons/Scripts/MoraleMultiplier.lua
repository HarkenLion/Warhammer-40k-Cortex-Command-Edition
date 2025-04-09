---------------------------------------------------------------------------------------------
------------------------------- Weapon's Morale Improvement --------------------------------
---------------------------------------------------------------------------------------------

--[[
function Create(self)

	--Beta version. Affected guns are all one handed as right now it requires the flag to be held.
	--Heck, the proper version might, emphasis on might, affect all guns, making this script obsolete

	self.origSharpLength = ToHDFirearm(self).SharpLength;
	self.origShakeRange = ToHDFirearm(self).ShakeRange;
	self.origSharpShakeRange = ToHDFirearm(self).SharpShakeRange;
	self.origReloadTime = ToHDFirearm(self).ReloadTime;

	-- Multiply by the Morale value and add/ subtract to the property (Morale = 2 then Sharplength = Orig + Orig*0.15*2
	self.sharpLengthMultiplier = 0.15
	self.shakeRangeMultiplier = 0.15
	self.sharpShakeRangeMultiplier = 0.2
	
	self.parent = nil;
	self.armParent = nil;

end

function Update(self)

	if self:IsAttached() == true then 		--Since the arm could get dettached without destroying the body, this makes sure that either way there isn't a nonexistant parent to get NumValues from
		if self.armParent == nil then
			if IsAttachable(self:GetParent()) then
				self.armParent = ToAttachable(self:GetParent())
			end
		else
			if self.armParent:IsAttached() then
				if self.parent == nil then
					if IsAHuman(self:GetRootParent()) then
						self.parent = ToAHuman(self:GetRootParent())
					end
				end
			else
				self.parent = nil;
			end
		end
	else
		self.parent = nil;
		self.armParent = nil;
	end

	if self.parent then
		if self.parent:NumberValueExists("Morale Value") then

			local morale = self.parent:GetNumberValue("Morale Value")
	
			if self:IsAttached() then	--Don't think will reach negatives as of planned right now, morale is capped at around 5 or 6, which is just on the border of negative land
				self.SharpLength = self.origSharpLength + (self.origSharpLength*self.sharpLengthMultiplier*morale);
				self.ShakeRange = self.origShakeRange - (self.origShakeRange*self.shakeRangeMultiplier*morale);
				self.SharpShakeRange = self.origSharpShakeRange - (self.origSharpShakeRange*self.sharpShakeRangeMultiplier*morale);
			else
				self.SharpLength = self.origSharpLength;
				self.ShakeRange = self.origShakeRange;
				self.SharpShakeRange = self.origSharpShakeRange;
			end
		end
	end
end
--]]
