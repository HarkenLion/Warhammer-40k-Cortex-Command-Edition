function Create(self)
	local gun
	if math.random() > 0.5 then
		gun = CreateHDFirearm("spacemarines.rte/PlasmaCannon")
	else
		gun = CreateHDFirearm("spacemarines.rte/Dreadnought Autocannon")
	end
	self:AddInventoryItem(gun)
end
