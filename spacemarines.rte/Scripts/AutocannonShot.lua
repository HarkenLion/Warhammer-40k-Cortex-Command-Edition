function Create(self)
	self.strength = 47                   
end

function Update(self)
	local posa = self.Pos
	local posb = self.Pos-self.Vel*0.25
	PrimitiveMan:DrawLinePrimitive(posa,posb,117,1.85)
end