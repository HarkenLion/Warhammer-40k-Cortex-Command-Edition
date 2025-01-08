dofile("Base.rte/Constants.lua")
require("AI/NativeCrabAI") --dofile("Base.rte/AI/NativeCrabAI.lua")

function Create(self)
	self.AI = NativeCrabAI:Create(self)
	self.explode = false

	self.WTime = Timer()
end

function Update(self)
	self.AngularVel = self.AngularVel * 0.85

	if self.Health < 0 and self.explode == false then
		local terrcheck = Vector(0, 0)

		local ray = SceneMan:CastStrengthRay(self.Pos, Vector(0, 35), 0, terrcheck, 1, 0, true)

		if ray == true then
			local randa = math.random(-15, 15)
			local randb = math.random(-15, 15)

			local sfx = CreateMOSRotating("Chaos Explosion")
			sfx.Pos = Vector(self.Pos.X + randa, self.Pos.Y + randb)
			sfx.Team = self.Team
			sfx.IgnoresTeamHits = true
			MovableMan:AddParticle(sfx)
			self.explode = true
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
