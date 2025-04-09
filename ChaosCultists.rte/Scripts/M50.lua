function Create(self)
	self.recoil = 0
	self.firecounter = 0
	self.recoilcooldown = 0.00013
end

function OnFire(self)
	local recoil2 = self.recoil
	if recoil2 < 0.03 then
		local actor = MovableMan:GetMOFromID(self.RootID)
		self.recoil = recoil2 + 0.001 + (4 - actor.Sharpness) * 0.6 * 0.0005
	end
end

function Update(self)
	if self:IsReloading() then
		self.recoil = 0.0
	end

	if MovableMan:ValidMO(self.Magazine) then
		local randb = math.random(-7, 7)
		local recoil = self.recoil
		local recoilrand = randb * recoil
		self.RotAngle = self.RotAngle + recoilrand

		if not self:IsActivated() then
			if recoil > 0 then
				self.recoil = recoil - self.recoilcooldown
			elseif recoil < 0 then
				self.recoil = 0
			end
		end
	end
end
