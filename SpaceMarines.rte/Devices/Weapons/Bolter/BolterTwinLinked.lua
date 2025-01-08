function Create(self)
	self.recoil = 0

	self.firecounter = 0
	self.recoilcooldown = 0.0002
	self.firetimer = Timer()
	self.cablesegs = 5
	self.muzzy = 0


end

function OnReload(self)
	self.recoil = 0
end


function OnFire(self)
	local recoil2 = self.recoil
	if recoil2 < 0.022 then
		local user
		user = MovableMan:GetMOFromID(self.RootID)

		self.recoil = recoil2 + 0.004 + (4 - user.Sharpness) * 0.65 * 0.0055
		self.firetimer:Reset()
	end

	local usey = 0
	if self.muzzy == 0 then
		self.muzzy = 6
		usex = 16
	else
		self.muzzy = 0
		usex = 16
	end
	self.MuzzleOffset = Vector(usex, self.muzzy)
end

function OnReload(self)
	self.recoil = 0
end

function Update(self)
	if self.RootID ~= self.ID then
	
		--if not self:IsAtRest() then
		if self.Magazine then
			local randb = math.random(-3, 3)
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
		--end
	end
end
