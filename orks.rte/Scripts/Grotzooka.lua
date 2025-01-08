function Create(self)
	self.Scale = 0.9
end

function update(self)
	if self.HFlipped == true then
		self.RotAngle = self.RotAngle + 0.1
	else
		self.RotAngle = self.RotAngle - 0.1
	end
end
