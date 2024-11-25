function Create(self)
	self.lifttimer = Timer()
	self.rechargeTimer = Timer()
	self.emptyTimer = Timer()
	self.grabTimer = Timer()
	self.lifttimer = Timer()
	self.ammoCounter = 100

	self.Magazine.RoundCount = self.ammoCounter

	local actor = MovableMan:GetMOFromID(self.RootID)
	if MovableMan:IsActor(actor) then
		self.parent = ToActor(actor)
		self.totalAmmo = self.parent.Sharpness * 30
	end
end

function Update(self)
	if MovableMan:IsActor(self.parent) then
		if self.Magazine ~= nil then
			if self.ammoCounter <= 2 and not self.rechargeTimer:IsPastSimMS(700) then
				self.parent:GetController():SetState(Controller.WEAPON_FIRE, false)
				self.emptyTimer:Reset()
			end

			if self:IsActivated() then
				self.rechargeTimer:Reset()
				self.parent:GetController():SetState(Controller.BODY_CROUCH, false)
				self.parent:GetController():SetState(Controller.BODY_JUMP, false)
				self.parent:GetController():SetState(Controller.BODY_JUMPSTART, false)

				if self.ammoCounter > 2 then
					self.ammoCounter = self.ammoCounter - 1
				end
			end

			if
				self.rechargeTimer:IsPastSimMS(150 - self.parent.Sharpness * 15)
				and self.emptyTimer:IsPastSimMS(1200)
				and self.ammoCounter < self.totalAmmo
			then
				self.rechargeTimer:Reset()
				self.ammoCounter = self.ammoCounter + 1.2
			end

			self.Magazine.RoundCount = math.ceil(self.ammoCounter)
		end
	else
		local actor = MovableMan:GetMOFromID(self.RootID)
		if MovableMan:IsActor(actor) then
			self.parent = ToActor(actor)
			self.totalAmmo = self.parent.Sharpness * 30
		end
	end
end
