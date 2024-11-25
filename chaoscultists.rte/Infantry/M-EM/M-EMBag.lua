function Create(self)
	self.rotAngleSize = 1

	self.deployTimer = Timer()
	self.deployDelay = 4000

	self.deploying = false
end

function Update(self)
	if self:IsAttached() == true then --I think this is more performance friendly as it doesn't check the parent every frame, rather just when the gun is first taken.
		if self.parent == nil then
			if IsAHuman(self:GetRootParent()) then
				self.parent = ToAHuman(self:GetRootParent())
			end
		end
	else
		self.parent = nil
	end

	if self.parent then
		self.RotAngle = self.RotAngle + self.FlipFactor * 1 * self.rotAngleSize

		if self.FiredFrame then
			if self.deploying == false then
				self.deploying = true
				self.deployTimer:Reset()
			end
		end
		if self.deploying == true then
			local controller = self.parent:GetController()
			local screen = controller.Player

			if self.parent:IsPlayerControlled() == true then
				if self.parent:GetController().InputMode == Controller.CIM_DISABLED then
					self.parent:SetControllerMode(2, self.parent:GetController().Player)
				end

				local guiFrame = (self.deployTimer.ElapsedSimTimeMS / (self.deployDelay / 9))

				local teamTable = { " Red", " Green", " Blue", " Yellow" }

				local radialIcon = CreateMOSRotating(
					"Armada GUI Radial" .. teamTable[self.parent.Team + 1],
					"ImporianArmada.rte"
				)

				PrimitiveMan:DrawBitmapPrimitive(screen, self.parent.Pos, radialIcon, 3.14, guiFrame, true, true)

				PrimitiveMan:DrawTextPrimitive(screen, self.parent.Pos + Vector(-16, 30), "Deploying...", true, 0)
				PrimitiveMan:DrawTextPrimitive(screen, self.parent.Pos + Vector(-18, 38), "Do not move", true, 0)
			else --Ze AI vill not move vile v'ilding!
				self.parent:SetControllerMode(Controller.CIM_DISABLED, self.parent:GetController().Player)
			end

			if
				controller:IsState(Controller.MOVE_RIGHT)
				or controller:IsState(Controller.MOVE_LEFT)
				or controller:IsState(Controller.BODY_JUMP)
				or self.parent.Vel.Magnitude > 5
				or controller:IsState(Controller.PIE_MENU_ACTIVE)
			then
				self.deploying = false
			end

			if self.deployTimer:IsPastSimMS(self.deployDelay) then
				local turret = nil

				if not self.parent:IsPlayerControlled() then
					self.parent.AIMode = Actor.AIMODE_SENTRY --Put AI actor on sentry mode to man turret
				end

				turret = CreateACrab("M-EM", "ImporianArmada.rte")
				turret:SetNumberValue("Bag Spawn", 1)
				turret.Pos = self.parent.Pos + Vector(15 * self.FlipFactor, 3)
				turret.Vel = Vector()
				turret.Team = self.parent.Team
				turret.HFlipped = self.parent.HFlipped
				turret.RotAngle = 0
				MovableMan:AddActor(turret)

				self:RemoveFromParent()
			end
		end
	end
end
