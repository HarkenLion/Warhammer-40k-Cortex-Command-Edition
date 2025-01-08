function Create(self)

self.AngularVel = 0;
self.RotAngle = 0;

self.LTimer = Timer();
self.LTimer:Reset();

end


function Update(self)

self.AngularVel = 0;
self.RotAngle = 0;

		local terrcheck = Vector(0,0);

		local groundray = SceneMan:CastStrengthRay(self.Pos,Vector(-30,33),0,terrcheck,1,0,true);
		local groundray2 = SceneMan:CastStrengthRay(self.Pos,Vector(30,33),0,terrcheck,1,0,true);
		if groundray == true and groundray2 == true then
				self.Vel.Y = 0;
				self.Vel.X = 0;
		end

if self.LTimer:IsPastSimMS(3000) then
	self:GibThis();
end


end