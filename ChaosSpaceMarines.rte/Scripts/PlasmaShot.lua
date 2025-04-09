function Create(self) end

function OnCollideWithTerrain(self)
	self:GibThis()
end

function OnCollideWithMO(self)
	self:GibThis()
end

function Update(self)
	local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
	local checkVect = self.Vel * velFactor
	local i = 0
	while i < 4 do
		local e = CreateMOPixel("Plas Shot glowC")
		e.Vel = self.Vel
		e.Pos = self.Pos - (checkVect * 0.45 * i)
		e.Team = self.Team
		e.IgnoresTeamHits = true
		MovableMan:AddMO(e)
		i = i + 1
	end
	if self.ToDelete == true then
		local e = CreateMOSParticle("Plasma Burst A", "ChaosSpaceMarines.rte")
		local rand = math.random(-4, 4)
		if rand > 2 then
			e = CreateMOSParticle("Plasma Burst B", "ChaosSpaceMarines.rte")
		end
		if rand < -2 then
			e = CreateMOSParticle("Plasma Burst C", "ChaosSpaceMarines.rte")
		end
		e.Pos = self.Pos + checkVect
		e.Scale = 0.75
		e.Frame = math.random(0, 4)
		MovableMan:AddMO(e)
	end
end
