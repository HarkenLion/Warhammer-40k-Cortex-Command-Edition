function Create(self)
    local rand = math.random() * 5
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("SpaceMarines.rte/Death Angels Bolter");
    elseif rand < 2 then
        gun = CreateHDFirearm("SpaceMarines.rte/Death Angels Bolter");
    elseif rand < 3 then
        gun = CreateHDFirearm("SpaceMarines.rte/Plasma Rifle");
    elseif rand < 4 then
        gun = CreateHDFirearm("SpaceMarines.rte/Soundstrike Launcher");
    else
        gun = CreateHDFirearm("SpaceMarines.rte/Space Marines Flamer");
    end
    self:AddInventoryItem(gun)
end
