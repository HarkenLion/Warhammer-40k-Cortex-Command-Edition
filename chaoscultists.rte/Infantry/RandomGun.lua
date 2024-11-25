function Create(self)
	local gun
	if math.random() > 0.5 then
		gun = CreateHDFirearm("chaoscultists.rte/Lasrifle")
	else
		gun = CreateHDFirearm("chaoscultists.rte/Columnus Mk V Infantry Autogun")
	end
	self:AddInventoryItem(gun)
end
