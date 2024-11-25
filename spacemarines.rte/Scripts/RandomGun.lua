function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHDFirearm("spacemarines.rte/Phobos Bolter Variant");
    else
        gun = CreateHDFirearm("spacemarines.rte/Bolt Carbine");
    end
    self:AddInventoryItem(gun)
end