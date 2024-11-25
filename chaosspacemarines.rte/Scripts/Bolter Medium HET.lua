function Create(self)
	self.strength = 45
end

function Update(self)
	if self.ToDelete == true or self.ToSettle == true then
		local e = CreateMOSParticle("Bolter Shell Burst A")
		local rand = math.random(-4, 4)
		if rand > 2 then
			e = CreateMOSParticle("Bolter Shell Burst E")
		end
		if rand > 3 then
			e = CreateMOSParticle("Bolter Shell Burst B")
		end
		if rand < -2 then
			e = CreateMOSParticle("Bolter Shell Burst D")
		end
		if rand < -3 then
			e = CreateMOSParticle("Bolter Shell Burst C")
		end
		e.Pos = self.Pos
		e.Frame = math.random(0, 4)
		MovableMan:AddMO(e)

		for mo in MovableMan:GetMOsInRadius(self.Pos, 25, self.Team) do
			if mo.PinStrength == 0 then
				local dist = SceneMan:ShortestDistance(self.Pos, mo.Pos, SceneMan.SceneWrapsX)
				local massFactor = math.sqrt(1 + math.abs(mo.Mass))
				local distFactor = 4 + dist.Magnitude * 0.1
				local forceVector = dist:SetMagnitude(self.strength / distFactor)
				if IsAttachable(mo) then
					--Diminish transferred impulses from attachables since we are likely already targeting its' parent
					forceVector = forceVector * math.abs(1 - ToAttachable(mo).JointStiffness)
				end
				mo.Vel = mo.Vel + forceVector / massFactor
				mo.AngularVel = mo.AngularVel - forceVector.X / (massFactor + math.abs(mo.AngularVel))
				mo:AddImpulseForce(forceVector * massFactor, Vector())
				--Add some additional points of damage to actors
				if IsActor(mo) then
					local actor = ToActor(mo)
					local impulse = (forceVector.Magnitude * self.strength / massFactor) - actor.ImpulseDamageThreshold
					local damage = impulse / (actor.GibImpulseLimit * 0.1 + actor.Material.StructuralIntegrity * 10)
					actor.Health = damage > 0 and actor.Health - damage or actor.Health
					actor.Status = (actor.Status == Actor.STABLE and damage > (actor.Health * 0.7)) and Actor.UNSTABLE
						or actor.Status
				end
			end
		end

		local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
		local checkVect = self.Vel * velFactor

		local e = CreateAEmitter("Bolt Shell Explosion", "chaosspacemarines.rte") --CreateMOSParticle("Small Smoke Ball 1");
		e.Pos = self.Pos + (checkVect * 0.6)
		e.Team = self.Team
		MovableMan:AddMO(e)
	else
		if self.Vel.Magnitude < 150 then
			self.Vel.X = self.Vel.X * 1.05
			self.Vel.Y = self.Vel.Y * 1.05
		end

		local posa = self.Pos - self.Vel * 0.03
		local posb = self.Pos - self.Vel * 0.2
		local posc = self.Pos - self.Vel * 0.1
		PrimitiveMan:DrawLinePrimitive(posa, posb, 86, 2)
		PrimitiveMan:DrawLinePrimitive(posa, posc, 117, 1)
	end
end
