function Create(self)
    local rand = math.random() * 3
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("SpaceMarines.rte/ChainswordBS");
    elseif rand < 2 then
        gun = CreateHDFirearm("SpaceMarines.rte/Death Watch Kraken Bolter");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Heavy Bolt Pistol");
    end
    self:AddInventoryItem(gun)
end
