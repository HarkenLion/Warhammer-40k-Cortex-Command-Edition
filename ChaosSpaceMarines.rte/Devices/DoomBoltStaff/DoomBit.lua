function Create(self)
	if not self.var then
		local var = {};

		var.target = nil;
		var.accDir = self.Vel * -1;
		var.theta = math.random() * 2 * math.pi;
		var.insanityVector = Vector(1, 0):RadRotate(math.random() * 2 * math.pi);
		var.insanityTicker = 0;
		var.insanityRotVel = (1 + math.random()) * (math.random(0, 1) == 1 and 1 or -1)

		self.var = var;
		
		self.Vel = self.Vel + self.Vel.Perpendicular.Normalized * 3 * math.cos(var.theta);
	end
end

function Update(self)
	local var = self.var;

	self.Vel = self.Vel + (var.accDir):SetMagnitude(0.25);
	var.insanityVector = var.insanityVector:GetRadRotatedCopy(2 * math.pi / 60 * var.insanityRotVel);
	self.Pos = self.Pos + var.insanityVector * 4 * math.min((var.insanityTicker / 20) ^ 2, (20 / var.insanityTicker) ^ 2);
	var.insanityTicker = var.insanityTicker + 1;

	self.EffectRotAngle = self.Vel.AbsRadAngle + math.pi;
end
