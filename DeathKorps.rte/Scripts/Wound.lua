function Create(self)
	self.f = math.floor(math.random() * 6)
	self.Frame = self.f
end

function ThreadedUpdate(self)
	self.Frame = self.f
end
