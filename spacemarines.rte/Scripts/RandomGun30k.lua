function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHDFirearm("spacemarines.rte/Phobos Bolter 30k");
    else
        gun = CreateHDFirearm("spacemarines.rte/Plasma Rifle");
    end
    self:AddInventoryItem(gun)
end