function Create(self)
	local gun
	if math.random() > 0.5 then
		gun = CreateHDFirearm("ChaosCultists.rte/Heavy Stubber")
	else
		gun = CreateHDFirearm("ChaosCultists.rte/Hellgun")
	end
	self:AddInventoryItem(gun)
end
