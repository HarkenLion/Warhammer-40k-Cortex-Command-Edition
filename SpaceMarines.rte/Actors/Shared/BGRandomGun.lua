function Create(self)
    local rand = math.random() * 3
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("SpaceMarines.rte/Heavy Bolt Rifle");
    elseif rand < 2 then
        gun = CreateHDFirearm("SpaceMarines.rte/Auto Bolt Rifle");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Bolt Carbine");
    end
    self:AddInventoryItem(gun)
end
