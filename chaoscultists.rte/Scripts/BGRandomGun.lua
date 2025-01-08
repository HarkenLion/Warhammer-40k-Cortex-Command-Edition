function Create(self)
	local rand = math.random() * 3
	local gun
	if rand < 1 then
		gun = CreateHDFirearm("spacemarines.rte/Primaris Bolter")
	elseif rand < 2 then
		gun = CreateHDFirearm("spacemarines.rte/Assault Bolter")
	else
		gun = CreateHDFirearm("spacemarines.rte/Melta Gun")
	end
	self:AddInventoryItem(gun)
end
