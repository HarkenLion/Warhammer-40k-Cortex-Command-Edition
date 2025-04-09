function Create(self)
    local rand = math.random() * 6
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("SpaceMarines.rte/Astartes Knife");
    elseif rand < 2 then
        gun = CreateHDFirearm("SpaceMarines.rte/Astartes Knife");
    elseif rand < 3 then
        gun = CreateHDFirearm("SpaceMarines.rte/Astartes Knife");
    elseif rand < 4 then
        gun = CreateHDFirearm("SpaceMarines.rte/Astartes Knife");
    elseif rand < 5 then
        gun = CreateHDFirearm("SpaceMarines.rte/Chainsword");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Chainsword");
    end
    self:AddInventoryItem(gun)
end
