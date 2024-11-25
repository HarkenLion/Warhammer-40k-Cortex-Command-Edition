function Create(self)
	--Find out who shot the weapon by finding the closest actor within 30 pixels.

	local curdist = 75

	for i = 1, MovableMan:GetMOIDCount() - 1 do
		gun = MovableMan:GetMOFromID(i)
		if
			gun.PresetName == "Necron Broadside Control"
			and gun.ClassName == "HDFirearm"
			and (gun.Pos - self.Pos).Magnitude < curdist
		then
			actor = MovableMan:GetMOFromID(gun.RootID)
			if MovableMan:IsActor(actor) then
				self.parent = ToActor(actor)
				self.parentItem = ToHDFirearm(gun)
			end
		end
	end

	for actor in MovableMan.Actors do
		if math.abs((self.Pos - actor.Pos).Magnitude) < curdist and actor.PresetName == "Necron Ghost Ark" then
			self.parent2 = actor
		end
	end
end

function Update(self)
	local vect = Vector(1700, 0)
	local rayL = 0

	if MovableMan:IsActor(self.parent) then
		vect = vect:RadRotate(self.parent:GetAimAngle(true))
		vect = vect:SetMagnitude(1700)
		rayL = SceneMan:CastObstacleRay(
			Vector(self.Pos.X, self.Pos.Y),
			vect,
			vect,
			vect,
			self.parent2.ID,
			self.parent2.Team,
			0,
			3
		)
	else
		self.ToDelete = true
	end

	if rayL > 0 then
		local part = CreateMOPixel("GhostBoat Target Reticle")
		part.Pos = SceneMan:GetLastRayHitPos()
		MovableMan:AddParticle(part)
	end
end
