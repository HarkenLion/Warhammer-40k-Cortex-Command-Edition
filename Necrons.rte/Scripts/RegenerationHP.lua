function Create(self)
	self.timer = Timer()
	self.AIMode = Actor.AIMODE_BRAINHUNT
end

function Update(self)
	local health = self.Health
	if self.timer:IsPastSimMS(4000) and health < 100 then
		self.Health = health + 1
		self.timer = Timer()
	end

	if health > 100 then
		self.Health = 100
	end
end
