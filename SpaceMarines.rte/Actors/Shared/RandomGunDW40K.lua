function Create(self)
    local rand = math.random() * 3
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("SpaceMarines.rte/Death Watch Bolter");
    elseif rand < 2 then
        gun = CreateHDFirearm("SpaceMarines.rte/Death Watch Kraken Bolter");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Heavy Bolt Rifle");
    end
    self:AddInventoryItem(gun)
end
