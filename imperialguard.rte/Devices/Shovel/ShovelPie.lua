function RoninCreateSandbag(pieMenu, pieSlice, pieMenuOwner)
	if pieMenuOwner:GetNumberValue("igshovelresource") >= 10 then
		pieMenuOwner = ToAHuman(pieMenuOwner)
		pieMenuOwner:RemoveNumberValue("igshovelresource")
		pieMenuOwner:AddInventoryItem(CreateThrownDevice("imperialguard.rte/Sandbag"))
		pieMenuOwner:EquipNamedDevice("Sandbag", true)
	else
		local errorSound = CreateSoundContainer("Error", "Base.rte")
		errorSound:Play(pieMenuOwner.Pos, pieMenuOwner:GetController().Player)
	end
end
