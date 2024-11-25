function Create(self)
	self.origMass = math.floor(self.Mass * 100 / self.RoundCount) * 0.01 --Original mass is the mass of all the bullets inside
end

function Update(self)
	self.Mass = self.origMass * self.RoundCount
end
