function Create(self)
	self.timer = Timer()
	self.AIMode = Actor.AIMODE_BRAINHUNT
end

function Update(self)
	if self.timer:IsPastSimMS(4000) and self.Health < 100 then
		self.Health = self.Health + 1
		self.timer = Timer()
	end
end
