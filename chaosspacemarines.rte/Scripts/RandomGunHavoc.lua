function Create(self)
	local gun
	if math.random() > 0.5 then
		gun = CreateHDFirearm("chaosspacemarines.rte/Autocannon Astartes")
	else
		gun = CreateHDFirearm("chaosspacemarines.rte/Heavy Bolter")
	end
	self:AddInventoryItem(gun)
end
