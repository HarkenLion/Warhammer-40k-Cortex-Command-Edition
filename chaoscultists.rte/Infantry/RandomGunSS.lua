function Create(self)
    local rand = math.random() * 3
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("chaoscultists.rte/Lasrifle Scab Shooter");
    elseif rand < 2 then
        gun = CreateHDFirearm("chaoscultists.rte/Graia MK IV Autogun");
    else
        gun = CreateHDFirearm("chaoscultists.rte/Vraks MK VII Autogun");
    end
    self:AddInventoryItem(gun)
end