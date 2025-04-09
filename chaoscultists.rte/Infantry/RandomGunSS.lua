function Create(self)
    local rand = math.random() * 3
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("ChaosCultists.rte/Lasrifle Scab Shooter");
    elseif rand < 2 then
        gun = CreateHDFirearm("ChaosCultists.rte/Graia MK IV Autogun");
    else
        gun = CreateHDFirearm("ChaosCultists.rte/Vraks MK VII Autogun");
    end
    self:AddInventoryItem(gun)
end