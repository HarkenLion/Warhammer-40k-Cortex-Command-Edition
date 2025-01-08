function Create(self)
	self.lockedFrame = math.random(self.FrameCount) - 1;
	self.Frame = self.lockedFrame;
end

function Update(self)
	self.Frame = self.lockedFrame;
end