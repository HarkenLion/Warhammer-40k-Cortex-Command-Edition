ActorHolder = {}

function Create(self)
	if IsAHuman(self:GetRootParent()) then
		self.parent = ToAHuman(self:GetRootParent())
	else
		self.parent = nil
	end

	self.checkTimer = Timer() --Sometimes the turret delets itslef and doesn't run its Destroy script, so here's a temporary fix
	self.checkDelay = 100
	self.Sharpness = 1
end

function Update(self)
	if self.parent then
		if self.checkTimer:IsPastSimMS(self.checkDelay) then
			if self.Sharpness == 2 then
				self.Sharpness = 1
			else
				ActorHolder.delet(self)
			end
			self.checkTimer:Reset()
		end

		if not self:IsAttached() then
			ActorHolder.delet(self)
		end

		if self.PresetName == "Reloader Holder" then
			self.RotAngle = self.RotAngle - self.FlipFactor * 1 * 0.35
		end
	else
		self.ToDelete = true
	end
end

function ActorHolder.delet(self)
	if self.parent then
		self.parent.AIMode = Actor.AIMODE_SENTRY
		self.parent:SetControllerMode(2, self.parent:GetController().Player)
		self.parent.HUDVisible = true
		self.ToDelete = true
	end
end
