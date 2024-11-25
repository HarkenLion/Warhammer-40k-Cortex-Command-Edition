function Create(self)
    local gun;
    if math.random() > 0.5 then
        gun = CreateHeldDevice("spacemarines.rte/Medusan Inmortals Combat Shield");
    else
        gun = CreateHeldDevice("spacemarines.rte/Medusan Inmortals Combat Shield");
    end
    self:AddInventoryItem(gun)
end