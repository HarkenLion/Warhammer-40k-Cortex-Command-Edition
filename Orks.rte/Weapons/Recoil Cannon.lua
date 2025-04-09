function Create(self)
	local actor = MovableMan:GetMOFromID(self.RootID)
	if MovableMan:IsActor(actor) then
		self.parent = ToActor(actor)
	end

	self.recoil = 0
	self.firetimer = Timer()
end

function OnFire(self)
	local user
	user = MovableMan:GetMOFromID(self.RootID)

	local recoil2 = self.recoil
	if recoil2 < 0.02 then
		self.recoil = recoil2 + 0.0007 + (4 - user.Sharpness) * 0.65 * 0.00025
		self.firetimer:Reset()
	end
end

function Update(self)
	if self.RootID ~= self.ID then
		if self.Magazine ~= nil then
			local randb = math.random(-4, 4)
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
