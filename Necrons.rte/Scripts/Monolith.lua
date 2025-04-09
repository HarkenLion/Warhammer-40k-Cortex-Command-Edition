dofile("Base.rte/Constants.lua")
require("AI/NativeCrabAI") --dofile("Base.rte/AI/NativeCrabAI.lua")

function Create(self)
	self.c = self:GetController()
	self.setalt = 75 --58;

	self.StaticTimer = Timer()
	self.statictime = 250
	self.AI = NativeCrabAI:Create(self)
end

function Update(self)
	--propulsion, stabilisation

	self.alt = self:GetAltitude(0, 1)

	if self.alt < self.setalt and self.Vel.Y > -10 then
		self.Vel.Y = self.Vel.Y - 0.5
	end

	if self.Vel.Y < -3 then
		self.Vel.Y = self.Vel.Y + 0.15
	elseif self.Vel.Y > 3 then
		self.Vel.Y = self.Vel.Y - 0.15
	end
	self.Vel.Y = 0.985 * self.Vel.Y

	self.AngularVel = 0.95 * self.AngularVel

	self.RotAngle = 0

	if self.Vel.X < 3 and self.c:IsState(3) then
		self.Vel.X = self.Vel.X + (math.cos(self.RotAngle) * 0.1)
		self.Vel.Y = self.Vel.Y - (math.sin(self.RotAngle) * 0.1)
	elseif self.Vel.X > -3 and self.c:IsState(4) then
		self.Vel.X = self.Vel.X - (math.cos(self.RotAngle) * 0.1)
		self.Vel.Y = self.Vel.Y + (math.sin(self.RotAngle) * 0.1)
	else
		self.Vel.X = self.Vel.X * 0.80
	end

	if self.setalt < 125 and self.c:IsState(5) then
		self.setalt = self.setalt + 0.75
	elseif self.setalt > 25 and self.c:IsState(6) then
		self.setalt = self.setalt - 0.75
	end

	if self.Health < 35 and self.StaticTimer:IsPastSimMS(self.statictime) then
		self.StaticTimer:Reset()
		local rand = math.random(-70, 70)
		local rand2 = math.random(-5, 85)

		local chain7 = CreateMOPixel("Gauss Lightning Static Particle")
		chain7.Pos.X = self.Pos.X + rand
		chain7.Pos.Y = self.Pos.Y + rand2
		chain7.Vel = self.Vel
		MovableMan:AddParticle(chain7)

		local soundfx = CreateAEmitter("Lightning Impact")
		soundfx.Pos = chain7.Pos
		MovableMan:AddParticle(soundfx)

		self.statictime = math.abs(self.Health) * 5
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
