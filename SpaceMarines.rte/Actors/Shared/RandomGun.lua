function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHDFirearm("SpaceMarines.rte/Phobos Bolter Variant");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Bolt Carbine");
    end
    self:AddInventoryItem(gun)
end