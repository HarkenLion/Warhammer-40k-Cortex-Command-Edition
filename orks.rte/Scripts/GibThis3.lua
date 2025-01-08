function Create(self)
	self.LTimer = Timer()
	self.explodetime = math.random(50, 875)
	self.AngularVel = math.random(-2, 2)
end

function Update(self)
	if self.LTimer:IsPastSimMS(self.explodetime) then
		self:GibThis()
	end
end
