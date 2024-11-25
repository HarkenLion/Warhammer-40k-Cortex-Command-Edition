function Create(self)
	self.LifeTime = 99999
	self.AirResistance = 0 --0.025
	self.IgnoresTeamHits = true
	local getx = self:GetNumberValue("TargX")
	local gety = self:GetNumberValue("TargY")
	self.hitvect = Vector(getx, gety)
	print("node made")

	self.LTimer = Timer()

	for actor in MovableMan:GetMOsInRadius(self.Pos, 10) do
		if actor.Team == self.Team and actor.ClassName == "ACrab" then
			self.parent = ToActor(actor)
			for attachable in self.parent.Attachables do
				if attachable.ClassName == "Actors - Turret" then
					self.useturret = ToAttachable(attachable)
				end
			end
			ToActor(actor):SetNumberValue("ArtilleryRequested", 1)
			print("found anchor unit")
		end
	end

	local gun = ToACrab(self.parent).EquippedItem
	self.usegun = ToHDFirearm(gun)

	function self.artillery_aimandfire(gravity, speed, startPos, targetPos)
		grav = gravity
		local speed2 = speed * speed
		local speed4 = speed * speed * speed * speed
		local x = targetPos.X - startPos.X
		local y = targetPos.Y - startPos.Y

		local highang = math.atan((speed2 + math.sqrt(speed4 - grav * (grav * x * x + 2 * speed2 * y))) / (grav * x)) --math.atan(speed2+math.sqrt(speed4-grav*(grav*x*x+2*speed2*y))) --
		return highang
	end
end

function Update(self)
	if self.parent then
		local getact = self.parent
		local getspeed = self.usegun:GetAIFireVel()
		local getgrav = self.usegun:GetBulletAccScalar()
		local findang = self.artillery_aimandfire(
			getgrav * 20 * GetPPM(),
			getspeed * GetPPM(),
			self.usegun.MuzzlePos,
			self.hitvect
		)
		local uang = findang * getact.FlipFactor
		getact:SetAimAngle(uang)
		getact:GetController():SetState(Controller.AIM_UP, false)
		getact:GetController():SetState(Controller.AIM_DOWN, false)
		self.PinStrength = 1000
		if self.LTimer:IsPastSimMS(2000) then
			getact:GetController():SetState(Controller.WEAPON_FIRE, true)
			getact:SetNumberValue("ArtilleryRequested", 0)
			self.ToDelete = true
			print("fired")
		else
			self.ToDelete = false
			self.ToSettle = false
		end
	end
end
