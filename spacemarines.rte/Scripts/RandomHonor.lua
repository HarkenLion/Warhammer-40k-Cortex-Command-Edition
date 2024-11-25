function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHDFirearm("spacemarines.rte/Honor Guard Bolter");
    else
        gun = CreateHDFirearm("spacemarines.rte/Powersword Salamander BladeGuard");
    end
    self:AddInventoryItem(gun)
end