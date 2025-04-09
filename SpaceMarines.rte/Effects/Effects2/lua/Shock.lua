function Create(self)
	self.lifeTimer = Timer()
	self.flashTimer = Timer()
	self.flashDelay = 40

	self.detectWidthAndHeight = 30 + math.random(30)
	self.spaceSkip = 10

	self.scanDots = self.detectWidthAndHeight / self.spaceSkip
	self.backAmount = self.detectWidthAndHeight * -0.5

	self.random = math.random(300)
	--self.target = nil;

	if math.random() <= 0.20 then
		for x = 1, self.scanDots do
			for y = 1, self.scanDots do
				local checkPos = self.Pos
					+ Vector(self.backAmount + (x * self.spaceSkip), self.backAmount + (y * self.spaceSkip))
				if SceneMan.SceneWrapsX == true then
					if checkPos.X > SceneMan.SceneWidth then
						checkPos = Vector(checkPos.X - SceneMan.SceneWidth, checkPos.Y)
					elseif checkPos.X < 0 then
						checkPos = Vector(SceneMan.SceneWidth + checkPos.X, checkPos.Y)
					end
				end

				local moCheck = SceneMan:GetMOIDPixel(checkPos.X, checkPos.Y)
				if moCheck ~= 255 then
					local actor = MovableMan:GetMOFromID(MovableMan:GetMOFromID(moCheck).RootID)
					if MovableMan:IsActor(actor) and actor.Team ~= self.Team then
						self.target = ToActor(actor)
						self.random = math.random(self.target.Mass)
						--self.Pos = self.target.Pos;
					end
				end
			end
		end
	end
end

function Update(self)
	if self.target ~= nil and MovableMan:IsActor(self.target) then
		if math.random() <= 0.75 then
			local part = CreateMOPixel("Untitled.rte.rte/Shocky Spark " .. math.random(3))
			part.Pos = self.Pos
				+ Vector(self.target.Radius * 0.4 + math.random(self.target.Radius * 0.4), 0):RadRotate(
					2 * math.pi * math.random()
				)
			part.Vel = Vector(math.random(), 0):RadRotate(2 * math.pi * math.random())
			MovableMan:AddParticle(part)
		end

		self.Pos = self.target.Pos

		self.target:GetController():SetState(Controller.BODY_JUMP, false)
		self.target:GetController():SetState(Controller.BODY_JUMPSTART, false)
		self.target:GetController():SetState(Controller.BODY_CROUCH, true)
		self.target:GetController():SetState(Controller.PIE_MENU_ACTIVE, false)
		self.target:GetController():SetState(Controller.WEAPON_FIRE, false)
		self.target:GetController():SetState(Controller.AIM_SHARP, false)
		self.target:GetController():SetState(Controller.MOVE_RIGHT, false)
		self.target:GetController():SetState(Controller.MOVE_LEFT, false)

		if self.target.Health > 0 then
			if not self.lifeTimer:IsPastSimMS(400 + self.random) then
				if self.flashTimer:IsPastSimMS(self.flashDelay + math.random(100)) then
					self.target:FlashWhite(20 + math.random(10))

					self.flashTimer:Reset()
					self.flashDelay = self.flashDelay * 1.10
				end
			end
		end

		if self.lifeTimer:IsPastSimMS(600 + self.random) then
			self.ToDelete = true
		end
	else
		self.ToDelete = true
	end
end
