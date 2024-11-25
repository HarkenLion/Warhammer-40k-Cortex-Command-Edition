function Create(self)
	if not self.var then
		local var = {};

		var.target = nil;
		var.accDir = self.Vel * 1;
		var.theta = math.random() * 2 * math.pi;
		var.insanityVector = Vector(1, 0):RadRotate(math.random() * 2 * math.pi);
		var.insanityTicker = 0;
		var.insanityRotVel = (1 + math.random()) * (math.random(0, 1) == 1 and 1 or -1)

		var.smokeTrailLifeTime = 150;
		var.smokeTrailSize = 4;
		var.smokeTrailRadius = 4;
		var.smokeTrailTwirl = 7;
		var.smokeAirThreshold = 5/(1 + var.smokeTrailLifeTime * 0.01);
		var.smokeTwirlCounter = math.random() < 0.5 and math.pi or 0;

		self.var = var;
		
		self.Vel = self.Vel + self.Vel.Perpendicular.Normalized * math.cos(var.theta);
	end
end

function shortestRotation(a01, a02)
	return (a02.AbsRadAngle - a01.AbsRadAngle + math.pi) % (2 * math.pi) - math.pi;
end

function Update(self)
	local var = self.var;
	
	if not var.target then
		for i = 1, 10 do
			local ray = var.accDir:GetRadRotatedCopy((math.random() - 0.5) * 0.3):SetMagnitude(500);
			--PrimitiveMan:DrawLinePrimitive(self.Pos, self.Pos + ray, 120, 1);
			local moid = SceneMan:CastMORay(self.Pos * 1, ray, self.ID, self.Team, 0, false, 0);
			local movableTarget = MovableMan:GetMOFromID(moid);
		
			if movableTarget then
				local movableRoot = movableTarget:GetRootParent();

				if IsActor(movableRoot) and not ToActor(movableRoot):IsDead() and not IsADoor(movableRoot) then
					var.target = ToActor(movableRoot);
					break;
				end
			end
		end
	end

	if var.target then
		local real = MovableMan:ValidMO(var.target) and not var.target:IsDead();
		local targetTract;

		if real then
			targetTract = SceneMan:ShortestDistance(self.Pos, var.target.Pos, true);

			if (self.Pos - var.target.Pos).Magnitude < var.target.Radius then
				self:GibThis();
			end
			
			self.Vel = self.Vel * (0.950 + self.Vel.Normalized:Dot(targetTract.Normalized) / 20) + targetTract:CapMagnitude(1);
		end

		-- If target tract wasn't defined we definitely have no target, but we can still lose it otherwise
		if not targetTract or self.Vel.Normalized:Dot(targetTract.Normalized) > -0.707 then
			var.target = nil;
			var.accDir = self.Vel * 1;
		end
	end

	if not MovableMan:ValidMO(var.target) then
		self.Vel = self.Vel * 0.98 + (var.accDir):SetMagnitude(0.8);
		var.insanityVector = var.insanityVector:GetRadRotatedCopy(2 * math.pi / 60 * var.insanityRotVel);
		self.Pos = self.Pos + var.insanityVector * 4 * math.min(var.insanityTicker / 30, (30 / var.insanityTicker) ^ 1);
		var.insanityTicker = var.insanityTicker + 1;
	end

	local offset = self.Vel * rte.PxTravelledPerFrame;	--The effect will be created the next frame so move it one frame backwards towards the barrel

	local trailLength = 10;
	local setVel = Vector(self.Vel.X, self.Vel.Y):SetMagnitude(math.sqrt(self.Vel.Magnitude));
	for i = 1, trailLength do
		local effect = CreateMOSParticle("Black Smoke Trail " .. math.random(3), "chaosspacemarines.rte");
		effect.Pos = self.Pos - (offset * i/trailLength) + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * var.smokeTrailRadius * var.smokeTrailRadius * 3;
		effect.Vel = setVel * RangeRand(0.6, 1) + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * var.smokeTrailRadius * 3;
		effect.Lifetime = math.max(var.smokeTrailLifeTime * RangeRand(0.4, 1) * (self.Lifetime > 1 and 1 - self.Age/self.Lifetime or 1), 1);
		effect.AirResistance = effect.AirResistance * RangeRand(0.8, 1);
		effect.AirThreshold = var.smokeAirThreshold;

		if var.smokeTrailTwirl > 0 then
			effect.GlobalAccScalar = effect.GlobalAccScalar * math.random();

			effect.Pos = self.Pos - offset + (offset * i/trailLength) + Vector(RangeRand(-1, 1), RangeRand(-1, 1)) * var.smokeTrailRadius;
			effect.Vel = setVel + Vector(0, math.sin(var.smokeTwirlCounter) * var.smokeTrailTwirl + RangeRand(-0.1, 0.1)):RadRotate(self.Vel.AbsRadAngle);

			var.smokeTwirlCounter = var.smokeTwirlCounter + RangeRand(-0.2, 0.4);
		end
		
		MovableMan:AddParticle(effect);
	end
	
	local e = CreateMOPixel("Plas Shot glowC");
	e.Vel = (self.Vel * 0.9):GetRadRotatedCopy(math.random() - 0.5);
	e.Pos = self.Pos;
	e.Team = self.Team;
	e.IgnoresTeamHits = true;
	MovableMan:AddMO(e);

	self.EffectRotAngle = self.Vel.AbsRadAngle;
end
