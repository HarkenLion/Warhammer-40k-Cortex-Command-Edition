dofile("Base.rte/Constants.lua")
dofile("necrons.rte/Scripts/AI/NativeWraithAI.lua")

function Create(self)
	self.AI = NativeWraithAI:Create(self)

	self.c = self:GetController()
	self.timer = Timer()
	self.pressed = 0

	self.JumpTimer = Timer()
end

function Update(self)
	if not self:IsDead() then
		self:MoveOutOfTerrain(5)

		if self.Health > 0 then
			if not self:HasObject("Necron Wraith Claw") then
				local hook = CreateHDFirearm("Necron Wraith Claw")
				self:AddInventoryItem(hook)
			end

			if not self:HasObject("Necron Wraith Claw Offhand") then
				local hook = CreateHDFirearm("Necron Wraith Claw Offhand")
				self:AddInventoryItem(hook)
			end
		end

		if self.JumpTimer:IsPastSimMS(1750) then
			if self.Head then
				--CREATE GREENEYE EFFECT
				local redeyeOffset = Vector(6, -11)
				if self.HFlipped then
					redeyeOffset = Vector(-6, -11)
				end
				local redeye = CreateMOPixel("Necron GreenEye 2")
				redeye.Pos = self.Pos + redeyeOffset:RadRotate(self.Head.RotAngle)
				MovableMan:AddParticle(redeye)

				local redeyeOffset = Vector(9, -11)
				if self.HFlipped then
					redeyeOffset = Vector(-9, -11)
				end
				local redeye = CreateMOPixel("Necron GreenEye 2")
				redeye.Pos = self.Pos + redeyeOffset:RadRotate(self.Head.RotAngle)
				MovableMan:AddParticle(redeye)
			end
		end

		if self:GetController():IsState(Controller.BODY_JUMP) == true and self.JumpTimer:IsPastSimMS(1750) then
			self.pressed = 1
			local indic = CreateMOPixel("Indic Glow")
			local newI = self.Pos.X + 210 * math.cos(-self:GetAimAngle(true))
			newI = newI % SceneMan.SceneWidth
			indic.Pos = SceneMan:MovePointToGround(
				Vector(newI, self.Pos.Y + 210 * math.sin(-self:GetAimAngle(true))),
				29,
				25
			)
			MovableMan:AddParticle(indic)
		else
			if self.pressed == 1 and self.JumpTimer:IsPastSimMS(375) then
				self.pressed = 0
				local newX = self.Pos.X + 210 * math.cos(-self:GetAimAngle(true))
				newX = newX % SceneMan.SceneWidth
				self.newpos = SceneMan:MovePointToGround(
					Vector(newX, self.Pos.Y + 210 * math.sin(-self:GetAimAngle(true))),
					29,
					25
				)
				if SceneMan:GetTerrMatter(self.newpos.X, self.newpos.Y) == 0 then
					local part = CreateMOPixel("Warp Glow")
					part.Pos = self.newpos
					MovableMan:AddParticle(part)
					for i = 1, 15, 1 do
						local part = CreateMOSRotating("Subspace Foam Parent")
						part.Pos = self.newpos
						MovableMan:AddParticle(part)
					end
					self.Pos = self.newpos
					self.Vel = self.Vel / 2
					self:FlashWhite(50)

					self.JumpTimer:Reset()
				end
			elseif self.pressed == 0 then
			end
		end

		--propulsion, stabilisation, healing

		local health = self.Health
		if self.timer:IsPastSimMS(4000) and health < 100 then
			self.Health = health + 1
			self.timer = Timer()
		end

		if health > 100 then
			self.Health = 100
		end

		local rotang = self.RotAngle
		if rotang < -0.15 then
			self.RotAngle = -0.15
		elseif rotang > 0.15 then
			self.RotAngle = 0.15
		end

		local alt = self:GetAltitude(0, 1)

		if alt < 50 then
			if alt < 15 and self.Vel.Y > -10 then
				self.Vel.Y = self.Vel.Y - 0.5
			end

			if self.Vel.Y < -3 then
				self.Vel.Y = self.Vel.Y + 0.15
			elseif self.Vel.Y > 3 then
				self.Vel.Y = self.Vel.Y - 0.15
			end
			self.Vel.Y = 0.985 * self.Vel.Y

			self.AngularVel = 0.95 * self.AngularVel

			if self.Vel.X < 15 and self.c:IsState(3) then
				self.Vel.X = self.Vel.X + 0.85
			elseif self.Vel.X > -15 and self.c:IsState(4) then
				self.Vel.X = self.Vel.X - 0.85
			else
				self.Vel.X = self.Vel.X * 0.80
			end
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
