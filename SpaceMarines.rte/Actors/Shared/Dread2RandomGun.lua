function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHDFirearm("SpaceMarines.rte/PlasmaCannon");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Dreadnought Autocannon");
    end
    self:AddInventoryItem(gun)
end