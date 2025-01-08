function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHDFirearm("SpaceMarines.rte/Astartes Knife");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Chainsword");
    end
    self:AddInventoryItem(gun)
end