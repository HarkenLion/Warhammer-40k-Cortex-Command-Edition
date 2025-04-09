function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHDFirearm("SpaceMarines.rte/RedemptorUM Heavy Bolter Hand");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/RedemptorUM Heavy Flamer Hand");
    end
    self:AddInventoryItem(gun)
end