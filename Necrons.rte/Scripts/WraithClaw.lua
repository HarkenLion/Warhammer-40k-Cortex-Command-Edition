function Create(self)
	local actor = MovableMan:GetMOFromID(self.RootID)
	if MovableMan:IsActor(actor) then
		self.parent = ToActor(actor)
	end

	self.fireTimer = Timer()
	self.rechargeTimer = Timer()
	self.negatore = 1
	self.fired = false
	self.ammoCounter = 21
	self.Scale = 0.85

	self.Magazine.RoundCount = self.ammoCounter
end

function Update(self)
	if self.ID ~= self.RootID then
		self.GetsHitByMOs = false

		if self.parent then
			if self.HFlipped == false then
				self.negatore = 1
				self.RotAngle = self.RotAngle - 0.95
			else
				self.negatore = -1
				self.RotAngle = self.RotAngle + 0.95
			end

			if self:IsActivated() then
				if self.ammoCounter > 1 then
					if self.fireTimer:IsPastSimMS(20) then
						self.fireTimer:Reset()
						self.ammoCounter = self.ammoCounter - 1

						local rand = math.random(-65, 65)
						if self.parent.HFlipped == false then
							self.RotAngle = self.parent:GetAimAngle(true) + (rand * 0.01)
						else
							self.RotAngle = (self.parent:GetAimAngle(true) + math.pi + (rand * 0.01))
						end
					end
					self.fired = true
				else
					self:Deactivate()
				end
			else
				if self.fired == true then
					self.rechargeTimer:Reset()
					self.fired = false
				end
				if self.rechargeTimer:IsPastSimMS(30) and self.ammoCounter < 50 then
					self.rechargeTimer:Reset()
					self.ammoCounter = self.ammoCounter + 1
				end
			end

			if self.Magazine ~= nil then
				self.Magazine.RoundCount = self.ammoCounter
			end
		else
			local actor = MovableMan:GetMOFromID(self.RootID)
			if MovableMan:IsActor(actor) then
				self.parent = ToActor(actor)
			end
		end
	end
end
