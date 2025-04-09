function Create(self)
	local gun
	if math.random() > 0.5 then
		gun = CreateHDFirearm("ChaosCultists.rte/Lasrifle")
	else
		gun = CreateHDFirearm("ChaosCultists.rte/Columnus Mk V Infantry Autogun")
	end
	self:AddInventoryItem(gun)
end
