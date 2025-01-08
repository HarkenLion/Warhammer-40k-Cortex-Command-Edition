local allSlices = {
	"Helldiver Beacon Artillery Light",
	"Helldiver Beacon Artillery Heavy",
	"Helldiver Beacon Strike Light",
	"Helldiver Beacon Strike Heavy"
}

function SelectArtilleryLight(pieMenuOwner, pieMenu, pieSlice)
	local gun = pieMenuOwner.EquippedItem;
	if gun then
		ToMOSRotating(gun):SetStringValue("BeaconMode", "ArtilleryLight");

		pieSlice.Enabled = false;
		local pieSlicePresetNamesToEnable = {
			"Helldiver Beacon Artillery Heavy",
			"Helldiver Beacon Strike Light",
			"Helldiver Beacon Strike Heavy"
		};
		for _, pieSlicePresetNameToEnable in pairs(pieSlicePresetNamesToEnable) do
			local pieSliceToEnable = pieMenu:GetFirstPieSliceByPresetName(pieSlicePresetNameToEnable);
			if pieSliceToEnable ~= nil then
				pieSliceToEnable.Enabled = true;
			end
		end
	end
end

function SelectArtilleryHeavy(pieMenuOwner, pieMenu, pieSlice)
	local gun = pieMenuOwner.EquippedItem;
	if gun then
		ToMOSRotating(gun):SetStringValue("BeaconMode", "ArtilleryHeavy");

		pieSlice.Enabled = false;
		local pieSlicePresetNamesToEnable = {
			"Helldiver Beacon Artillery Light",
			"Helldiver Beacon Strike Light",
			"Helldiver Beacon Strike Heavy"
		};
		for _, pieSlicePresetNameToEnable in pairs(pieSlicePresetNamesToEnable) do
			local pieSliceToEnable = pieMenu:GetFirstPieSliceByPresetName(pieSlicePresetNameToEnable);
			if pieSliceToEnable ~= nil then
				pieSliceToEnable.Enabled = true;
			end
		end
	end
end

function SelectStrikeLight(pieMenuOwner, pieMenu, pieSlice)
	local gun = pieMenuOwner.EquippedItem;
	if gun then
		ToMOSRotating(gun):SetStringValue("BeaconMode", "StrikeLight");

		pieSlice.Enabled = false;
		local pieSlicePresetNamesToEnable = {
			"Helldiver Beacon Artillery Light",
			"Helldiver Beacon Artillery Heavy",
			"Helldiver Beacon Strike Heavy"
		};
		for _, pieSlicePresetNameToEnable in pairs(pieSlicePresetNamesToEnable) do
			local pieSliceToEnable = pieMenu:GetFirstPieSliceByPresetName(pieSlicePresetNameToEnable);
			if pieSliceToEnable ~= nil then
				pieSliceToEnable.Enabled = true;
			end
		end
	end
end

function SelectStrikeHeavy(pieMenuOwner, pieMenu, pieSlice)
	local gun = pieMenuOwner.EquippedItem;
	if gun then
		ToMOSRotating(gun):SetStringValue("BeaconMode", "StrikeHeavy");

		pieSlice.Enabled = false;
		local pieSlicePresetNamesToEnable = {
			"Helldiver Beacon Artillery Light",
			"Helldiver Beacon Artillery Heavy",
			"Helldiver Beacon Strike Light"
		};
		for _, pieSlicePresetNameToEnable in pairs(pieSlicePresetNamesToEnable) do
			local pieSliceToEnable = pieMenu:GetFirstPieSliceByPresetName(pieSlicePresetNameToEnable);
			if pieSliceToEnable ~= nil then
				pieSliceToEnable.Enabled = true;
			end
		end
	end
end