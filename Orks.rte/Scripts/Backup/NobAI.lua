dofile("Base.rte/Constants.lua")
dofile("Orks.rte/Scripts/AI/NativeNobAI.lua")

function Create(self)
	self.AI = NativeNobAI:Create(self)
	self.c = self:GetController()
	self.WTime = Timer()
end
function Update(self)
	self.c:SetState(9, false)

	if self.c:IsState(3) or self.c:IsState(4) or self.c:IsState(10) or self.c:IsState(5) then
		if self.WTime:IsPastSimMS(60) then
			self.WTime:Reset()

			local rotangle = self.RotAngle
			if rotangle > -0.15 and rotangle < 0.15 then
				if self.FGLeg ~= nil and self.BGLeg ~= nil then
					if self.c:IsState(3) or self.c:IsState(4) then
						self.alt = 25
					else
						self.alt = 23
					end

					local dx = 0

					if SceneMan.SceneWidth > self.Pos.X + 12 and 0 < self.Pos.X - 12 then
						dx = 12
						if self.Vel.X < 0 then
							dx = -12
						end
						if math.abs(self.Vel.X) < 1 then
							dx = 0
						end
					else
						dx = 0
					end

					if not self.c:IsState(10) and not self.c:IsState(5) and self.Health > 0 then
						local terrcheck = Vector(0, 0)
						local groundray = SceneMan:CastStrengthRay(self.Pos, Vector(0, 28), 1, terrcheck, 1, 1, true)
						if groundray == true then
							if math.abs(self.Vel.Y) < 5 then
								local ray = SceneMan:CastObstacleRay(
									Vector(self.Pos.X + dx, self.Pos.Y),
									Vector(0, self.alt * 1.5),
									Vector(),
									Vector(),
									self.ID,
									self.Team,
									128,
									0
								)
								if ray <= 0 then
									ray = ((2 * self.alt) / 3)
								end
								local ray = ray
								if math.abs(self.alt - ray) < 15 then
									self.Vel.Y = self.Vel.Y - (0.25 * (self.alt - ray))
								end
							end
							if self.c:IsState(3) and self.Vel.X < 6.5 then
								self.Vel.X = self.Vel.X + 1.25
							elseif self.c:IsState(4) and self.Vel.X > -6.5 then
								self.Vel.X = self.Vel.X - 1.25
							end
						end
					end

					self.Vel.Y = 0.9925 * self.Vel.Y
					self.AngularVel = 0.95 * self.AngularVel
				end
			end
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
