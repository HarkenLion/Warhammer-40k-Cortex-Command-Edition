dofile("Base.rte/Constants.lua")
dofile("necrons.rte/Scripts/AI/NativeNecronAI.lua")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.c = self:GetController()
	self.setalt = 25 --40; --58;
	self.timer = Timer()
end

function Update(self)
	--propulsion, stabilisation

	--if not self:IsDead() then

	local health = self.Health

	if health > 0 then
		if self.timer:IsPastSimMS(4000) and health < 100 then
			self.Health = health + 1
			self.timer = Timer()
		end

		if health > 100 then
			self.Health = 100
		end

		self.alt = self:GetAltitude(0, 1)

		if self.alt < self.setalt and self.Vel.Y > -10 then
			self.Vel.Y = self.Vel.Y - 0.5
		end

		local altitudes = 30
		if self.alt < altitudes then
			if self.Vel.Y < -3 then
				self.Vel.Y = self.Vel.Y + 0.15
			elseif self.Vel.Y > 3 then
				self.Vel.Y = self.Vel.Y - 0.15
			end
		end
		self.Vel.Y = 0.995 * self.Vel.Y

		if self.setalt < 135 and self.c:IsState(5) then
			self.setalt = self.setalt + 1
		elseif self.setalt > 25 and self.c:IsState(6) then
			self.setalt = self.setalt - 1
		end

		self.AngularVel = 0.95 * self.AngularVel

		self.RotAngle = 0

		if self.Vel.X < 25 and self.c:IsState(3) then
			self.Vel.X = self.Vel.X + (math.cos(self.RotAngle) * 0.1)
			self.Vel.Y = self.Vel.Y - (math.sin(self.RotAngle) * 0.1)
		elseif self.Vel.X > -25 and self.c:IsState(4) then
			self.Vel.X = self.Vel.X - (math.cos(self.RotAngle) * 0.1)
			self.Vel.Y = self.Vel.Y + (math.sin(self.RotAngle) * 0.1)
		else
			self.Vel.X = self.Vel.X * 0.80
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
