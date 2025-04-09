local function isThisMe(self, object)
	object:SendMessage("is_this_me", {});
	local flag = self:HasStringValue("IsThisMe");

	if flag then
		self:RemoveStringValue("IsThisMe");
	end

	if object:HasStringValue("IsThisMe") then
		object:RemoveStringValue("IsThisMe");
	end

	return flag;
end

function Create(self)
	self.isThisMe = isThisMe;
	self.magazines = self:HasNumberValue("RepresentingMagazines") and self:GetNumberValue("RepresentingMagazines") or 1;
	self.magazineAmmoIcon = CreateMOSParticle("Ammo Icon", "Base.rte");
end

function OnAttach(self, newParent)
	local rootParent = newParent:GetRootParent();
	self:Activate();

	if rootParent and IsAHuman(rootParent) then
		rootParent = ToAHuman(rootParent);
		self.rootParent = rootParent;
	end
end

function Update(self, oldParent)
	if self.rootParent and not self:isThisMe(self:GetRootParent()) then
		self:Activate();
		local rootParent = self.rootParent;
		local controller = rootParent:GetController();

		for item in rootParent.Inventory do
			if not (item.ClassName == self.ClassName and item.PresetName == self.PresetName and item.ModuleName == self.ModuleName) then
				break;
			end

			self.magazines = self.magazines + item:GetNumberValue("RepresentingMagazines");
			self.rootParent:RemoveInventoryItemAtIndex(0);
			self:SetNumberValue("RepresentingMagazines", self.magazines);
		end
		
		-- Draw the magazine ammo icon and text.
		if rootParent.HUDVisible and rootParent:IsPlayerControlled() and not (rootParent.Jetpack and rootParent.Jetpack:IsEmitting()) then
			local distanceBetweenIconAndText = 2 + math.floor(self.magazineAmmoIcon:GetSpriteWidth() * 0.5);
			local drawPosition = rootParent.AboveHUDPos + Vector(-distanceBetweenIconAndText, controller:IsState(Controller.PIE_MENU_ACTIVE) and -1 or 2);

			PrimitiveMan:DrawBitmapPrimitive(controller.Player, drawPosition, self.magazineAmmoIcon, math.pi, 0, true, true);
			drawPosition = drawPosition + Vector(distanceBetweenIconAndText, -self.magazineAmmoIcon:GetSpriteHeight() * 0.5);
			PrimitiveMan:DrawTextPrimitive(controller.Player, drawPosition, tostring(self.magazines), true, 0);
		end
	end
end

function OnMessage(self, message, context)
	if "is_this_me" == message then
		self:SetStringValue("IsThisMe", "YEAH");
	elseif "add_magazines" then
		if type(context) == "number" then
			self.magazines = self.magazines + context;
			self:SetNumberValue("RepresentingMagazines", self.magazines);
		end
	end
end

function OnDetach(self, oldParent)
	local beingHeld = self:IsActivated();
	local itemInReach = ToAHuman(oldParent:GetRootParent()).ItemInReach;
	local itemInReachGrabbed = not not (itemInReach and not MovableMan:ValidMO(itemInReach));

	if (beingHeld or itemInReachGrabbed) then
		if itemInReachGrabbed then
			local item = itemInReach;

			if item.ClassName == self.ClassName and item.PresetName == self.PresetName and item.ModuleName == self.ModuleName then
				self.ToDelete = true;
				item:SendMessage("add_magazines", self.magazines);
			end
		end
	else
		if self.rootParent and self:isThisMe(self:GetRootParent()) then
			local rootParent = self.rootParent;
			self.rootParent = nil;

			if rootParent and IsAHuman(rootParent) and self.magazines >= 2 then
				rootParent = ToAHuman(rootParent);
			
				rootParent.UpperBodyState = AHuman.WEAPON_READY;

				local clone = self:Clone();
				clone:SetNumberValue("RepresentingMagazines", self.magazines - 1);

				local items = {};

				for item in rootParent.Inventory do
					table.insert(items, rootParent:RemoveInventoryItemAtIndex(0));
				end

				rootParent:AddInventoryItem(clone);

				for _, item in ipairs(items) do
					if item then
						rootParent:AddInventoryItem(item);
					end
				end

				self.magazines = 1;
				self:SetNumberValue("RepresentingMagazines", self.magazines);
			end
		end
	end
end