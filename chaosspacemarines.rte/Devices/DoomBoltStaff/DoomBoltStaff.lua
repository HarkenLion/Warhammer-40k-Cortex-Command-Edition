function Create(self)
	if not self.var then
		local var = {};
		
		var.grip = Vector(0, 0);
		var.maxGrip = Vector(0, 20);
		var.minGrip = Vector(0, 10);
		var.gripRange = var.maxGrip - var.minGrip;
		var.pommelOffset = Vector(0, 40);
		var.raise = Vector(0, 6);
		var.minRaise = Vector(0, 1);
		var.maxRaise = Vector(0, -10);
		var.raiseRange = var.maxRaise - var.minRaise;
		var.stanceDisplacement = Vector(0, 0);
		var.preset = ToHDFirearm(PresetMan:GetPreset(self.ClassName, self.PresetName, self.ModuleName));
		var.raiseTime = var.preset.ActivationDelay;
		var.presetStance = var.preset.StanceOffset * 1;
		var.presetSharpStance = var.preset.SharpStanceOffset * 1;
		var.presetJoint = var.preset.JointOffset * 1;

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

	-- lock the staff grip if we're casting
	local locked = false;
	if self:IsActivated() then
		var.raise = var.raise + var.raiseRange * (1000 / 60) / (var.raiseTime);
		var.raise.Y = math.max(var.raise.Y, var.maxRaise.Y); 
		locked = true;
	else
		var.raise = var.raise - var.raiseRange * (1000 / 60) / (var.raiseTime);
		var.raise.Y = math.min(var.raise.Y, var.minRaise.Y); 
	end

	if not locked then
		local checkPos = self.Pos + var.pommelOffset:GetRadRotatedCopy(self.RotAngle);

		if SceneMan:GetTerrMatter(checkPos.X, checkPos.Y) ~= 0 then
			var.grip = var.grip + var.gripRange * (1000 / 60) / (var.raiseTime);
			var.stanceDisplacement = var.stanceDisplacement + var.gripRange.Perpendicular * (1000 / 60) / (var.raiseTime);
			var.grip.Y = math.min(var.grip.Y, var.maxGrip.Y);
		else
			var.grip = var.grip - var.gripRange * (1000 / 60) / (var.raiseTime);
			var.stanceDisplacement = var.stanceDisplacement - var.gripRange.Perpendicular * (1000 / 60) / (var.raiseTime);
			var.grip.Y = math.max(var.grip.Y, var.minGrip.Y); 
		end
	end

	var.stanceDisplacement = var.stanceDisplacement * 0.9;

	self.StanceOffset = var.presetStance + var.raise + var.stanceDisplacement;
	self.JointOffset = var.presetJoint + var.grip;
	self.SharpStanceOffset = var.presetSharpStance + var.raise + var.stanceDisplacement;
end
