function Create(self)
	self.adjustTimer = Timer()
end

function Update(self)
	if self.Frame ~= 4 then
		self.Frame = self.Frame + 1
	else
		self.ToDelete = true
	end

	self.adjustTimer:Reset()
end
