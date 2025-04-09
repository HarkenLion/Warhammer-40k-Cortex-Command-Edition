function Create(self)
	self.muzzleSmokeSize = self:NumberValueExists("MuzzleSmokeSize") and self:GetNumberValue("MuzzleSmokeSize") or self.Mass * 1;

	self.muzzleSmokeCountMax = self.muzzleSmokeSize;
	self.muzzleSmokeCountMin = math.ceil(self.muzzleSmokeCountMax * 0.5);
	self.muzzleSmokeVel = math.sqrt(self.muzzleSmokeSize) * 5;
	self.muzzleSmokeSpread = math.rad((self.ShakeRange + self.SharpShakeRange) * 0.5 + (self.muzzleSmokeVel + self.ParticleSpreadRange) * 0.5);
	
	--дымок
	self.FireTimer = Timer();
	self.angVel = 0
	self.smokeDelayTimer = Timer();
end

function OnFire(self)
	local smokeCount = math.random(self.muzzleSmokeCountMin, self.muzzleSmokeCountMax);

	for i = 1, smokeCount do
		local smoke = CreateMOSParticle("Tiny Smoke Trail " .. math.random(3));
		smoke.Pos = self.MuzzlePos;
		smoke.AirResistance = smoke.AirResistance * RangeRand(0.5, 1.0);
		smoke.Vel = Vector(i/smokeCount * self.muzzleSmokeVel * self.FlipFactor, 0):RadRotate(self.RotAngle + self.muzzleSmokeSpread * RangeRand(-1, 1));
		MovableMan:AddParticle(smoke);
	end
end

function ThreadedUpdate(self)--function Update(self)

	---дымок
	if self.FiredFrame then
		
		self.horizontalAnim = 30
	
		self.FireTimer:Reset();
	
		self.angVel = self.angVel - RangeRand(0.7,1.1) * 3
		
		self.canSmoke = true
		
		if self.RoundInMagCount > 0 then
		else
			self.chamberOnReload = true;
		end
		
		for i = 1, 2 do
			local Effect = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte")
			if Effect then
				Effect.Pos = self.MuzzlePos;
				Effect.Vel = (self.Vel + Vector(RangeRand(-20,20), RangeRand(-20,20)) + Vector(150*self.FlipFactor,0):RadRotate(self.RotAngle)) / 30
				MovableMan:AddParticle(Effect)
			end
		end
		
	end

	if self.canSmoke and not self.FireTimer:IsPastSimMS(1500) then

		if self.smokeDelayTimer:IsPastSimMS(120) then
			
			local poof = CreateMOSParticle("Tiny Smoke Ball 1 Glow Yellow");
			poof.Pos = self.Pos + Vector(self.MuzzleOffset.X * self.FlipFactor, self.MuzzleOffset.Y):RadRotate(self.RotAngle);
			poof.Lifetime = poof.Lifetime * RangeRand(0.3, 1.3) * 0.9;
			poof.Vel = self.Vel * 0.1
			poof.GlobalAccScalar = RangeRand(0.9, 1.0) * -0.4; -- Go up and down
			MovableMan:AddParticle(poof);
			self.smokeDelayTimer:Reset()
		end
	end
end