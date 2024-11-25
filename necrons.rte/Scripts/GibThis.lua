function Create(self)
	self.LTimer = Timer()
	self.explodetime = math.random(375, 675)
end

function Update(self)
	if self.LTimer:IsPastSimMS(self.explodetime) then
		self:GibThis()
	end
end
