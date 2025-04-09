function Create(self)

	self.recoil = 0;

	self.firecounter = 0;
	self.recoilcooldown = 0.0003;
	self.firetimer = Timer();
	self.muzzx = 12;
end

function OnFire(self)
	local recoil2 = self.recoil;
	if recoil2 < 0.024 then
		local user 
		user = MovableMan:GetMOFromID(self.RootID);

		self.recoil = recoil2 + 0.0025 + (4 - user.Sharpness) * 0.65 * 0.0021;
		self.firetimer:Reset();
	end

	local usey = 0;
	if self.muzzx == 12 then
		self.muzzx = 14
		usey = -1
	else
		self.muzzx = 12
		usey = 1
	end
	self.MuzzleOffset = Vector(self.muzzx,usey)
end

function Update(self)

	if self.RootID ~= self.ID then
		if self:IsReloading() then
			self.recoil = 0.0;
		end

		if self.Magazine then
			self.Magazine.Frame = 20 - math.ceil((ToMagazine(self.Magazine).RoundCount/ToMagazine(self.Magazine).Capacity) * 20)
				local randb = math.random(-4,4);
				local recoil = self.recoil
				local recoilrand = randb * recoil;
				self.RotAngle = self.RotAngle + recoilrand;

			if self.firetimer:IsPastSimMS(80) then
				if recoil > 0 then
					local user 
					user = MovableMan:GetMOFromID(self.RootID);
					self.recoil = recoil - self.recoilcooldown * user.Sharpness;

				elseif recoil < 0 then
					self.recoil = 0;
				end

			end
		end

	end

end