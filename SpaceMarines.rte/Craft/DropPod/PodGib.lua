function Create(self)

self.AngularVel = 0;
self.RotAngle = 0;
self.ToSettle = true;

	self.Vel.X = 0;
	self.Vel.Y = 0;

end


function Update(self)
	self.ToSettle = true;
end
