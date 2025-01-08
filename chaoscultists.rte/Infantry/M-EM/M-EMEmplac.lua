------ Thanks to Zeta for that amazing hovercraft Bike.

function Create(self)
	if IsACrab(self:GetRootParent()) then
		self.parent = ToACrab(self:GetRootParent())
		self.IsPlayer = ActivityMan:GetActivity():IsHumanTeam(self.parent.Team)
	else
		self.parent = nil
	end

	if IsAttachable(self:GetParent()) then
		self.motorParent = ToAttachable(self:GetParent())
	else
		self.motorParent = nil
	end

	self.crewSize = 1 --How many people can operate this gun.

	self.gunner = nil
	self.originalPerceptiveness = self.Perceptiveness
	self.perceptivenessValue = 0.95 --Value in which the gunners/reloaders/whateva percetivness is multiplied before aplying it in total to the turret

	self.reloader = nil
	self.originalReloadTime = self.BaseReloadTime
	self.reloadTimeReducer = 1.5

	self.optimizationTimer = Timer()
	self.optimizationDelay = 10

	------ Script shortened, check "Emplacement.Lua" in shared for full script

	self.dismounting = false
	self.dismountTimer = Timer()
	self.dismountDelay = 3000

	self.detachActorTimer = Timer() --Timer for AI enemies to detach gun and keep going
	self.detachActorDelay = 8000

	self.grabber = nil

	if self.parent and self.motorParent and self.parent:NumberValueExists("Bag Spawn") then
		self.parent:FlashWhite(45)

		self:Reload()
	end
end

function Update(self)
	if self:IsAttached() == true then
		if self.motorParent and self.motorParent:IsAttached() == true then
			if
				math.abs(self.parent.RotAngle) > 0.8
				and math.abs(self.parent.AngularVel) > 0
				and math.abs(self.parent.AngularVel) < 7
			then
				if self.parent.RotAngle < -0.6 then
					self.parent.AngularVel = self.parent.AngularVel + 1
				elseif self.parent.RotAngle > 0.6 then
					self.parent.AngularVel = self.parent.AngularVel - 1
				end
			end

			------------------------------- Gunner Man ------------------------------------

			if not MovableMan:ValidMO(self.gunner) then --Get first guy: Gunner
				self.Reloadable = false
				self:Deactivate() --Deactivate a bunch of stuff
				self.parent:SetAimAngle((-0.3 + self.parent.RotAngle))
				self.Perceptiveness = self.originalPerceptiveness

				if self.parent:GetController().InputMode ~= Controller.CIM_DISABLED then
					self.parent:SetControllerMode(Controller.CIM_DISABLED, self.parent:GetController().Player)
					self.parent.AIMode = Actor.AIMODE_NONE
				end

				self.parent.PlayerControllable = false

				if self.parent:IsPlayerControlled() then
					local ctrl = self.parent:GetController()
					local screen = ctrl.Player

					PrimitiveMan:DrawTextPrimitive(
						screen,
						self.parent.AboveHUDPos + Vector(-14, -25),
						"UNMANNED",
						true,
						0
					)
					PrimitiveMan:DrawTextPrimitive(
						screen,
						self.parent.AboveHUDPos + Vector(-25, -15),
						"REQUIRES: GUNNER",
						true,
						0
					)
				end

				if MovableMan:ValidMO(self.reloader) then
					self.gunner = ToAHuman(self.reloader)
					self.reloader = nil
					self.parent.PlayerControllable = true
					self.gunner:AddInventoryItem(CreateHDFirearm("Gunner Holder", "chaoscultists.rte"))
					self.gunner:EquipNamedDevice("Gunner Holder", true)
					self.gunner:RemoveInventoryItem("Reloader Holder")
				elseif self.optimizationTimer:IsPastSimMS(self.optimizationDelay) then
					self.optimizationTimer:Reset()
					for mo in MovableMan:GetMOsInRadius(self.Pos, 30) do
						if IsActor(mo) then
							actor = ToActor(mo)
							if actor.Team == self.Team and actor.Vel.Magnitude < 10 and actor.Status == 0 then
								if IsAHuman(actor) then
									if
										not (
											math.abs(self.parent.AngularVel) > 7
											or math.abs(self.parent.RotAngle) > 0.8
											or not MovableMan:IsActor(self.parent)
											or self.parent.Health <= 0
										)
									then
										if
											(
												self.IsPlayer == false
												and (math.random() < 0.05 or actor.AIMode == Actor.AIMODE_SENTRY)
											)
											or (
												(actor:IsPlayerControlled() and UInputMan:KeyPressed(Key["T"]))
												or (
													not actor:IsPlayerControlled()
													and actor.AIMode == Actor.AIMODE_SENTRY
												)
											)
										then --F to mount
											self.gunner = ToAHuman(actor)
											if
												self.gunner.FGArm
												and (
													not self.gunner.EquippedItem
													or (
														self.gunner.EquippedItem
														and self.gunner.EquippedItem.PresetName ~= "Gunner Holder"
													)
												)
											then
												self.gunner:AddInventoryItem(
													CreateHDFirearm("Gunner Holder", "chaoscultists.rte")
												)
												self.gunner:EquipNamedDevice("Gunner Holder", true)
												self.gunner.AIMode = Actor.AIMODE_NONE
												self.gunner.HUDVisible = false
												self.parent.PlayerControllable = true
												self.parent.AIMode = 1
												self.BaseReloadTime = self.originalReloadTime
												self.parent:SetControllerMode(2, self.parent:GetController().Player)
												--------
												if self.IsPlayer and self.gunner:IsPlayerControlled() then
													local switcher = ActivityMan:GetActivity()
													switcher:SwitchToActor(
														self.parent,
														self.gunner:GetController().Player,
														self.parent.Team
													)
												end
											else
												self.gunner = nil
											end
										end
									end
									if actor:IsPlayerControlled() and UInputMan:KeyPressed(Key["B"]) then
										self.grabber = ToAHuman(actor)
										self.dismounting = true
										self.dismountTimer:Reset()
									end
								end
							end
						end
					end
				end
			elseif MovableMan:ValidMO(self.gunner) then --We have gunner
				if self.gunner.EquippedItem then
					self.gunner.EquippedItem.Sharpness = 2
				end

				if self.gunner:GetController().InputMode ~= Controller.CIM_DISABLED then
					self.gunner:SetControllerMode(Controller.CIM_DISABLED, self.gunner:GetController().Player)
					self.gunner.AIMode = Actor.AIMODE_NONE
				end

				self.gunner.PlayerControllable = false

				self.Perceptiveness = self.gunner.Perceptiveness * self.perceptivenessValue

				self.Reloadable = true

				--Set gunner pos and vel so it moves with the turret

				self.gunner.Vel = self.motorParent.Vel / 1.5
				self.gunner.Pos = self.Pos + Vector(-34 * self.FlipFactor, 10):RadRotate(self.RotAngle / 1.5)
				self.gunner.HFlipped = self.HFlipped
				self.gunner:SetAimAngle(self.parent:GetAimAngle(false))

				if self.gunner.Status ~= 0 then
					self.gunner = nil
				end

				-- Remove gunner if turret moves a lot or is very rotated

				if
					self.gunner
					and (
						math.abs(self.parent.AngularVel) > 7
						or math.abs(self.parent.RotAngle) > 0.8
						or not MovableMan:IsActor(self.parent)
						or self.parent.Health <= 0
						or (self.parent:IsPlayerControlled() and UInputMan:KeyPressed(Key["G"]))
						or self.gunner.FGArm == nil
					)
				then
					if self.gunner.EquippedItem then
						self.gunner.EquippedItem.ToDelete = true
					end
					self.gunner.AIMode = 1
					self.gunner:SetControllerMode(2, self.gunner:GetController().Player)
					self.gunner.HUDVisible = true
					self.gunner.PlayerControllable = true

					if self.IsPlayer and self.parent:IsPlayerControlled() then
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.gunner, self.parent:GetController().Player, self.Team)
					end

					self.gunner = nil
				end

				if
					self.parent:IsPlayerControlled()
					and UInputMan:KeyPressed(Key["B"]) --[[or (self.IsPlayer == false and self.detachActorTimer:IsPastSimMS(self.detachActorDelay))--]]
				then --remove gunner AND grab turret
					self.grabber = self.gunner
					self.dismounting = true
					self.dismountTimer:Reset()
				end
				------------------------- Reloader Man -----------------------------------

				if self.crewSize > 1 then
					if not MovableMan:ValidMO(self.reloader) then --Get second guy: Reloader
						self.BaseReloadTime = self.originalReloadTime

						if self.optimizationTimer:IsPastSimMS(self.optimizationDelay) then
							self.optimizationTimer:Reset()
							if
								not (
									math.abs(self.parent.AngularVel) > 7
									or math.abs(self.parent.RotAngle) > 0.8
									or not MovableMan:IsActor(self.parent)
									or self.parent.Health <= 0
								)
							then
								for mo in MovableMan:GetMOsInRadius(self.Pos, 30) do
									if IsActor(mo) then
										actor = ToActor(mo)
										if
											actor.Team == self.Team
											and actor.Vel.Magnitude < 10
											and actor.Status == 0
										then
											if IsAHuman(actor) then
												if
													(actor:IsPlayerControlled() and UInputMan:KeyPressed(Key["T"]))
													or (
														not actor:IsPlayerControlled()
														and actor.AIMode == Actor.AIMODE_SENTRY
													)
												then --F to mount
													self.reloader = ToAHuman(actor)
													if
														self.reloader.FGArm
														and (
															not self.reloader.EquippedItem
															or (
																self.reloader.EquippedItem
																and self.reloader.EquippedItem.PresetName
																	~= "Gunner Holder"
															)
														)
													then
														local RH = CreateHDFirearm(
															"Reloader Holder",
															"chaoscultists.rte"
														)
														RH.Frame = 1
														self.reloader:AddInventoryItem(RH)
														self.reloader:EquipNamedDevice("Reloader Holder", true)
														self.reloader.AIMode = Actor.AIMODE_NONE
														self.reloader.HUDVisible = false
														if self.IsPlayer and self.reloader:IsPlayerControlled() then
															local switcher = ActivityMan:GetActivity()
															switcher:SwitchToActor(
																self.parent,
																self.reloader:GetController().Player,
																self.parent.Team
															)
														end
													else
														self.reloader = nil
													end
												end
											end
										end
									end
								end
							end
						end
					elseif MovableMan:ValidMO(self.reloader) then
						if self.reloader.EquippedItem then
							self.reloader.EquippedItem.Sharpness = 2
						end

						if self.reloader:GetController().InputMode ~= Controller.CIM_DISABLED then
							self.reloader:SetControllerMode(
								Controller.CIM_DISABLED,
								self.reloader:GetController().Player
							)
							self.reloader.AIMode = Actor.AIMODE_NONE
						end

						self.reloader.PlayerControllable = false

						self.BaseReloadTime = self.originalReloadTime / self.reloadTimeReducer

						--Set reloader pos and vel so it moves with the turret

						self.reloader.Vel = self.motorParent.Vel / 1.5
						self.reloader.Pos = self.parent.Pos
							+ Vector(-6 * self.FlipFactor, 4):RadRotate(self.parent.RotAngle / 1.5)
						self.reloader.HFlipped = self.HFlipped
						self.reloader:SetAimAngle(self.parent.RotAngle)

						if self.reloader.Status ~= 0 then
							self.reloader = nil
						end

						-- Remove reloader if turret moves a lot or is very rotated

						if
							self.reloader
							and (
								math.abs(self.parent.AngularVel) > 7
								or math.abs(self.parent.RotAngle) > 0.8
								or not MovableMan:IsActor(self.parent)
								or self.parent.Health <= 0
								or (self.parent:IsPlayerControlled() and UInputMan:KeyPressed(Key["H"]))
								or self.reloader.FGArm == nil
							)
						then
							if self.reloader.EquippedItem then
								self.reloader.EquippedItem.ToDelete = true
							end
							self.reloader.AIMode = 1
							self.reloader:SetControllerMode(2, self.reloader:GetController().Player)
							self.reloader.HUDVisible = true
							self.reloader.PlayerControllable = true

							if self.IsPlayer and self.parent:IsPlayerControlled() then
								local switcher = ActivityMan:GetActivity()
								switcher:SwitchToActor(self.reloader, self.parent:GetController().Player, self.Team)
							end

							self.reloader = nil
						end
					end
				end
			end
			--------------- HUD Part, should make this more user friednly in create but oh well --------------------------

			local ctrl = self.parent:GetController()
			local screen = ctrl.Player

			local gunnerFrame = (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8) and 5
				or self.gunner and (self.parent.Team + 1)
				or 0
			local gunnerIcon = CreateMOSRotating("Gunner HUD Icon", "chaoscultists.rte")
			local gunnerIconPos = self.crewSize > 1 and self.parent.Pos + Vector(-6, -32)
				or self.parent.Pos + Vector(0, -32)

			PrimitiveMan:DrawBitmapPrimitive(screen, gunnerIconPos, gunnerIcon, 3.14, gunnerFrame, true, true)

			if self.crewSize > 1 then
				local reloaderFrame = (math.abs(self.parent.AngularVel) > 7 or math.abs(self.parent.RotAngle) > 0.8)
						and 5
					or self.reloader and (self.parent.Team + 1)
					or 0
				local reloaderIcon = CreateMOSRotating("Reloader HUD Icon", "chaoscultists.rte")
				local reloaderIconPos = self.parent.Pos + Vector(6, -32)

				PrimitiveMan:DrawBitmapPrimitive(screen, reloaderIconPos, reloaderIcon, 3.14, reloaderFrame, true, true)
			end

			---------------------------------------------------------------------------------------------------------------

			if self.dismounting == true then
				local Manning = self.gunner ~= nil and self.gunner == self.grabber and true or false
				local grabber = Manning and self.parent or self.grabber
				local controller = grabber:GetController()

				if grabber:IsPlayerControlled() == true then
					local guiFrame = (self.dismountTimer.ElapsedSimTimeMS / (self.dismountDelay / 9))

					local teamTable = { " Red", " Green", " Blue", " Yellow" }

					local radialIcon = CreateMOSRotating(
						"Armada GUI Radial" .. teamTable[self.parent.Team + 1],
						"chaoscultists.rte"
					)

					PrimitiveMan:DrawBitmapPrimitive(screen, grabber.Pos, radialIcon, 3.14, guiFrame, true, true)

					PrimitiveMan:DrawTextPrimitive(screen, grabber.Pos + Vector(-16, 30), "Dismounting...", true, 0)
					PrimitiveMan:DrawTextPrimitive(screen, grabber.Pos + Vector(-18, 38), "Do not move", true, 0)
				end

				if
					controller:IsState(Controller.MOVE_RIGHT)
					or controller:IsState(Controller.MOVE_LEFT)
					or controller:IsState(Controller.WEAPON_FIRE)
					or controller:IsState(Controller.BODY_JUMP)
					or grabber.Vel.Magnitude > 5
					or controller:IsState(Controller.PIE_MENU_ACTIVE)
				then
					self.dismounting = false
				end

				if self.dismountTimer:IsPastSimMS(self.dismountDelay) then
					local turretItem = CreateHDFirearm("M-EM Gun Bag", "chaoscultists.rte") --Create turret deployer

					self.grabber:AddInventoryItem(turretItem)
					self.grabber:EquipNamedDevice("M-EM Gun Bag", true)

					ActivityMan:GetActivity():ReportDeath(self.Team, -1)

					if self.parent:IsPlayerControlled() then
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.gunner, self.parent:GetController().Player, self.Team)

						self.gunner.AIMode = Actor.AIMODE_BRAINHUNT
						self.gunner:SetControllerMode(2, self.gunner:GetController().Player)
						self.gunner.HUDVisible = true
						self.gunner.PlayerControllable = true
					end

					self.parent.ToDelete = true
				end
			end
		else
			self.motorParent = nil
			if MovableMan:ValidMO(self.gunner) then
				if self.gunner.Status ~= 0 then
					self.gunner = nil
				else
					self.gunner.AIMode = 1
					self.gunner:SetControllerMode(2, self.gunner:GetController().Player)
					self.gunner.HUDVisible = true
					self.gunner.PlayerControllable = true

					if self.IsPlayer and self.parent and self.parent:IsPlayerControlled() then
						local switcher = ActivityMan:GetActivity()
						switcher:SwitchToActor(self.gunner, self.parent:GetController().Player, self.Team)
					end

					self.gunner = nil
				end
			end

			if MovableMan:ValidMO(self.reloader) then
				if self.reloader.Status ~= 0 then
					self.reloader = nil
				else
					self.reloader.AIMode = 1
					self.reloader:SetControllerMode(2, self.reloader:GetController().Player)
					self.reloader.HUDVisible = true
					self.reloader.PlayerControllable = true

					self.reloader = nil
				end
			end

			self.parent = nil
		end
	else
		self.parent = nil
		if MovableMan:ValidMO(self.gunner) then
			if self.gunner.Status ~= 0 then
				self.gunner.AIMode = 1
				self.gunner:SetControllerMode(2, self.gunner:GetController().Player)
				self.gunner.HUDVisible = true
				self.gunner.PlayerControllable = true
			end
			self.gunner = nil
		end

		if MovableMan:ValidMO(self.reloader) then
			if self.reloader.Status ~= 0 then
				self.reloader.AIMode = 1
				self.reloader:SetControllerMode(2, self.reloader:GetController().Player)
				self.reloader.HUDVisible = true
				self.reloader.PlayerControllable = true
			end
			self.reloader = nil
		end
	end
end

function Destroy(self)
	if MovableMan:ValidMO(self.gunner) then
		self.gunner.AIMode = 1
		self.gunner:SetControllerMode(2, self.gunner:GetController().Player)
		self.gunner.HUDVisible = true
		self.gunner.PlayerControllable = true

		if self.IsPlayer and self.parent and self.parent:IsPlayerControlled() then
			local switcher = ActivityMan:GetActivity()
			switcher:SwitchToActor(self.gunner, self.parent:GetController().Player, self.Team)
		end

		self.gunner = nil
	end

	if MovableMan:ValidMO(self.reloader) then
		self.reloader.AIMode = 1
		self.reloader:SetControllerMode(2, self.reloader:GetController().Player)
		self.reloader.HUDVisible = true
		self.reloader.PlayerControllable = true
		self.reloader = nil
	end
end
