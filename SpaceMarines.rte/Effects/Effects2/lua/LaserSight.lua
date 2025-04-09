function Update(self)
	local eff = CreateMOPixel("Laser Pointer Deco Red " .. math.random(3), "Untitled.rte")
	eff.Pos = self.Pos
	MovableMan:AddParticle(eff)
end
