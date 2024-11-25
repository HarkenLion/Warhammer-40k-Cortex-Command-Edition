function Create(self)
    local rand = math.random() * 3
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("spacemarines.rte/ChainswordBS");
    elseif rand < 2 then
        gun = CreateHDFirearm("spacemarines.rte/Death Watch Kraken Bolter");
    else
        gun = CreateHDFirearm("spacemarines.rte/Heavy Bolt Pistol");
    end
    self:AddInventoryItem(gun)
end
