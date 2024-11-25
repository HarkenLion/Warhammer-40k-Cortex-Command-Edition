function Create(self)

	self.recoil = 0;

	self.firecounter = 0;
	self.recoilcooldown = 0.0003;
	self.firetimer = Timer();

end

function OnFire(self)
	local recoil2 = self.recoil;
	if recoil2 < 0.022 then
		local user 
		user = MovableMan:GetMOFromID(self.RootID);

		self.recoil = recoil2 + 0.0045 + (4 - user.Sharpness) * 0.65 * 0.0041;
		self.firetimer:Reset();
	end
end


function Update(self)

	if self.RootID ~= self.ID then
		if self:IsReloading() then
			self.recoil = 0.0;
		end

		if self.Magazine then
			local randb = math.random(-3,3);
			local recoil = self.recoil
			local recoilrand = randb * recoil;
			self.RotAngle = self.RotAngle + recoilrand;

			if self.firetimer:IsPastSimMS(80) then
				if recoil > 0 then
					local user 
					user = MovableMan:GetMOFromID(self.RootID);
					self.recoil = recoil - (self.recoilcooldown * user.Sharpness);

				elseif recoil < 0 then
					self.recoil = 0;
				end

			end
		end
	end


end 