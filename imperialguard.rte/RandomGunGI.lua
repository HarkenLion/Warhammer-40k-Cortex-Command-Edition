function Create(self)
    local rand = math.random() * 3
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("ImperialGuard.rte/Lasrifle");
    elseif rand < 2 then
        gun = CreateHDFirearm("ImperialGuard.rte/Kantrael MG Ia Infantry Lasgun");
	else 
        gun = CreateHDFirearm("ImperialGuard.rte/Kantrael Graia MG Ia Infantry Lasgun");
    end
    self:AddInventoryItem(gun)
end