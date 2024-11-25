function Create(self)
	self.strength = 45    
end

function OnCollideWithMO(self)
	self.ToDelete = true;
end

function Update(self)
	if self.ToDelete == true or self.ToSettle == true then
		local e = CreateMOSParticle("Bolter Shell Burst A")
		local rand = math.random(-4,4)
		if rand > 2 then e = CreateMOSParticle("Bolter Shell Burst E") end
		if rand > 3 then e = CreateMOSParticle("Bolter Shell Burst B") end
		if rand < -2 then e = CreateMOSParticle("Bolter Shell Burst D") end
		if rand < -3 then e = CreateMOSParticle("Bolter Shell Burst C") end
		e.Pos =  self.Pos
		e.Frame = math.random(0,4)
		MovableMan:AddMO(e)


		local velFactor = GetPPM() * TimerMan.DeltaTimeSecs;
		local checkVect = self.Vel * velFactor;

		local e = CreateAEmitter("Bolt HellFire Shell Explosion","spacemarines.rte"); --CreateMOSParticle("Small Smoke Ball 1");
		e.Pos = self.Pos + (checkVect * 0.6);
		e.Team = self.Team
		MovableMan:AddMO(e);
	else
		if self.Vel.Magnitude < 150 then
			self.Vel.X = self.Vel.X * 1.05;
			self.Vel.Y = self.Vel.Y * 1.05;
		end
	
		local posa = self.Pos-self.Vel*0.03
		local posb = self.Pos-self.Vel*0.2
		local posc = self.Pos - self.Vel*0.1
		PrimitiveMan:DrawLinePrimitive(posa,posb,86,2)
		PrimitiveMan:DrawLinePrimitive(posa,posc,117,1)
	end
end