local modifyMagazineCount = function(self, numberOfMagazinesToAddOrRemove, doNotDeleteAttachableIfThereAreNoMoreMagazines)
	-- This is probably an unnecessary safety check, but it may be possible for some combination of replenish delays and replenish gui time limits to result in wonky behaviour, so it's best to be extra safe.
	if self.currentMagazineCount < 0 then
		self.ToDelete = true;
		return;
	end

	self.currentMagazineCount = self.infiniteMagazines and 1 or (self.currentMagazineCount + numberOfMagazinesToAddOrRemove);
	self.Mass = self.bandolierMass + (self.magazineMass * self.currentMagazineCount);
	self.rootParent:SetNumberValue(self.bandolierKey, self.currentMagazineCount);
	self.rootParent:SetGoldValue(self.rootParent:GetGoldValue(self.rootParent.ModuleID, 1, 1) + (self.magazineObjectGoldValue * numberOfMagazinesToAddOrRemove));

	if self.currentMagazineCount <= 0 and not doNotDeleteAttachableIfThereAreNoMoreMagazines then
		self.ToDelete = true;
	end
end

-- Note: This function returns whether or not the replenished magazine was equipped.
local replenishMagazine = function(self, forceEquipMagazine)
	self.rootParent:AddInventoryItem(self.magazinePreset:Clone());

	if forceEquipMagazine or self.magazineReplenishDelay < 100 then
		self:modifyMagazineCount(-1);
		self.rootParent.UpperBodyState = AHuman.WEAPON_READY;
		-- Only actually equip the magazine if the root parent was previously holding one, or we're forcing it to equip it. This avoids issues when, for example, removing a magazine from the root parent's inventory via Lua.
		return (forceEquipMagazine or self.magazinePreviouslyHeldByRootParent) and self.rootParent:EquipNamedDevice(self.magazineTech, self.magazineName, true);
	else
		self.magazineReplenishGUITimer:Reset();
		self:modifyMagazineCount(-1, true);
	end

	return false;
end

function Create(self)
	self.modifyMagazineCount = modifyMagazineCount;
	self.replenishMagazine = replenishMagazine;
	self.DeleteWhenRemovedFromParent = true;

	local rootParent = self:GetRootParent();
	
	if not IsAHuman(rootParent) then
		self.ToDelete = true;
		return;
	end

	local rootParent = ToAHuman(rootParent);
	self.controller = rootParent:GetController();

	self.magazineName = self:GetStringValue("MagazineName");
	self.magazineTech = self:GetStringValue("MagazineTech");
	self.magazinePreset = ToHeldDevice(PresetMan:GetPreset("HeldDevice", self.magazineName, PresetMan:GetModuleID(self.magazineTech)));
	self.magazineKey = self.magazineTech .. "/" .. self.magazineName;

	self.magazineReplenishDelay = self:GetNumberValue("ReplenishDelay");
	self.magazineReplenishTimer = Timer();
	self.magazineReplenishTimer:SetSimTimeLimitMS(self.magazineReplenishDelay);

	self.magazineMass = self:GetNumberValue("MagazineMass");
	self.magazinesPerBandolier = self:GetNumberValue("MagazinesPerBandolier");
	if self.magazinesPerBandolier == -1 then
		self.infiniteMagazines = true;
	end
	self.magazineObjectGoldValue = self.magazinePreset:GetGoldValue(self.magazinePreset.ModuleID, 1, 1);

	self.currentMagazineCount = self.rootParent:GetNumberValue(self.bandolierKey);
	local magazinesToAdd = self:NumberValueExists("MagazinesRemainingInBandolier") and self:GetNumberValue("MagazinesRemainingInBandolier") or self.magazinesPerBandolier;
	self:RemoveNumberValue("MagazinesRemainingInBandolier");
	self:modifyMagazineCount(self.currentMagazineCount == 0 and magazinesToAdd or 0);

	self.magazineAmmoIcon = CreateMOSParticle("Ammo Icon", "Base.rte");

	self.magazineReplenishGUITimer = Timer();
	self.magazineReplenishGUITimer:SetSimTimeLimitMS(1500);
	self.magazineReplenishGUITimer.ElapsedSimTimeMS = self.magazineReplenishGUITimer:GetSimTimeLimitMS() + 1000;
	self.magazineReplenishIcon = self.magazinePreset;
	-- TODO maybe change sprite or at least sprite colour for refresh plus
	self.magazineReplenishPlusIcon = CreateMOSParticle("Particle Heal Effect", "Base.rte");
	
	self.bandolierObjectForDropping = CreateHeldDevice(self.bandolierName, self.magazineTech);
	
	local heldObjectCharacteristic = self.rootParent.EquippedItem ~= nil and self.rootParent.EquippedItem:GetModuleAndPresetName() or nil;
	local holdingMagazine = heldObjectCharacteristic == self.magazinePreset:GetModuleAndPresetName();
	if heldObjectCharacteristic ~= self.magazinePreset:GetModuleAndPresetName() then
		self:replenishMagazine(true);
	end
end

function Update(self)
	if self.rootParent and self.rootParent.Health > 0 and MovableMan:ValidMO(self.rootParent) then
		local heldObjectCharacteristic = self.rootParent.EquippedItem ~= nil and self.rootParent.EquippedItem:GetModuleAndPresetName() or nil;
		local holdingMagazine = heldObjectCharacteristic == self.magazinePreset:GetModuleAndPresetName();

		-- If the root parent is holding a magazine bandolier, merge it and replace it with a magazine.
		if heldObjectCharacteristic == self.bandolierKey then
			local rootParentEquippedItem = self.rootParent.EquippedItem;
			rootParentEquippedItem:RemoveFromParent();
			local bandolierMagazineCount = rootParentEquippedItem:NumberValueExists("MagazinesRemainingInBandolier") and rootParentEquippedItem:GetNumberValue("MagazinesRemainingInBandolier") or self.magazinesPerBandolier;
			self:modifyMagazineCount(bandolierMagazineCount);
			holdingMagazine = self:replenishMagazine(true);
		end

		local hasInventoryMagazine = false;

		-- Merge any magazines or magazine bandoliers in the root parent's inventory.
		if self.rootParent:HasObject(self.magazineName) or self.rootParent:HasObject(self.bandolierName) then
			local rootParentHasMagazineOrBandolierSoAnyCopiesCanBeMerged = holdingMagazine;

			for item in self.rootParent.Inventory do
				if item:GetModuleAndPresetName() == self.bandolierKey or item:GetModuleAndPresetName() == self.magazinePreset:GetModuleAndPresetName() then
					hasInventoryMagazine = hasInventoryMagazine or item.PresetName == self.magazineName;

					if not rootParentHasMagazineOrBandolierSoAnyCopiesCanBeMerged then
						rootParentHasMagazineOrBandolierSoAnyCopiesCanBeMerged = true;
					else
						self:modifyMagazineCount(item.PresetName == self.bandolierName and self.magazinesPerBandolier or 1);
						self.rootParent:RemoveInventoryItem(self.magazineTech, item.PresetName);
					end
				end
			end
		end

		-- Draw the magazine ammo icon and text.
		if self.rootParent.HUDVisible and holdingMagazine and self.rootParent:IsPlayerControlled() and not (self.rootParent.Jetpack and self.rootParent.Jetpack:IsEmitting()) then
			local distanceBetweenIconAndText = 2 + math.floor(self.magazineAmmoIcon:GetSpriteWidth() * 0.5);
			local drawPosition = self.rootParent.AboveHUDPos + Vector(-distanceBetweenIconAndText, self.rootParentController:IsState(Controller.PIE_MENU_ACTIVE) and -1	 or 2);

			PrimitiveMan:DrawBitmapPrimitive(self.rootParentController.Player, drawPosition, self.magazineAmmoIcon, math.pi, 0, true, true);
			drawPosition = drawPosition + Vector(distanceBetweenIconAndText, -self.magazineAmmoIcon:GetSpriteHeight() * 0.5);
			PrimitiveMan:DrawTextPrimitive(self.rootParentController.Player, drawPosition, (self.infiniteMagazines and "Infinite" or tostring(self.currentMagazineCount + 1)), true, 0);
		end

		-- Give the root parent a magazine if the timer is ready and they don't already have a copy of the magazine.
		if holdingMagazine or hasInventoryMagazine then
			self.magazineReplenishTimer:Reset();
		elseif self.magazineReplenishTimer:IsPastSimTimeLimit() then
			self:replenishMagazine();
			self.magazineReplenishTimer:Reset();
		end

		-- Draw magazine replenish icons, and delete the Attachable in the case where the icons are finished drawing and the current magazine count is <= 0, but the Attachable needed to stick around to draw the icons.
		if self.HUDVisible and not self.magazineReplenishGUITimer:IsPastSimTimeLimit() then
			local magazineReplenishIconPos = self.rootParent.AboveHUDPos + Vector(25, 24);
			PrimitiveMan:DrawBitmapPrimitive(self.rootParentController.Player, magazineReplenishIconPos, self.magazineReplenishIcon, math.pi, 0, true, true);
			PrimitiveMan:DrawBitmapPrimitive(self.rootParentController.Player, magazineReplenishIconPos + Vector(self.magazineReplenishIcon:GetSpriteWidth(), 0), self.magazineReplenishPlusIcon, math.pi, 0, true, true);
		elseif self.currentMagazineCount <= 0 and self.magazineReplenishGUITimer:IsPastSimTimeLimit() then
			self.ToDelete = true;
		end
		
		self.magazinePreviouslyHeldByRootParent = holdingMagazine and self.rootParent.EquippedItem or nil;
	end
end

function Destroy(self)
	if self.rootParent and MovableMan:ValidMO(self.rootParent) then
		self.rootParent:RemoveNumberValue(self.bandolierKey);
	end

	if self.currentMagazineCount > 0 then
		local bandolierPosition = self.Pos;
		local bandolierVel = self.Vel;
		local bandolierRotAngle = self.RotAngle;
		local bandolierAngularVel = self.AngularVel;
		
		if self.magazinePreviouslyHeldByRootParent then
			if MovableMan:ValidMO(self.magazinePreviouslyHeldByRootParent) and not self.magazinePreviouslyHeldByRootParent:IsActivated() then
				self.magazinePreviouslyHeldByRootParent.ToDelete = true;
				self:modifyMagazineCount(1);
				
				bandolierPosition = self.magazinePreviouslyHeldByRootParent.Pos;
				bandolierVel = self.magazinePreviouslyHeldByRootParent.Vel;
				bandolierRotAngle = self.magazinePreviouslyHeldByRootParent.RotAngle;
				bandolierAngularVel = self.magazinePreviouslyHeldByRootParent.AngularVel;
			end
		end
		
		if self.currentMagazineCount > 0 then
			self.bandolierObjectForDropping:SetNumberValue("MagazinesRemainingInBandolier", self.currentMagazineCount);
			
			self.bandolierObjectForDropping.Pos = bandolierPosition;
			self.bandolierObjectForDropping.Vel = bandolierVel;
			self.bandolierObjectForDropping.RotAngle = bandolierRotAngle;
			self.bandolierObjectForDropping.AngularVel = bandolierAngularVel;
			
			self.bandolierObjectForDropping.Mass = self.bandolierMass + (self.magazineMass * self.currentMagazineCount);
			
			MovableMan:AddItem(self.bandolierObjectForDropping);
		end
	end
end