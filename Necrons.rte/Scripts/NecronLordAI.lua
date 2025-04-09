dofile("Base.rte/Constants.lua")
dofile("Necrons.rte/Scripts/AI/NativeNecronAI.lua")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.WTime = Timer()
end

function Update(self)
	local con = self:GetController()
	con:SetState(9, false)

	con:SetState(9, false)

	if con:IsState(3) or con:IsState(4) or con:IsState(10) or con:IsState(5) then
		if self.WTime:IsPastSimMS(80) then
			self.WTime:Reset()

			local rotangle = self.RotAngle
			if rotangle > -0.15 and rotangle < 0.15 then
				if self.FGLeg ~= nil and self.BGLeg ~= nil then
					if con:IsState(3) or con:IsState(4) then
						self.alt = 23
					else
						self.alt = 21
					end

					if SceneMan.SceneWidth > self.Pos.X + 12 and 0 < self.Pos.X - 12 then
						self.dx = 12
						if self.Vel.X < 0 then
							self.dx = -12
						end
						if math.abs(self.Vel.X) < 1 then
							self.dx = 0
						end
					else
						self.dx = 0
					end

					if not con:IsState(10) and not con:IsState(5) and self.Health > 0 then
						self.ray = SceneMan:CastObstacleRay(
							self.Pos,
							Vector(0, 20 * 1.5),
							Vector(),
							Vector(),
							self.ID,
							self.Team,
							128,
							0
						)
						if self.ray > 0 then
							if math.abs(self.Vel.Y) < 5 then
								local ray = SceneMan:CastObstacleRay(
									Vector(self.Pos.X + self.dx, self.Pos.Y),
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
									self.Vel.Y = self.Vel.Y - (0.2 * (self.alt - ray))
								end
							end
							if con:IsState(3) and self.Vel.X < 4 then
								self.Vel.X = self.Vel.X + 0.75
							elseif con:IsState(4) and self.Vel.X > -4 then
								self.Vel.X = self.Vel.X - 0.75
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
