function Create(self)
	if not self.var then
		local var = {};

		var.raise = Vector(0, 6);
		var.minRaise = Vector(0, 15);
		var.maxRaise = Vector(0, -10);
		var.raiseRange = var.maxRaise - var.minRaise;
		var.preset = ToHDFirearm(PresetMan:GetPreset(self.ClassName, self.PresetName, self.ModuleName));
		var.raiseTime = var.preset.ActivationDelay;
		var.presetStance = var.preset.StanceOffset * 1;
		var.presetSharpStance = var.preset.SharpStanceOffset * 1;

		self.var = var;
	end
end

function OnFire(self)

end

function Update(self)
	local var = self.var;

	for attachable in self.Attachables do
		if attachable.PresetName == "Doom Bolt Staff Glow" then
			attachable.EffectRotAngle = self.RotAngle + (1 - self.FlipFactor) * math.pi / 2;
			local s = 0.5 + (0.3 + math.random() / 5) * (var.raise.Y - var.minRaise.Y) / (var.maxRaise.Y - var.minRaise.Y);
			attachable:SetEffectStrength(s);
		end
	end

	if self.Flash then
		self.Flash.EffectRotAngle = self.RotAngle + (1 - self.FlipFactor) * math.pi / 2;
		--local s = (0.8 + math.random() / 5) * (var.raise.Y - var.minRaise.Y) / (var.maxRaise.Y - var.minRaise.Y);
		self.Flash:SetEffectStrength(self.FiredFrame and 1 or 0);
	end

	if self:IsActivated() then
		var.raise = var.raise + var.raiseRange * (1000 / 60) / (var.raiseTime);
		var.raise.Y = math.max(var.raise.Y, var.maxRaise.Y); 
	else
		var.raise = var.raise - var.raiseRange * (1000 / 60) / (var.raiseTime);
		var.raise.Y = math.min(var.raise.Y, var.minRaise.Y); 
	end

	self.StanceOffset = var.presetStance + var.raise;
	self.SharpStanceOffset = var.presetSharpStance + var.raise;
end
