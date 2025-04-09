function Create(self)
	self.AngularVel = 0
	self.RotAngle = 0

	self.LTimer = Timer()
	self.LTimer:Reset()

	self.BTimer = Timer()
end

function Update(self)
	local terrcheck = Vector(0, 0)

	local groundray = SceneMan:CastStrengthRay(self.Pos, Vector(-30, 100), 0, terrcheck, 1, 0, true)
	local groundray2 = SceneMan:CastStrengthRay(self.Pos, Vector(30, 100), 0, terrcheck, 1, 0, true)
	if groundray == true and groundray2 == true then
		self.Vel.Y = self.Vel.Y * 0.95
		self.Vel.X = self.Vel.X * 0.85
		self.AngularVel = self.AngularVel * 0.95
	else
		self.AngularVel = 0
	end

	if self.BTimer:IsPastSimMS(90) then
		local randa = math.random(-25, 25)
		local randb = math.random(-100, 100)

		local sfx = CreateMOSRotating("Orkz Droppod Explosion")
		sfx.Pos = Vector(self.Pos.X + randa, self.Pos.Y + randb)
		sfx.Team = self.Team
		sfx.IgnoresTeamHits = true
		MovableMan:AddParticle(sfx)

		self.BTimer:Reset()
	end

	if self.LTimer:IsPastSimMS(3000) then
		self:GibThis()
	end
end
