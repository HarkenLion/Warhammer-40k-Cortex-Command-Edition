function Create(self)
	self.recoil = 0

	self.ff = false

	self.f0 = ToMagazine(self.Magazine).RoundCount

	self.f1 = ToMagazine(self.Magazine).RoundCount

	self.firecounter = 0
	self.recoilcooldown = 0.00009
end

function Update(self)
	if self:IsReloading() then
		self.recoil = 0.0
	end

	if self.Magazine ~= nil then
		self.Magazine.Frame = 20
			- math.ceil((ToMagazine(self.Magazine).RoundCount / ToMagazine(self.Magazine).Capacity) * 20)

		if self.ff then
			self.f0 = ToMagazine(self.Magazine).RoundCount

			self.ff = false
		else
			self.f1 = ToMagazine(self.Magazine).RoundCount

			self.ff = true
		end

		if self:IsActivated() and self.f1 ~= self.f0 then
			local recoil2 = self.recoil
			if recoil2 < 0.015 then
				self.recoil = recoil2 + 0.001
			end
		end

		local randb = math.random(-5, 5)

		local recoil = self.recoil
		local recoilrand = randb * recoil

		self.RotAngle = self.RotAngle + recoilrand

		if self.firetimer:IsPastSimMS(100) then
			if recoil > 0 then
				local user
				user = MovableMan:GetMOFromID(self.RootID)
				self.recoil = recoil - self.recoilcooldown * user.Sharpness
			elseif recoil < 0 then
				self.recoil = 0
			end
		end
	end
end
