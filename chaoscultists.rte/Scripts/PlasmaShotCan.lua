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
	while i < 6 do
		local e = CreateMOPixel("PlasC Shot glow")
		e.Vel = self.Vel
		e.Pos = self.Pos - (checkVect * 0.25 * i)
		e.Team = self.Team
		e.IgnoresTeamHits = true
		MovableMan:AddMO(e)
		i = i + 1
	end
	if self.ToDelete == true then
		local e = CreateMOSParticle("Plasma Burst A", "spacemarines.rte")
		local rand = math.random(-4, 4)
		if rand > 2 then
			e = CreateMOSParticle("Plasma Burst B", "spacemarines.rte")
		end
		if rand < -2 then
			e = CreateMOSParticle("Plasma Burst C", "spacemarines.rte")
		end
		e.Pos = self.Pos + checkVect
		e.Frame = math.random(0, 4)
		MovableMan:AddMO(e)
	end
end
