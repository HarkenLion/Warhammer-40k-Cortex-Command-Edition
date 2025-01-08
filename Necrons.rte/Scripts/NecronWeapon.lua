function Create(self)
	local actor = MovableMan:GetMOFromID(self.RootID)
	if MovableMan:IsActor(actor) then
		self.parent = ToActor(actor)
	end
end

function Update(self)
	if not self.parent then
		local actor = MovableMan:GetMOFromID(self.RootID)
		if MovableMan:IsActor(actor) then
			self.parent = ToActor(actor)
		end

		self.GetsHitByMOs = true
	else
		self.GetsHitByMOs = false
	end
end
