function OnAttach(self, newParent)
	local rootParent = self:GetRootParent()
	if IsActor(rootParent) and MovableMan:IsActor(rootParent) then
		local pieSliceToAddPresetName = self:IsDualWieldable() and "Two Handed" or "One Handed"
		ToActor(rootParent).PieMenu:AddPieSliceIfPresetNameIsUnique(
			CreatePieSlice(pieSliceToAddPresetName, self.ModuleName),
			self
		)
	end
end

function Create(self)
	-- OnAttach doesn't get run if the device was added to a brain in edit mode, so re-run it here for safety.
	if OnAttach then
		OnAttach(self)
	end
end
