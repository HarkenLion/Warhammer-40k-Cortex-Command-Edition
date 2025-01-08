function Create(self)
	local gun
	if math.random() > 0.5 then
		gun = CreateHDFirearm("chaoscultists.rte/Heavy Stubber")
	else
		gun = CreateHDFirearm("chaoscultists.rte/Hellgun")
	end
	self:AddInventoryItem(gun)
end
