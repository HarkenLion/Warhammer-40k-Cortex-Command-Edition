function Create(self)
    self.LTimer = Timer();
end

function Update(self)
    if self.LTimer:IsPastSimMS(1) then
	    self:GibThis();
    end
end