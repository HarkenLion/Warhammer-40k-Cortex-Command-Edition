function Create(self)
	self.LifeTimer = Timer()
	self.StunTimer = Timer()
	self.SpazTimer = Timer()
	self.FlashTimer = Timer()
	self.target = nil
	self.stickpositionX = 0
	self.stickpositionY = 0
	self.stickrotation = 0
	self.stickdirection = 0
	self.startflipped = false

	self.stundelay = 370 -- delay before stunning (MS)
	self.stuntime = 1600 -- how long target is stunned (MS)
	self.hit = 0
end

function Update(self)
	if self.target == nil then
		if self.LifeTimer:IsPastSimMS(750) then
			self.ToDelete = true
		end
		self.stickobject = SceneMan:CastMORay(
			self.Pos,
			Vector(5, 0):RadRotate(self.RotAngle),
			255,
			self.Team,
			0,
			false,
			0
		)
		if self.stickobject ~= 255 then
			self.target = MovableMan:GetMOFromID(self.stickobject)
			self.stickpositionX = self.Pos.X - self.target.Pos.X
			self.stickpositionY = self.Pos.Y - self.target.Pos.Y
			self.stickrotation = self.target.RotAngle
			self.stickdirection = self.RotAngle
			self.startflipped = self.target.HFlipped
			self.StunTimer:Reset()
		end
	elseif self.target ~= nil and self.target.ID ~= 255 then
		self.ToDelete = false
		self.ToSettle = false
		self.Pos = self.target.Pos
			+ Vector(self.stickpositionX, self.stickpositionY):RadRotate(self.target.RotAngle - self.stickrotation)
		self.RotAngle = self.stickdirection + (self.target.RotAngle - self.stickrotation)
		self.Vel = Vector(0, 0)
		self.PinStrength = 1000

		self.actor = MovableMan:GetMOFromID(self.target.RootID)

		if MovableMan:IsActor(self.actor) then
			if self.LifeTimer:IsPastSimMS(self.stuntime) then
				self.ToSettle = true
				self.ToDelete = true
			end

			ToActor(self.actor):GetController():SetState(Controller.BODY_JUMP, false)
			ToActor(self.actor):GetController():SetState(Controller.BODY_JUMPSTART, false)
			ToActor(self.actor):GetController():SetState(Controller.PIE_MENU_ACTIVE, false)
			ToActor(self.actor):GetController():SetState(Controller.AIM_SHARP, false)
			ToActor(self.actor):GetController():SetState(Controller.WEAPON_FIRE, false)

			ToActor(self.actor):SetAimAngle(math.random(math.pi / -2, math.pi / 2))
			ToActor(self.actor):GetController():SetState(Controller.BODY_CROUCH, true)

			if self.actor.ClassName == "AHuman" and not (self.StunTimer:IsPastSimMS(self.stundelay)) then
				if
					not (
						ToActor(self.actor):GetController():IsState(Controller.MOVE_RIGHT)
						and ToActor(self.actor):GetController():IsState(Controller.MOVE_LEFT)
					)
				then
					if self.startflipped == false then
						ToActor(self.actor):GetController():SetState(Controller.MOVE_RIGHT, true)
					else
						ToActor(self.actor):GetController():SetState(Controller.MOVE_LEFT, true)
					end
				end
			end

			if self.FlashTimer:IsPastSimMS(335) then
				self.FlashTimer:Reset()

				ToActor(self.actor).Health = ToActor(self.actor).Health - 1

				ToActor(self.actor):SetAimAngle(math.random(math.pi / -2, math.pi / 2))
				ToActor(self.actor):GetController():SetState(Controller.BODY_CROUCH, true)

				ToActor(self.actor):GetController():SetState(Controller.AIM_SHARP, false)
				ToActor(self.actor):GetController():SetState(Controller.WEAPON_FIRE, false)

				ToActor(self.actor):FlashWhite(70)

				if ToActor(self.actor).Health < 3 then
					ToActor(self.actor).Health = 0
					self.ToDelete = true
				end
			end
		end
	elseif self.target ~= nil and self.target.ID == 255 then
		self:GibThis()
	end
end
