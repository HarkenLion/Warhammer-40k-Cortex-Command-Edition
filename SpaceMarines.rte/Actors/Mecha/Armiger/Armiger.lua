function Create(self)
	local var = {};
	
	var.FakeFGThigh = nil;
	var.FakeBGCalf = nil;
	var.FakeFGThigh = nil;
	var.FakeBGCalf = nil;
	
	for attachable in self.Attachables do
		if attachable.PresetName == "Armiger Fake FG Leg A" then
			var.FakeFGThigh = attachable;
			var.FakeFGCalf = attachable.Attachables();
		elseif attachable.PresetName == "Armiger Fake BG Leg A" then
			var.FakeBGThigh = attachable;
			var.FakeBGCalf = attachable.Attachables();
		end
	end
	
	self.var = var;
end

function Update(self)
	local var = self.var;
	
	local hFlip = self.HFlipped;
	local hFlipFactor = self.FlipFactor;
	
	local thigh = var.FakeFGThigh;
	local calf = var.FakeFGCalf;
	local footPos = self.FGFoot.Pos;
	if thigh and calf then
		local newAngle = math.pi / 2 - math.atan2(footPos.Y - thigh.Pos.Y, footPos.X - thigh.Pos.X);
		local dist = SceneMan:ShortestDistance(thigh.Pos, footPos, true);
		local offset = math.asin(15 / dist.Magnitude);
		thigh.RotAngle = newAngle + offset * hFlipFactor;
		calf.ParentOffset = (dist - (dist * 1):SetMagnitude(36):GetRadRotatedCopy(offset)):GetRadRotatedCopy(-thigh.RotAngle);
		calf.RotAngle = newAngle + offset;
	end
	
	local thigh = var.FakeBGThigh;
	local calf = var.FakeBGCalf;
	local footPos = self.BGFoot.Pos;
	if thigh and calf then
		local newAngle = math.pi / 2 - math.atan2(footPos.Y - thigh.Pos.Y, footPos.X - thigh.Pos.X);
		local dist = SceneMan:ShortestDistance(thigh.Pos, footPos, true);
		local offset = math.asin(15 / dist.Magnitude);
		thigh.RotAngle = newAngle + offset * hFlipFactor;
		calf.ParentOffset = (dist - (dist * 1):SetMagnitude(36):GetRadRotatedCopy(offset)):GetRadRotatedCopy( - thigh.RotAngle);
		calf.RotAngle = newAngle + offset;
	end
end