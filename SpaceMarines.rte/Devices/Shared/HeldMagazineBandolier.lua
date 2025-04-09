function Create(self)
	self.magazineName = self:StringValueExists("MagazineName") and self:GetStringValue("MagazineName") or "Frag Magazine";
	self.magazineTech = self:StringValueExists("MagazineTech") and self:GetStringValue("MagazineTech") or "Base.rte";
	self.magazineObject = CreateHeldDevice(self.magazineName, self.magazineTech);
	self.bandolierKey =  self.magazineTech .. "/" .. self.PresetName;
	self.bandolierMass = self:NumberValueExists("BandolierMass") and self:GetNumberValue("BandolierMass") or 1.5;
	self.replenishDelay = self:NumberValueExists("ReplenishDelay") and self:GetNumberValue("ReplenishDelay") or 0;
	self.magazineMass = self:NumberValueExists("MagazineMass") and self:GetNumberValue("MagazineMass") or self.magazineObject.Mass;
	self.magazinesPerBandolier = self:NumberValueExists("MagazineCount") and self:GetNumberValue("MagazineCount") or 3;
	self.magazinesRemainingInBandolier = self:NumberValueExists("MagazinesRemainingInBandolier") and self:GetNumberValue("MagazinesRemainingInBandolier") or self.magazinesPerBandolier;
end

function OnAttach(self, newParent)
	local rootParent = self:GetRootParent();

	if IsAHuman(rootParent) then
		rootParent = ToAHuman(rootParent);
	end

	if rootParent and not rootParent:NumberValueExists(self.bandolierKey) then
		local attachable = CreateAttachable("Magazine Bandolier", "SpaceMarines.rte");
		attachable:SetStringValue("BandolierName", self.PresetName);
		attachable:SetNumberValue("BandolierMass", self.bandolierMass);
		attachable:SetNumberValue("ReplenishDelay", self.replenishDelay);
		attachable:SetStringValue("MagazineName", self.magazineName);
		attachable:SetStringValue("MagazineTech", self.magazineTech);

		attachable:SetNumberValue("MagazineMass", self.magazineMass);
		attachable:SetNumberValue("MagazinesPerBandolier", self.magazinesPerBandolier);

		if self.magazinesPerBandolier ~= self.magazinesRemainingInBandolier then
			attachable:SetNumberValue("MagazinesRemainingInBandolier", self.magazinesRemainingInBandolier);
		end

		rootParent:AddAttachable(attachable);
		self.ToDelete = true;
	end
end