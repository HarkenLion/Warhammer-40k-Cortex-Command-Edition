function Create(self)
    local rand = math.random() * 3
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("spacemarines.rte/Heavy Bolt Rifle");
    elseif rand < 2 then
        gun = CreateHDFirearm("spacemarines.rte/Auto Bolt Rifle");
    else
        gun = CreateHDFirearm("spacemarines.rte/Bolt Carbine");
    end
    self:AddInventoryItem(gun)
end
