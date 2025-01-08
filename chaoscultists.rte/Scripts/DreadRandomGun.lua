function Create(self)
	local gun
	if math.random() > 0.5 then
		gun = CreateHDFirearm("spacemarines.rte/RedemptorUM Heavy Bolter Hand")
	else
		gun = CreateHDFirearm("spacemarines.rte/RedemptorUM Heavy Flamer Hand")
	end
	self:AddInventoryItem(gun)
end
