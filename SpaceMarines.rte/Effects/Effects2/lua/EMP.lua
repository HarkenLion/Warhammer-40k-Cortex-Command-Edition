function Create(self)
	self.timer = Timer()
	self.random = math.random(30)
end

function Update(self)
	if self.timer:IsPastSimMS(self.random) then
		-- bouncy stuff

		self.Vel = self.Vel * 0.8 + Vector(self.Vel.Largest * 0.3, 0):RadRotate(2 * math.pi * math.random())
		self.random = math.random(50)
		self.timer:Reset()

		-- if the actor is a robot, disable it!

		for actor in MovableMan.Actors do
			if
				string.find(actor.PresetName, "Robot")
				or string.find(actor.PresetName, "Drone")
				or string.find(actor.PresetName, "Actors - Turret")
				or string.find(actor.PresetName, "Mech")
				or string.find(actor.PresetName, "Dummy")
				or string.find(actor.PresetName, "Dreadnought")
				or string.find(actor.PresetName, "Whitebot")
				or string.find(actor.PresetName, "Patchbot")
				or string.find(actor.PresetName, "UA-")
				or actor.PresetName == "Techion Silver Man"
				or actor.PresetName == "Blast Runner"
				or actor.PresetName == "Behemoth"
				or actor.ClassName == "ACDropShip"
				or actor.ClassName == "ACRocket"
				or actor.ClassName == "ADoor"
			then
				local avgx = actor.Pos.X - self.Pos.X
				local avgy = actor.Pos.Y - self.Pos.Y
				local dist = math.sqrt(avgx ^ 2 + avgy ^ 2)
				if dist < 50 then
					if actor.Health > 0 then
						actor:FlashWhite(10 + math.random(20))

						actor:GetController():SetState(Controller.BODY_JUMP, false)
						actor:GetController():SetState(Controller.BODY_JUMPSTART, false)
						actor:GetController():SetState(Controller.BODY_CROUCH, true)
						actor:GetController():SetState(Controller.PIE_MENU_ACTIVE, false)
						actor:GetController():SetState(Controller.WEAPON_FIRE, false)
						actor:GetController():SetState(Controller.AIM_SHARP, false)

						if math.random() < 0.5 then
							actor:GetController():SetState(Controller.MOVE_RIGHT, true)
							actor:GetController():SetState(Controller.MOVE_LEFT, false)
						else
							actor:GetController():SetState(Controller.MOVE_LEFT, true)
							actor:GetController():SetState(Controller.MOVE_RIGHT, false)
						end

						actor.Health = actor.Health - (100 / actor.Mass + 2)
					end
				end
			end
		end
	end
end
