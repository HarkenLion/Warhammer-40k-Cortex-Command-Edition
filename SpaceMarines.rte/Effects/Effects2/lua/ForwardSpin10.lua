function Create(self)
	self.negativeNum = 0
end

function Update(self)
	if self.HFlipped == false then
		self.negativeNum = -1
	else
		self.negativeNum = 1
	end
	self.AngularVel = math.random(10 * self.negativeNum)
end
