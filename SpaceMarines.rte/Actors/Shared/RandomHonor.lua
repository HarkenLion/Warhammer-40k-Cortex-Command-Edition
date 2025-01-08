function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHDFirearm("SpaceMarines.rte/Honor Guard Bolter");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Powersword Salamander BladeGuard");
    end
    self:AddInventoryItem(gun)
end