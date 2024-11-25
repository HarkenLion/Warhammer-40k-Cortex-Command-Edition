function Update(self)
	if not self:IsAttached() then
		self:GibThis()
	end
end
