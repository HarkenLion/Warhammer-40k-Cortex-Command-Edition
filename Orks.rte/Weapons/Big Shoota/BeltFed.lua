function Create(self)
	self.recoil = 0
	self.firecounter = 0
	self.recoilcooldown = 0.00009
end

function OnFire(self)
	local recoil2 = self.recoil
	if recoil2 < 0.03 then
		self.recoil = recoil2 + 0.001
	end
end

function Update(self)
	if self.RootID ~= self.ID then
		if self:IsReloading() then
			self.recoil = 0.0
		end

		if self.Magazine ~= nil then
			if self.recoil > 0 then
				local randb = math.random(-4, 4)
				local recoil = self.recoil
				local recoilrand = randb * recoil
				self.RotAngle = self.RotAngle + recoilrand
				self.recoil = recoil - self.recoilcooldown
			elseif self.recoil < 0 then
				self.recoil = 0
			end
		end
	end
end
