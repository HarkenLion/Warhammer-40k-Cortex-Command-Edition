function Create(self)
    local rand = math.random() * 3
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("imperialguard.rte/Lasrifle");
    elseif rand < 2 then
        gun = CreateHDFirearm("imperialguard.rte/Kantrael MG Ia Infantry Lasgun");
	else 
        gun = CreateHDFirearm("imperialguard.rte/Kantrael Graia MG Ia Infantry Lasgun");
    end
    self:AddInventoryItem(gun)
end