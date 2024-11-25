function Create(self)
	self.parent = nil
end

function Update(self)
	if self.Magazine == nil then
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
end
