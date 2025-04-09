function Create(self)
	local gun
	if math.random() > 0.5 then
		gun = CreateHDFirearm("ChaosSpaceMarines.rte/Autocannon Astartes")
	else
		gun = CreateHDFirearm("ChaosSpaceMarines.rte/Heavy Bolter")
	end
	self:AddInventoryItem(gun)
end
