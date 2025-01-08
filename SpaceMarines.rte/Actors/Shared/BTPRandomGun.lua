function Create(self)
    local rand = math.random() * 4
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("SpaceMarines.rte/Black Templars Primaris Bolter");
    elseif rand < 2 then
        gun = CreateHDFirearm("SpaceMarines.rte/Black Templars Primaris Bolter");
    elseif rand < 3 then
        gun = CreateHDFirearm("SpaceMarines.rte/Dark Angels Stalker Bolt Rifle");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Auto Bolt Rifle");
    end
    self:AddInventoryItem(gun)
end
