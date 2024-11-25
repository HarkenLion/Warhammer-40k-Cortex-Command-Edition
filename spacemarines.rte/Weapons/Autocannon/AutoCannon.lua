function Create(self)
	self.origActivationDelay = self.ActivationDelay;
	self.spinDownTimer = Timer();
	self.currentlySpinningDown = false;
	self.fireTimer = Timer();

	self.headname = "Dreadnought Autocannon Flash"
	
	for attachable in self.Attachables do
		if attachable.PresetName == self.headname then
			self.GunFront = attachable;
			self.GunFront.GetsHitByMOs = false
			actor = self:GetRootParent(); --MovableMan:GetMOFromID(attachable.RootID)
			if actor.ID ~= self.ID then
				self.operator = ToActor(actor)
			end
			break;
		end
	end	
end

function OnFire(self)
	if not self.GunFront then
		for attachable in self.Attachables do
			if attachable.PresetName == self.headname then
				self.GunFront = attachable;
				self.GunFront.GetsHitByMOs = false
				actor = self:GetRootParent(); -- MovableMan:GetMOFromID(attachable.RootID)
				if actor.ID ~= self.ID then
					self.operator = ToActor(actor)
				end
				break;
			end
		end	
	end
	self.GunFront.Scale = 1
	self.GunFront.Frame = self.Frame;
	self.fireTimer:Reset();
end

function Update(self)
	if self.GunFront then
		if self.GunFront.Scale == 1 and self.fireTimer:IsPastSimMS(15) then
			self.GunFront.Scale = 0
		end
	else
		for attachable in self.Attachables do
			if attachable.PresetName == self.headname then
				self.GunFront = attachable;
				self.GunFront.GetsHitByMOs = false
				actor = self:GetRootParent(); --MovableMan:GetMOFromID(attachable.RootID)
				if actor.ID ~= self.ID then
					self.operator = ToActor(actor)
				end
				break;
			end
		end	
	end

	if not self.currentlySpinningDown and not self:IsActivated() and not self:IsReloading() and self.ActiveSound:IsBeingPlayed() then
		self.spinDownTimer:Reset();
		self.currentlySpinningDown = true;
		self.activationDelay = self.origActivationDelay;
	elseif (self.currentlySpinningDown and self.spinDownTimer:IsPastSimMS(self.DeactivationDelay)) or self:IsReloading() then
		self.ActivationDelay = self.origActivationDelay;
		self.currentlySpinningDown = false;
	elseif self.currentlySpinningDown and self:IsActivated() then
		self.ActivationDelay = self.origActivationDelay * self.spinDownTimer.ElapsedSimTimeMS / self.DeactivationDelay;
		self.currentlySpinningDown = false;
	end

	if self.Magazine ~= nil then
		self.Magazine.Frame = 20 - math.ceil((ToMagazine(self.Magazine).RoundCount/ToMagazine(self.Magazine).Capacity) * 20)
	end
end