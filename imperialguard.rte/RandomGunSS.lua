function Create(self)
    local rand = math.random() * 4
    local gun
    if rand < 1 then
        gun = CreateHDFirearm("ImperialGuard.rte/Voss MKV");
    elseif rand < 2 then
        gun = CreateHDFirearm("ImperialGuard.rte/Hellgun");
	elseif rand < 3 then
        gun = CreateHDFirearm("ImperialGuard.rte/Hotshot Lasgun");
    else
        gun = CreateHDFirearm("ImperialGuard.rte/Hotshot Volley Lasgun");
    end
    self:AddInventoryItem(gun)
end