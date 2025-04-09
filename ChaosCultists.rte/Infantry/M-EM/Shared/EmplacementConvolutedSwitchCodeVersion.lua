------ Thanks to Zeta for that amazing hovercraft Bike.

function Create(self)
	if IsACrab(self:GetRootParent()) then
		self.parent = ToACrab(self:GetRootParent())
	else
		self.parent = nil
	end

	if IsAttachable(self:GetParent()) then
		self.motorParent = ToAttachable(self:GetParent())
	else
		self.motorParent = nil
	end

	self.IsPlayer = ActivityMan:GetActivity():IsHumanTeam(self.parent.Team)
	self.switchWhichWay = 0 --0 nil, 1 left, 2 right

	self.crewSize = 3 --How many people can operate this gun.

	self.gunner = nil

	self.reloader = nil
	self.originalReloadTime = self.BaseReloadTime
	self.reloadTimeReducer = 1.5

	self.spotter = nil
	self.originalSharpLength = self.SharpLength
	self.sharpLengthIncreaser = 2
end

function Update(self)
	if self:IsAttached() == true then
		if self.motorParent and self.motorParent:IsAttached() == true then
			------------------------------------- WARNING! hugely cancerous switch code right up ahead! -----------------------------------

			if self.IsPlayer and self.parent:IsPlayerControlled() then
				if self.gunner and self.gunner:IsPlayerControlled() then
					if self.gunner:GetController():IsState(Controller.ACTOR_NEXT) or self.switchWhichWay == 2 then
						ToGameActivity(ActivityMan:GetActivity()):SwitchToNextActor(
							self.gunner:GetController().Player,
							self.gunner.Team,
							self.gunner
						)
						self.switchWhichWay = 2
					elseif self.gunner:GetController():IsState(Controller.ACTOR_PREV) or self.switchWhichWay == 1 then
						ToGameActivity(ActivityMan:GetActivity()):SwitchToPrevActor(
							self.gunner:GetController().Player,
							self.gunner.Team,
							self.gunner
						)
						self.switchWhichWay = 1
					else
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.parent, self.parent.Team, self.Team)
					end
				end

				if self.reloader and self.reloader:IsPlayerControlled() then
					if self.reloader:GetController():IsState(Controller.ACTOR_NEXT) or self.switchWhichWay == 2 then
						ToGameActivity(ActivityMan:GetActivity()):SwitchToNextActor(
							self.reloader:GetController().Player,
							self.reloader.Team,
							self.reloader
						)
						self.switchWhichWay = 2
					elseif self.reloader:GetController():IsState(Controller.ACTOR_PREV) or self.switchWhichWay == 1 then
						ToGameActivity(ActivityMan:GetActivity()):SwitchToPrevActor(
							self.reloader:GetController().Player,
							self.reloader.Team,
							self.reloader
						)
						self.switchWhichWay = 1
					else
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.parent, self.parent.Team, self.Team)
					end
				end

				if self.spotter and self.spotter:IsPlayerControlled() then
					if self.spotter:GetController():IsState(Controller.ACTOR_NEXT) or self.switchWhichWay == 2 then
						ToGameActivity(ActivityMan:GetActivity()):SwitchToNextActor(
							self.spotter:GetController().Player,
							self.spotter.Team,
							self.spotter
						)
						self.switchWhichWay = 2
					elseif self.spotter:GetController():IsState(Controller.ACTOR_PREV) or self.switchWhichWay == 1 then
						ToGameActivity(ActivityMan:GetActivity()):SwitchToPrevActor(
							self.spotter:GetController().Player,
							self.spotter.Team,
							self.spotter
						)
						self.switchWhichWay = 1
					else
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.parent, self.parent.Team, self.Team)
					end
				end

				if
					not (self.gunner and self.gunner:IsPlayerControlled())
					or (self.reloader and self.reloader:IsPlayerControlled())
					or (self.spotter and self.spotter:IsPlayerControlled())
				then
					self.switchWhichWay = 0
				end
			end

			------------------------------- Gunner Man ------------------------------------

			if self.gunner == nil or not MovableMan:IsActor(self.gunner) then --Get first guy: Gunner
				self:Deactivate() --Deactivate a bunch of stuff
				self.parent:SetAimAngle((-0.3 + self.parent.RotAngle))
				self.parent:SetControllerMode(Controller.CIM_DISABLED, self.parent:GetController().Player)
				self.parent.AIMode = Actor.AIMODE_NONE

				if self.IsPlayer and self.parent:IsPlayerControlled() then --Normal sized switch code for when turret is alone
					if self.parent:GetController():IsState(Controller.ACTOR_NEXT) then
						ToGameActivity(ActivityMan:GetActivity()):SwitchToNextActor(
							self.parent:GetController().Player,
							self.parent.Team,
							self.parent
						)
					elseif self.parent:GetController():IsState(Controller.ACTOR_PREV) then
						ToGameActivity(ActivityMan:GetActivity()):SwitchToPrevActor(
							self.parent:GetController().Player,
							self.parent.Team,
							self.parent
						)
					end
				end

				if self.reloader then
					self.gunner = ToAHuman(self.reloader)
					self.reloader = nil
					self.gunner:AddInventoryItem(CreateHDFirearm("Gunner Holder", "GrandGuard.rte"))
					self.gunner:EquipNamedDevice("Gunner Holder", true)
					self.gunner:RemoveInventoryItem("Reloader Holder")
				elseif self.spotter then
					self.gunner = ToAHuman(self.spotter)
					self.spotter = nil
					self.gunner:AddInventoryItem(CreateHDFirearm("Gunner Holder", "GrandGuard.rte"))
					self.gunner:EquipNamedDevice("Gunner Holder", true)
					self.gunner:RemoveInventoryItem("Spotter Holder")
				elseif
					not (
						math.abs(self.parent.AngularVel) > 7
						or self.parent.RotAngle > 0.75
						or self.parent.RotAngle < -0.75
						or not MovableMan:IsActor(self.parent)
						or self.parent.Health <= 0
					)
				then
					for actor in MovableMan.Actors do
						if
							actor.Team == self.Team
							and SceneMan:ShortestDistance(actor.Pos, self.Pos, SceneMan.SceneWrapsX).Magnitude < 30
							and actor.Vel.Magnitude < 10
							and actor.Status == 0
						then
							if IsAHuman(actor) then
								if
									(actor:IsPlayerControlled() and UInputMan:KeyPressed(6))
									or (not actor:IsPlayerControlled() and actor.AIMode == Actor.AIMODE_SENTRY)
								then --F to mount
									if
										actor:NumberValueExists("Manning Gun") == false
										or actor:GetNumberValue("Manning Gun") == 0
									then
										self.gunner = ToAHuman(actor)
										self.gunner:SetNumberValue("Manning Gun", 1)
										self.gunner:AddInventoryItem(CreateHDFirearm("Gunner Holder", "GrandGuard.rte"))
										self.gunner:EquipNamedDevice("Gunner Holder", true)
										self.gunner.AIMode = Actor.AIMODE_NONE
										self.gunner.HUDVisible = false
										self.parent.AIMode = 1

										self.parent:SetControllerMode(2, self.parent:GetController().Player)

										if self.gunner:IsPlayerControlled() then
											local switcher = ActivityMan:GetActivity()
											switcher:SwitchToActor(self.parent, self.parent.Team, self.Team)
										end
									end
								end
							end
						end
					end
				end
			elseif self.gunner then --We have gunner
				--Set gunner pos and vel so it moves with the turret

				self.gunner.Vel = self.motorParent.Vel / 1.5
				self.gunner.Pos = self.Pos
					+ Vector((-31 * self.FlipFactor) + (math.abs(self.RotAngle)) * self.FlipFactor, 10):RadRotate(
						self.RotAngle / 1.75
					)

				self.gunner.HFlipped = self.HFlipped

				self.gunner:SetAimAngle(self.parent:GetAimAngle(false))

				self.gunner:SetControllerMode(Controller.CIM_DISABLED, self.gunner:GetController().Player)

				self.gunner:SetNumberValue("BugFix Check", 1)

				if self.gunner.Status ~= 0 then
					self.gunner = nil
				end

				-- Remove gunner if turret moves a lot or is very rotated

				if
					math.abs(self.parent.AngularVel) > 7
					or self.parent.RotAngle > 0.75
					or self.parent.RotAngle < -0.75
					or not MovableMan:IsActor(self.parent)
					or self.parent.Health <= 0
					or (self.parent:IsPlayerControlled() and UInputMan:KeyPressed(7))
				then
					self.gunner:SetNumberValue("Manning Gun", 0)
					self.gunner.AIMode = 1
					self.gunner:SetControllerMode(2, self.gunner:GetController().Player)
					self.gunner.HUDVisible = true

					if self.parent:IsPlayerControlled() then
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.gunner, self.gunner.Team, self.Team)
					end

					self.gunner = nil
				end

				------------------------- Reloader Man -----------------------------------

				if self.crewSize > 1 then
					if self.reloader == nil or not MovableMan:IsActor(self.reloader) then --Get second guy: Reloader
						self.BaseReloadTime = self.originalReloadTime

						if self.spotter then
							self.reloader = ToAHuman(self.spotter)
							self.spotter = nil
							self.reloader:AddInventoryItem(CreateHDFirearm("Reloader Holder", "GrandGuard.rte"))
							self.reloader:EquipNamedDevice("Reloader Holder", true)
							self.reloader:RemoveInventoryItem("Spotter Holder")
						elseif
							not (
								math.abs(self.parent.AngularVel) > 7
								or self.parent.RotAngle > 0.75
								or self.parent.RotAngle < -0.75
								or not MovableMan:IsActor(self.parent)
								or self.parent.Health <= 0
							)
						then
							for actor in MovableMan.Actors do
								if
									actor.Team == self.Team
									and SceneMan:ShortestDistance(actor.Pos, self.Pos, SceneMan.SceneWrapsX).Magnitude < 30
									and actor.Vel.Magnitude < 10
									and actor.Status == 0
								then
									if IsAHuman(actor) then
										if
											(actor:IsPlayerControlled() and UInputMan:KeyPressed(6))
											or (not actor:IsPlayerControlled() and actor.AIMode == Actor.AIMODE_SENTRY)
										then --F to mount
											if
												actor:NumberValueExists("Manning Gun") == false
												or actor:GetNumberValue("Manning Gun") == 0
											then
												self.reloader = ToAHuman(actor)
												self.reloader:SetNumberValue("Manning Gun", 2)
												self.reloader:AddInventoryItem(
													CreateHDFirearm("Reloader Holder", "GrandGuard.rte")
												)
												self.reloader:EquipNamedDevice("Reloader Holder", true)
												self.reloader.AIMode = Actor.AIMODE_NONE
												self.reloader.HUDVisible = false

												if self.reloader:IsPlayerControlled() then
													local switcher = ActivityMan:GetActivity()
													switcher:SwitchToActor(self.parent, self.parent.Team, self.Team)
												end
											end
										end
									end
								end
							end
						end
					elseif self.reloader then
						self.BaseReloadTime = self.originalReloadTime / self.reloadTimeReducer

						--Set reloader pos and vel so it moves with the turret

						self.reloader.Vel = self.motorParent.Vel / 1.5
						self.reloader.Pos = self.parent.Pos
							+ Vector(-18 * self.FlipFactor, 2):RadRotate(self.parent.RotAngle / 1.5)

						self.reloader.HFlipped = self.HFlipped

						self.reloader:SetAimAngle(self.parent.RotAngle)

						self.reloader:SetControllerMode(Controller.CIM_DISABLED, self.reloader:GetController().Player)

						self.reloader:SetNumberValue("BugFix Check", 1)

						if self.reloader.Status ~= 0 then
							self.reloader = nil
						end

						-- Remove reloader if turret moves a lot or is very rotated

						if
							math.abs(self.parent.AngularVel) > 7
							or self.parent.RotAngle > 0.75
							or self.parent.RotAngle < -0.75
							or not MovableMan:IsActor(self.parent)
							or self.parent.Health <= 0
							or (self.parent:IsPlayerControlled() and UInputMan:KeyPressed(8))
						then
							self.reloader:SetNumberValue("Manning Gun", 0)
							self.reloader.AIMode = 1
							self.reloader:SetControllerMode(2, self.reloader:GetController().Player)
							self.reloader.HUDVisible = true

							if self.parent:IsPlayerControlled() then
								local switcher = ActivityMan:GetActivity()
								switcher:SwitchToActor(self.reloader, self.reloader.Team, self.Team)
							end

							self.reloader = nil
						end

						if self.crewSize > 2 then
							if self.spotter == nil or not MovableMan:IsActor(self.spotter) then --Get third guy: Spotter
								self.SharpLength = self.originalSharpLength

								if
									not (
										math.abs(self.parent.AngularVel) > 7
										or self.parent.RotAngle > 0.75
										or self.parent.RotAngle < -0.75
										or not MovableMan:IsActor(self.parent)
										or self.parent.Health <= 0
									)
								then
									for actor in MovableMan.Actors do
										if
											actor.Team == self.Team
											and SceneMan:ShortestDistance(actor.Pos, self.Pos, SceneMan.SceneWrapsX).Magnitude < 30
											and actor.Vel.Magnitude < 10
											and actor.Status == 0
										then
											if IsAHuman(actor) then
												if
													(actor:IsPlayerControlled() and UInputMan:KeyPressed(6))
													or (
														not actor:IsPlayerControlled()
														and actor.AIMode == Actor.AIMODE_SENTRY
													)
												then --F to mount
													if
														actor:NumberValueExists("Manning Gun") == false
														or actor:GetNumberValue("Manning Gun") == 0
													then
														self.spotter = ToAHuman(actor)
														self.spotter:SetNumberValue("Manning Gun", 2)
														self.spotter:AddInventoryItem(
															CreateHDFirearm("Spotter Holder", "GrandGuard.rte")
														)
														self.spotter:EquipNamedDevice("Spotter Holder", true)
														self.spotter.AIMode = Actor.AIMODE_NONE
														self.spotter.HUDVisible = false

														if self.spotter:IsPlayerControlled() then
															local switcher = ActivityMan:GetActivity()
															switcher:SwitchToActor(
																self.parent,
																self.parent.Team,
																self.Team
															)
														end
													end
												end
											end
										end
									end
								end
							elseif self.spotter then
								self.SharpLength = self.originalSharpLength * self.sharpLengthIncreaser

								--Set spotter pos and vel so it moves with the turret

								self.spotter.Vel = self.motorParent.Vel / 1.5
								self.spotter.Pos = self.parent.Pos
									+ Vector(12 * self.FlipFactor, -12):RadRotate(self.parent.RotAngle / 1.5)

								self.spotter.HFlipped = self.HFlipped

								self.spotter:SetAimAngle(self.parent:GetAimAngle(false))

								self.spotter:SetControllerMode(
									Controller.CIM_DISABLED,
									self.spotter:GetController().Player
								)

								self.spotter:SetNumberValue("BugFix Check", 1)

								if self.spotter.Status ~= 0 then
									self.spotter = nil
								end

								-- Remove spotter if turret moves a lot or is very rotated

								if
									math.abs(self.parent.AngularVel) > 7
									or self.parent.RotAngle > 0.75
									or self.parent.RotAngle < -0.75
									or not MovableMan:IsActor(self.parent)
									or self.parent.Health <= 0
									or (self.parent:IsPlayerControlled() and UInputMan:KeyPressed(10))
								then
									self.spotter:SetNumberValue("Manning Gun", 0)
									self.spotter.AIMode = 1
									self.spotter:SetControllerMode(2, self.spotter:GetController().Player)
									self.spotter.HUDVisible = true

									if self.parent:IsPlayerControlled() then
										local switcher = ActivityMan:GetActivity()
										switcher:SwitchToActor(self.spotter, self.spotter.Team, self.Team)
									end

									self.spotter = nil
								end
							end
						end
					end
				end
			end

			--------------- HUD Part, should make this more user friednly in create but oh well --------------------------

			local ctrl = self.parent:GetController()
			local screen = ctrl.Player

			local gunnerFrame = self.gunner and (self.parent.Team + 1) or 0
			local gunnerIcon = CreateMOSRotating("Gunner HUD Icon", "GrandGuard.rte")
			local gunnerIconPos = self.crewSize > 2 and self.parent.Pos + Vector(-12, -38)
				or self.crewSize > 1 and self.parent.Pos + Vector(-6, -38)
				or self.parent.Pos + Vector(0, -38)

			PrimitiveMan:DrawBitmapPrimitive(screen, gunnerIconPos, gunnerIcon, 3.14, gunnerFrame, true, true)

			if self.crewSize > 1 then
				local reloaderFrame = self.reloader and (self.parent.Team + 1) or 0
				local reloaderIcon = CreateMOSRotating("Reloader HUD Icon", "GrandGuard.rte")
				local reloaderIconPos = self.crewSize > 2 and self.parent.Pos + Vector(0, -38)
					or self.parent.Pos + Vector(6, -38)

				PrimitiveMan:DrawBitmapPrimitive(screen, reloaderIconPos, reloaderIcon, 3.14, reloaderFrame, true, true)
			end

			if self.crewSize > 2 then
				local spotterFrame = self.spotter and (self.parent.Team + 1) or 0
				local spotterIcon = CreateMOSRotating("Spotter HUD Icon", "GrandGuard.rte")
				local spotterIconPos = self.parent.Pos + Vector(12, -38)

				PrimitiveMan:DrawBitmapPrimitive(screen, spotterIconPos, spotterIcon, 3.14, spotterFrame, true, true)
			end
		else
			self.motorParent = nil
			if self.gunner then
				if self.gunner.Status ~= 0 then
					self.gunner = nil
				else
					self.gunner:SetNumberValue("Manning Gun", 0)
					self.gunner.AIMode = 1
					self.gunner:SetControllerMode(2, self.gunner:GetController().Player)
					self.gunner.HUDVisible = true

					if self.parent and self.parent:IsPlayerControlled() then
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.gunner, self.gunner.Team, self.Team)
					end

					self.gunner = nil
				end
			end

			if self.reloader then
				if self.reloader.Status ~= 0 then
					self.reloader = nil
				else
					self.reloader:SetNumberValue("Manning Gun", 0)
					self.reloader.AIMode = 1
					self.reloader:SetControllerMode(2, self.reloader:GetController().Player)
					self.reloader.HUDVisible = true

					self.reloader = nil
				end
			end

			if self.spotter then
				if self.spotter.Status ~= 0 then
					self.spotter = nil
				else
					self.spotter:SetNumberValue("Manning Gun", 0)
					self.spotter.AIMode = 1
					self.spotter:SetControllerMode(2, self.spotter:GetController().Player)
					self.spotter.HUDVisible = true

					self.spotter = nil
				end
			end

			self.parent = nil
		end
	else
		self.parent = nil
		if self.gunner then
			if self.gunner.Status ~= 0 then
				self.gunner:SetNumberValue("Manning Gun", 0)
				self.gunner.AIMode = 1
				self.gunner:SetControllerMode(2, self.gunner:GetController().Player)
				self.gunner.HUDVisible = true
			end
			self.gunner = nil
		end

		if self.reloader then
			if self.reloader.Status ~= 0 then
				self.reloader:SetNumberValue("Manning Gun", 0)
				self.reloader.AIMode = 1
				self.reloader:SetControllerMode(2, self.reloader:GetController().Player)
				self.reloader.HUDVisible = true
			end
			self.reloader = nil
		end

		if self.spotter then
			if self.spotter.Status ~= 0 then
				self.spotter:SetNumberValue("Manning Gun", 0)
				self.spotter.AIMode = 1
				self.spotter:SetControllerMode(2, self.spotter:GetController().Player)
				self.spotter.HUDVisible = true
			end
			self.spotter = nil
		end
	end
end

function Destroy(self)
	if self.gunner then
		self.gunner:SetNumberValue("Manning Gun", 0)
		self.gunner.AIMode = 1
		self.gunner:SetControllerMode(2, self.gunner:GetController().Player)
		self.gunner.HUDVisible = true

		if self.parent and self.parent:IsPlayerControlled() then
			local switcher = ActivityMan:GetActivity()
			switcher:SwitchToActor(self.gunner, self.gunner.Team, self.Team)
		end

		self.gunner = nil
	end

	if self.reloader then
		self.reloader:SetNumberValue("Manning Gun", 0)
		self.reloader.AIMode = 1
		self.reloader:SetControllerMode(2, self.reloader:GetController().Player)
		self.reloader.HUDVisible = true

		self.reloader = nil
	end

	if self.spotter then
		self.spotter:SetNumberValue("Manning Gun", 0)
		self.spotter.AIMode = 1
		self.spotter:SetControllerMode(2, self.spotter:GetController().Player)
		self.spotter.HUDVisible = true

		self.spotter = nil
	end
end
