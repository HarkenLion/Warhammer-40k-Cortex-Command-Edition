function Create(self) end

function Update(self)
	self:MoveOutOfTerrain(1)

	--	if self:IsPlayerControlled() == false then
	--		self:SetControllerMode(Controller.CIM_AI, -1);
	--	end
end
