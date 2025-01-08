function Create(self)
	self.LTimer = Timer()
end

function Update(self)
	self.Vel.X = 0
	self.Vel.Y = 0

	if not self.LTimer:IsPastSimMS(250) or self.RotAngle < 1.2 then
		if self.AngularVel < 0 then
			self.AngularVel = 12
		end
	else
		self.ToSettle = true
	end
end
