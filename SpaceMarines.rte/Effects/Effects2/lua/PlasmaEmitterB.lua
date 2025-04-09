function Update(self)
	--if self.ID ~= self.RootID then
	local eff = CreateMOPixel("Plasma Deco B " .. math.random(2), "Untitled.rte")
	eff.Pos = self.Pos
	eff.Vel = self.Vel * math.random()
	MovableMan:AddParticle(eff)
	--end
end
