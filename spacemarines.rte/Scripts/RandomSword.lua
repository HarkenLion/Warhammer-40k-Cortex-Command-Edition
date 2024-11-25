function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHDFirearm("spacemarines.rte/Astartes Knife");
    else
        gun = CreateHDFirearm("spacemarines.rte/Chainsword");
    end
    self:AddInventoryItem(gun)
end