function SwitchHand(pieMenuOwner, pieMenu, pieSlice)
	local device = pieMenuOwner.EquippedItem
	if device and IsHeldDevice(device) then
		local isDualWieldable = ToHeldDevice(device):IsDualWieldable()
		ToHeldDevice(device):SetDualWieldable(not isDualWieldable)
		ToHeldDevice(device):SetOneHanded(not isDualWieldable)

		local pieMenuToAdd = pieSlice.PresetName == "One Handed" and "Two Handed" or "One Handed"
		pieMenu:RemovePieSlicesByPresetName(pieSlice.PresetName)
		pieMenu:AddPieSlice(CreatePieSlice(pieMenuToAdd, "ImporianArmada.rte"), device)
	end
end
