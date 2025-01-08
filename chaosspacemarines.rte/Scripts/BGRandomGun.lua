function Create(self)
	local rand = math.random() * 3
	local gun
	if rand < 1 then
		gun = CreateHDFirearm("chaosspacemarines.rte/Primaris Bolter")
	elseif rand < 2 then
		gun = CreateHDFirearm("chaosspacemarines.rte/Assault Bolter")
	else
		gun = CreateHDFirearm("chaosspacemarines.rte/Melta Gun")
	end
	self:AddInventoryItem(gun)
end
