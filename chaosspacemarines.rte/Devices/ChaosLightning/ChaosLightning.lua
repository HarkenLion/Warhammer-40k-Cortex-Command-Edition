function Create(self)
	if not self.var then
		local var = {};

		var.ammo = 100;

		self.var = var;
	end
end

function Update(self)
	local var = self.var;

	if self:IsActivated() then
		var.ammo = math.min(100, math.max(0, var.ammo - 100 / 5 / 60));
	else
		var.ammo = math.min(100, math.max(0, var.ammo + 100 / 5 / 60));
	end

	local mag = self.Magazine;
	if self.Magazine then
		mag.RoundCount = var.ammo;
	end
end