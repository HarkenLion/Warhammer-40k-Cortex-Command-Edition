function Create(self)
	self.recoil = 0
	self.firetimer = Timer()
end

function OnFire(self)
	local user
	user = MovableMan:GetMOFromID(self.RootID)

	local recoil2 = self.recoil
	if recoil2 < 0.02 then
		self.recoil = recoil2 + 0.008 + (4 - user.Sharpness) * 0.65 * 0.00025
		self.firetimer:Reset()
	end
end

function Update(self)
	if self.RootID ~= self.ID then
		if self.Magazine then
			local randb = math.random(-5, 5)
			local recoil = self.recoil
			local recoilrand = randb * recoil
			self.RotAngle = self.RotAngle + recoilrand

			if self.firetimer:IsPastSimMS(160) then
				if recoil > 0 then
					local user
					user = MovableMan:GetMOFromID(self.RootID)
					self.recoil = recoil - 0.0004 * user.Sharpness
				elseif recoil < 0 then
					self.recoil = 0
				end
			end
		end
	end
end
