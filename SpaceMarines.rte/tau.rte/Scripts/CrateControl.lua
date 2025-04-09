function Create(self)
	self.enableselect = true
end

function Update(self)
	self:MoveOutOfTerrain(1)

	if self:IsPlayerControlled() == true then
		if self.enableselect == true then
			self.selected = CreateAEmitter("Tau Crate Select")
			self.selected.Pos = self.Pos
			self.selected.PinStrength = 1000
			MovableMan:AddParticle(self.selected)
			self.enableselect = false
		end
	else
		self.enableselect = true
	end
end
