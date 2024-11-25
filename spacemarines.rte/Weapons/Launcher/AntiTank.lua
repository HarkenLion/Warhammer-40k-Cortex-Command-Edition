
function Destroy(self)
	for actor in MovableMan.Actors do
		local dist = SceneMan:ShortestDistance(self.Pos, actor.Pos, true).Magnitude
		if dist < 35 and actor.Mass > 300 then
			ToActor(actor).Health = ToActor(actor).Health - 35;
		end
	end
end