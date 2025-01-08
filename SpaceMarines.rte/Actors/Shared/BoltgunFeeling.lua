function Create(self)
	AudioMan:PlayMusic("SpaceMarines.rte/Actors/Shared/Bolt.ogg", -1, -1.0)
end
function Update(self)
	if self.Health <= 0 then
		AudioMan:StopMusic()
	end
end