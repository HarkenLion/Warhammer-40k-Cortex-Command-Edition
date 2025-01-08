function Create(self)
    local rand = math.random() * 4
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("SpaceMarines.rte/Bolt Rifle");
    elseif rand < 2 then
        gun = CreateHDFirearm("SpaceMarines.rte/Bolt Rifle");
    elseif rand < 3 then
        gun = CreateHDFirearm("SpaceMarines.rte/Stalker Bolt Rifle");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Auto Bolt Rifle");
    end
    self:AddInventoryItem(gun)
end
