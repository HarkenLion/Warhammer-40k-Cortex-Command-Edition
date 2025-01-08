function Create(self)
	self.origSize = self.Scale
end

function Update(self)
	self.Scale = self.Scale * (self.Lifetime / 1000)
end

function Destroy(self)
	self.Scale = 0
end
