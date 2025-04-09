function Create(self)
	local actor = MovableMan:GetMOFromID(self.RootID)
	if MovableMan:IsActor(actor) then
		self.parent = ToActor(actor)
	end

	self.recoil = 0
	self.firecounter = 0
	self.recoilcooldown = 0.00019
	self.firetimer = Timer()
end

function OnFire(self)
	if not self.parent then
		local actor = MovableMan:GetMOFromID(self.RootID)
		if MovableMan:IsActor(actor) then
			self.parent = ToActor(actor)
		end
	else
		local recoil2 = self.recoil
		if recoil2 < 0.024 then
			self.recoil = recoil2 + 0.0006 + (4 - self.parent.Sharpness) * 0.65 * 0.0007
		end
	end
	self.firetimer:Reset()
end

function Update(self)
	if self:IsReloading() then
		self.recoil = 0.0
		local actor = MovableMan:GetMOFromID(self.RootID)
		if MovableMan:IsActor(actor) then
			self.parent = ToActor(actor)
		end
	end

	if MovableMan:ValidMO(self.Magazine) then
		local randb = math.random(-4, 4)

		local recoil = self.recoil
		local recoilrand = randb * recoil

		self.RotAngle = self.RotAngle + recoilrand

		if self.firetimer:IsPastSimMS(80) then
			if recoil > 0 then
				self.recoil = recoil - self.recoilcooldown
			elseif recoil < 0 then
				self.recoil = 0
			end
		end
	end
end
