function Create(self)
	self.Scale = 1.1
end

function Update(self)
	self.Scale = 1.1
	if self.LTimer:IsPastSimMS(self.explodetime) then
		self:GibThis()
	end
end
