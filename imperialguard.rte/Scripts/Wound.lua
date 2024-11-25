function Create(self)
	self.f = math.floor(math.random() * 6)
	self.Frame = self.f
end

function Update(self)
	self.Frame = self.f
end
