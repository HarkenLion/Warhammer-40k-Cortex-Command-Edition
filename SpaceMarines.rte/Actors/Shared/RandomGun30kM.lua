function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHDFirearm("SpaceMarines.rte/Phobos Bolter 30k M");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Plasma Rifle M");
    end
    self:AddInventoryItem(gun)
end