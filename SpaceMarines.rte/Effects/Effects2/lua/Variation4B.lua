function Create(self)
	self.disp = math.floor(math.random() * 4)
end

function Update(self)
	self.Frame = self.disp
end
