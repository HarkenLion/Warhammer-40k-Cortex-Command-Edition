function Create(self)
	self.Scale = 0.4
end

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
	while i < 3 do
		local e = CreateMOPixel("Melta Shot Glow A", "chaosspacemarines.rte")
		local rand = math.random(-4, 4)
		if rand > 3 then
			e = CreateMOPixel("Melta Shot Glow B", "chaosspacemarines.rte")
		end
		if rand > 2 then
			e = CreateMOPixel("Melta Shot Glow C", "chaosspacemarines.rte")
		end
		if rand < -2 then
			e = CreateMOPixel("Melta Shot Glow D", "chaosspacemarines.rte")
		end
		if rand < -3 then
			e = CreateMOPixel("Melta Shot Glow E", "chaosspacemarines.rte")
		end
		e.Vel = self.Vel
		e.Pos = self.Pos - (checkVect * 0.25 * i)
		e.Team = self.Team
		MovableMan:AddMO(e)
		i = i + 1
	end
	if self.ToDelete == true then
		local e = CreateMOSParticle("Melta Burst A", "chaosspacemarines.rte")
		local rand = math.random(-4, 4)
		if rand > 2 then
			e = CreateMOSParticle("Melta Burst B", "chaosspacemarines.rte")
		end
		if rand < -2 then
			e = CreateMOSParticle("Melta Burst C", "chaosspacemarines.rte")
		end
		e.Pos = self.Pos + checkVect
		e.Frame = math.random(0, 4)
		e.Scale = 0.65
		MovableMan:AddMO(e)
	end
end
