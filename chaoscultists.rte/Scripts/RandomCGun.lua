function Create(self)
	local gun
	if math.random() > 0.5 then
		gun = CreateHDFirearm("spacemarines.rte/Plasma Pistol Company Champion")
	else
		gun = CreateHDFirearm("spacemarines.rte/Heavy Bolt Pistol")
	end
	self:AddInventoryItem(gun)
end
