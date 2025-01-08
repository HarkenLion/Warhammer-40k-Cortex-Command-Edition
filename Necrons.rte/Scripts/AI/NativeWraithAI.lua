dofile("Necrons.rte/Scripts/AI/NecronBehaviors.lua")
require("AI/PID")

NativeWraithAI = {}

function NativeWraithAI:Create(Owner)
	local Members = {}

	Members.lateralMoveState = Actor.LAT_STILL
	Members.proneState = AHuman.NOTPRONE
	Members.jumpState = AHuman.NOTJUMPING
	Members.deviceState = AHuman.STILL
	Members.lastAIMode = Actor.AIMODE_NONE
	Members.teamBlockState = Actor.NOTBLOCKED
	Members.SentryFacing = Owner.HFlipped
	Members.fire = false
	Members.minBurstTime = math.min(200, Owner.Jetpack.JetTimeTotal * 0.99)

	Members.Ctrl = Owner:GetController()

	Members.AirTimer = Timer()
	Members.PickUpTimer = Timer()
	Members.ReloadTimer = Timer()
	Members.BlockedTimer = Timer()

	Members.AlarmTimer = Timer()
	Members.AlarmTimer:SetSimTimeLimitMS(400)

	Members.TargetLostTimer = Timer()
	Members.TargetLostTimer:SetSimTimeLimitMS(1000)

	-- the controllers
	Members.XposPID = RegulatorPID:New({ p = 0.04, i = 0.00001, d = 0.4, filter_leak = 0.8, integral_max = 100 })
	Members.YposPID = RegulatorPID:New({ p = 0.05, i = 0.0001, d = 0.2, filter_leak = 0.8, integral_max = 100 })

	if Owner:HasObjectInGroup("Brains") then
		Members.isBrain = true
	end

	-- check if this team is controlled by a human
	local Activ = ActivityMan:GetActivity()
	for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
		if Activ:PlayerActive(player) and Activ:PlayerHuman(player) then
			if Owner.Team == Activ:GetTeamOfPlayer(player) then
				Members.isPlayerOwned = true
				Members.PlayerInterferedTimer = Timer()
				Members.PlayerInterferedTimer:SetSimTimeLimitMS(500)
				break
			end
		end
	end

	setmetatable(Members, self)
	self.__index = self
	return Members
end

function NativeWraithAI:Update(Owner)
	if self.isPlayerOwned then
		if self.PlayerInterferedTimer:IsPastSimTimeLimit() then
			self.Behavior = nil -- remove the current behavior
			if self.BehaviorCleanup then
				self.BehaviorCleanup(self) -- clean up after the current behavior
				self.BehaviorCleanup = nil
			end

			self.GoToBehavior = nil
			if self.GoToCleanup then
				self.GoToCleanup(self)
				self.GoToCleanup = nil
			end

			self.Target = nil
			self.UnseenTarget = nil
			self.OldTargetPos = nil
			self.PickupHD = nil
			self.BlockingActor = nil
			self.FollowingActor = nil

			self.fire = false
			self.canHitTarget = false
			self.jump = false

			self.proneState = AHuman.NOTPRONE
			self.SentryFacing = self.HFlipped
			self.deviceState = AHuman.STILL
			self.lastAIMode = Actor.AIMODE_NONE
			self.teamBlockState = Actor.NOTBLOCKED

			if self.EquippedItem then
				self.PlayerPreferredHD = self.EquippedItem.PresetName
			else
				self.PlayerPreferredHD = nil
			end
		end

		self.PlayerInterferedTimer:Reset()
	end

	if self.Target and not MovableMan:IsActor(self.Target) then
		self.Target = nil
	end

	if self.UnseenTarget and not MovableMan:IsActor(self.UnseenTarget) then
		self.UnseenTarget = nil
	end

	-- switch to the next behavior, if avaliable
	if self.NextBehavior then
		if self.BehaviorCleanup then
			self.BehaviorCleanup(self)
		end

		self.Behavior = self.NextBehavior
		self.BehaviorCleanup = self.NextCleanup
		self.BehaviorName = self.NextBehaviorName

		self.NextBehavior = nil
		self.NextCleanup = nil
		self.NextBehaviorName = nil
	end

	-- switch to the next GoTo behavior, if avaliable
	if self.NextGoTo then
		if self.GoToCleanup then
			self.GoToCleanup(self)
		end

		self.GoToBehavior = self.NextGoTo
		self.GoToCleanup = self.NextGoToCleanup
		self.GoToName = self.NextGoToName

		self.NextGoTo = nil
		self.NextGoToCleanup = nil
		self.NextGoToName = nil
	end

	-- check if the AI mode has changed or if we need a new behavior
	if Owner.AIMode ~= self.lastAIMode or (not self.Behavior and not self.GoToBehavior) then
		self.Behavior = nil
		if self.BehaviorCleanup then
			self.BehaviorCleanup(self) -- stop the current behavior
			self.BehaviorCleanup = nil
		end

		self.GoToBehavior = nil
		if self.GoToCleanup then
			self.GoToCleanup(self)
			self.GoToCleanup = nil
		end

		-- select a new behavior based on AI mode
		if Owner.AIMode == Actor.AIMODE_GOTO then
			self:CreateGoToBehavior()
		elseif Owner.AIMode == Actor.AIMODE_BRAINHUNT then
			self:CreateBrainSearchBehavior()
		elseif Owner.AIMode == Actor.AIMODE_GOLDDIG then
			self:CreateGoldDigBehavior()
		elseif Owner.AIMode == Actor.AIMODE_PATROL then
			self:CreatePatrolBehavior()
		else
			if Owner.AIMode ~= self.lastAIMode and Owner.AIMode == Actor.AIMODE_SENTRY then
				self.SentryFacing = Owner.HFlipped -- store the direction in which we should be looking
				self.SentryPos = Vector(Owner.Pos.X, Owner.Pos.Y) -- store the pos on which we should be standing
			end

			self:CreateSentryBehavior(Owner)
		end

		self.lastAIMode = Owner.AIMode
	end

	-- check if the legs reach the ground
	if self.AirTimer:IsPastSimMS(250) then
		self.AirTimer:Reset()

		if
			-1
			< SceneMan:CastObstacleRay(
				Owner.Pos,
				Vector(0, Owner.Height / 4),
				Vector(),
				Vector(),
				Owner.ID,
				Owner.IgnoresWhichTeam,
				rte.grassID,
				3
			)
		then
			self.flying = false
		else
			self.flying = true
		end

		Owner:EquipShieldInBGArm() -- try to equip a shield
	end

	-- look for targets
	local FoundMO, HitPoint
	if self.isBrain then
		FoundMO, HitPoint = NecronBehaviors.CheckEnemyLOS(self, Owner)
	else
		FoundMO, HitPoint = NecronBehaviors.LookForTargets(self, Owner)
	end

	if FoundMO then
		if self.Target and MovableMan:IsActor(self.Target) and FoundMO.ID == self.Target.ID then -- found the same target
			self.TargetOffset = SceneMan:ShortestDistance(self.Target.Pos, HitPoint, false)
			self.TargetLostTimer:Reset()
			self.ReloadTimer:Reset()
		elseif MovableMan:IsActor(FoundMO) then
			if FoundMO.Team == Owner.Team then -- found an ally
				if self.Target then
					if
						SceneMan:ShortestDistance(Owner.Pos, FoundMO.Pos, false).Magnitude
						< SceneMan:ShortestDistance(Owner.Pos, self.Target.Pos, false).Magnitude
					then
						self.Target = nil -- stop shooting
					end
				elseif
					FoundMO.ClassName ~= "ADoor"
					and SceneMan:ShortestDistance(Owner.Pos, FoundMO.Pos, false).Magnitude
						< Owner.Diameter + FoundMO.Diameter
				then
					self.BlockingActor = ToActor(FoundMO) -- this actor is blocking our path
				end
			else
				if FoundMO.ClassName == "AHuman" then
					FoundMO = ToAHuman(FoundMO)
				elseif FoundMO.ClassName == "ACrab" then
					FoundMO = ToACrab(FoundMO)
				elseif FoundMO.ClassName == "ACRocket" then
					FoundMO = ToACRocket(FoundMO)
				elseif FoundMO.ClassName == "ACDropShip" then
					FoundMO = ToACDropShip(FoundMO)
				elseif FoundMO.ClassName == "ADoor" then
					FoundMO = ToADoor(FoundMO)
				elseif FoundMO.ClassName == "Actor" then
					FoundMO = ToActor(FoundMO)
				else
					FoundMO = nil
				end

				if FoundMO then
					if self.Target then
						-- check if this MO sould be targeted instead
						if
							NecronBehaviors.CalculateThreatLevel(FoundMO, Owner)
							> NecronBehaviors.CalculateThreatLevel(self.Target, Owner) + 0.5
						then
							self.OldTargetPos = Vector(self.Target.Pos.X, self.Target.Pos.Y)
							self.Target = FoundMO
							self.TargetOffset = SceneMan:ShortestDistance(self.Target.Pos, HitPoint, false) -- this is the distance vector from the target center to the point we hit with our ray
							if self.NextBehaviorName ~= "ShootTarget" then
								self:CreateAttackBehavior(Owner)
							end
						end
					else
						self.OldTargetPos = nil
						self.Target = FoundMO
						self.TargetOffset = SceneMan:ShortestDistance(self.Target.Pos, HitPoint, false) -- this is the distance vector from the target center to the point we hit with our ray
						self:CreateAttackBehavior(Owner)
					end
				end
			end
		end
	else -- no target found this frame
		if self.Target and self.TargetLostTimer:IsPastSimTimeLimit() then
			self.OldTargetPos = Vector(self.Target.Pos.X, self.Target.Pos.Y)
			self.Target = nil -- the target has been out of sight for too long, ignore it
			self:CreateFaceAlarmBehavior(Owner) -- keep aiming in the direction of the target
		end

		if self.ReloadTimer:IsPastSimMS(8000) then -- check if we need to reload
			self.ReloadTimer:Reset()
			if Owner.FirearmNeedsReload then
				Owner:ReloadFirearms()
			end
		end
	end

	-- run the move behavior and delete it if it returns true
	if self.GoToBehavior then
		local msg, done = coroutine.resume(self.GoToBehavior, self, Owner)
		if not msg then
			ConsoleMan:PrintString(Owner.PresetName .. " " .. self.GoToName .. " error:\n" .. done) -- print the error message
			done = true
		end

		if done then
			self.GoToBehavior = nil
			if self.GoToCleanup then
				self.GoToCleanup(self)
				self.GoToCleanup = nil
			end
		end
	elseif self.flying then -- avoid falling damage
		if (not self.jump and Owner.Vel.Y > 9) or (self.jump and Owner.Vel.Y > 6) then
			self.jump = true

			-- try falling straight down
			if not self.Target then
				if Owner.Vel.X > 2 then
					self.lateralMoveState = Actor.LAT_LEFT
				elseif Owner.Vel.X < -2 then
					self.lateralMoveState = Actor.LAT_RIGHT
				else
					self.lateralMoveState = Actor.LAT_STILL
				end
			end
		else
			self.jump = false
			self.lateralMoveState = Actor.LAT_STILL
		end
	end

	-- run the selected behavior and delete it if it returns true
	if self.Behavior then
		local msg, done = coroutine.resume(self.Behavior, self, Owner)
		if not msg then
			ConsoleMan:PrintString(Owner.PresetName .. " behavior " .. self.BehaviorName .. " error:\n" .. done) -- print the error message
			done = true
		end

		if done then
			self.Behavior = nil
			if self.BehaviorCleanup then
				self.BehaviorCleanup(self)
				self.BehaviorCleanup = nil
			end

			if not self.NextBehavior and not self.PickupHD and self.PickUpTimer:IsPastSimMS(10000) then
				self.PickUpTimer:Reset()

				if not Owner:EquipFirearm(false) then
					self:CreateGetWeaponBehavior()
				elseif Owner.AIMode ~= Actor.AIMODE_SENTRY and not Owner:EquipDiggingTool(false) then
					self:CreateGetToolBehavior()
				end
			end
		end
	end

	if self.PickupHD then -- there is a HeldDevice we want to pick up
		if not MovableMan:IsDevice(self.PickupHD) or self.PickupHD.ID ~= self.PickupHD.RootID then
			self.PickupHD = nil -- the HeldDevice has been destroyed or picked up
			Owner:ClearAIWaypoints()

			if self.PrevAIWaypoint or self.FollowingActor then
				if self.FollowingActor and MovableMan:IsActor(self.FollowingActor) then -- what if the old destination was a moving actor?
					Owner:AddAIMOWaypoint(self.FollowingActor)
					self:CreateGoToBehavior() -- continue towards our old destination
				else
					self.FollowingActor = nil
					if self.PrevAIWaypoint then
						Owner:AddAISceneWaypoint(self.PrevAIWaypoint)
						self:CreateGoToBehavior() -- continue towards our old destination
					end
				end
			end
		else
			if SceneMan:ShortestDistance(Owner.Pos, self.PickupHD.Pos, false).Magnitude < Owner.Height then
				self.Ctrl:SetState(Controller.WEAPON_PICKUP, true)
			end
		end
	end

	-- listen and react to relevant AlarmEvents
	if not self.Target and not self.UnseenTarget then
		if self.AlarmTimer:IsPastSimTimeLimit() and NecronBehaviors.ProcessAlarmEvent(self, Owner) then
			self.AlarmTimer:Reset()
		end
	end

	if self.teamBlockState == Actor.IGNORINGBLOCK then
		if self.BlockedTimer:IsPastSimMS(2000) then
			self.teamBlockState = Actor.NOTBLOCKED
		end
	elseif self.teamBlockState == Actor.BLOCKED then -- we are blocked by a teammate, stop
		self.lateralMoveState = Actor.LAT_STILL
		self.jump = false
		if self.BlockedTimer:IsPastSimMS(5000) then
			self.BlockedTimer:Reset()
			self.teamBlockState = Actor.IGNORINGBLOCK
		end
	else
		self.BlockedTimer:Reset()
	end

	-- controller states
	if self.fire then
		self.Ctrl:SetState(Controller.WEAPON_FIRE, true)
	end

	if self.deviceState == AHuman.AIMING then
		self.Ctrl:SetState(Controller.AIM_SHARP, true)
	end

	if self.jump and Owner.Jetpack and Owner.Jetpack.JetTimeLeft > TimerMan.DeltaTimeMS then
		if self.jumpState == AHuman.PREJUMP then
			self.jumpState = AHuman.UPJUMP
		elseif self.jumpState ~= AHuman.UPJUMP then -- the jetpack is off
			if Owner.Jetpack and Owner.Jetpack.JetTimeLeft >= self.minBurstTime then -- don't start the jetpack unless there is enough fuel to fire a burst that is long enough to be useful
				self.jumpState = AHuman.PREJUMP
			else
				self.jumpState = AHuman.NOTJUMPING
			end
		end
	else
		self.jumpState = AHuman.NOTJUMPING
	end

	if self.jumpState == AHuman.PREJUMP then
		self.Ctrl:SetState(Controller.BODY_JUMPSTART, true) -- trigger burst
	elseif self.jumpState == AHuman.UPJUMP then
		self.Ctrl:SetState(Controller.BODY_JUMP, true) -- trigger normal jetpack emission
	end

	if self.lateralMoveState == Actor.LAT_LEFT then
		self.Ctrl:SetState(Controller.MOVE_LEFT, true)
	elseif self.lateralMoveState == Actor.LAT_RIGHT then
		self.Ctrl:SetState(Controller.MOVE_RIGHT, true)
	end
end

-- functions that create behaviors. the default behaviors are stored in the NecronBehaviors table. store your custom behaviors in a table to avoid name conflicts between mods.
function NativeWraithAI:CreateSentryBehavior(Owner)
	if not Owner.FirearmIsReady and not Owner.ThrowableIsReady then
		if not Owner:EquipFirearm(true) then
			self:CreateGetWeaponBehavior()
		end

		return
	end

	self.NextBehavior = coroutine.create(NecronBehaviors.Sentry) -- replace "NecronBehaviors.Sentry" with the function name of your own sentry behavior
	self.NextCleanup = nil
	self.NextBehaviorName = "Sentry"
end

function NativeWraithAI:CreatePatrolBehavior(Owner)
	self.NextBehavior = coroutine.create(NecronBehaviors.Patrol)
	self.NextCleanup = nil
	self.NextBehaviorName = "Patrol"
end

function NativeWraithAI:CreateGoldDigBehavior(Owner)
	self.NextBehavior = coroutine.create(NecronBehaviors.GoldDig)
	self.NextCleanup = nil
	self.NextBehaviorName = "GoldDig"
end

function NativeWraithAI:CreateBrainSearchBehavior(Owner)
	self.NextBehavior = coroutine.create(NecronBehaviors.BrainSearch)
	self.NextCleanup = nil
	self.NextBehaviorName = "BrainSearch"
end

function NativeWraithAI:CreateGetToolBehavior(Owner)
	self.NextBehavior = coroutine.create(NecronBehaviors.ToolSearch)
	self.NextCleanup = nil
	self.NextBehaviorName = "ToolSearch"
end

function NativeWraithAI:CreateGetWeaponBehavior(Owner)
	self.NextBehavior = coroutine.create(NecronBehaviors.WeaponSearch)
	self.NextCleanup = nil
	self.NextBehaviorName = "WeaponSearch"
end

function NativeWraithAI:CreateGoToBehavior(Owner)
	self.NextGoTo = coroutine.create(NecronBehaviors.GoToWpt)
	self.NextGoToCleanup = function(AI)
		AI.lateralMoveState = Actor.LAT_STILL
		AI.deviceState = AHuman.STILL
		AI.proneState = AHuman.NOTPRONE
		AI.jump = false
		AI.fire = false
	end
	self.NextGoToName = "GoToWpt"
end

function NativeWraithAI:CreateAttackBehavior(Owner)
	self.ReloadTimer:Reset()
	self.TargetLostTimer:Reset()

	if
		Owner:EquipDiggingTool(true)
		and SceneMan:ShortestDistance(Owner.Pos, self.Target.Pos, false).Magnitude < 405
	then
		self.NextBehavior = coroutine.create(NecronBehaviors.AttackTarget)
		self.NextBehaviorName = "AttackTarget"
	else -- unarmed or far away
		self.NextBehavior = coroutine.create(NecronBehaviors.AttackTarget)
		self.NextBehaviorName = "AttackTarget"
	end

	self.NextCleanup = function(AI)
		AI.fire = false
		AI.canHitTarget = false
		AI.deviceState = AHuman.STILL
		AI.proneState = AHuman.NOTPRONE
		AI.TargetLostTimer:SetSimTimeLimitMS(2000)
	end
end

-- force the use of a digger when attacking
function NativeWraithAI:CreateHtHBehavior(Owner)
	if self.Target and Owner:EquipDiggingTool(true) then
		self.NextBehavior = coroutine.create(NecronBehaviors.AttackTarget)
		self.NextBehaviorName = "AttackTarget"
		self.NextCleanup = function(AI)
			AI.fire = false
			AI.Target = nil
			AI.deviceState = AHuman.STILL
			AI.proneState = AHuman.NOTPRONE
		end
	end
end

function NativeWraithAI:CreateSuppressBehavior(Owner)
	if Owner:EquipFirearm(true) then
		self.NextBehavior = coroutine.create(NecronBehaviors.ShootArea)
		self.NextBehaviorName = "ShootArea"
	else
		if self.FirearmIsEmpty then
			self:ReloadFirearms()
		end

		return
	end

	self.NextCleanup = function(AI)
		AI.fire = false
		AI.UnseenTarget = nil
		AI.deviceState = AHuman.STILL
		AI.proneState = AHuman.NOTPRONE
	end
end

function NativeWraithAI:CreateMoveAroundBehavior(Owner)
	self.NextGoTo = coroutine.create(NecronBehaviors.MoveAroundActor)
	self.NextGoToName = "MoveAroundActor"
	self.NextGoToCleanup = function(AI)
		AI.lateralMoveState = Actor.LAT_STILL
		AI.jump = false
	end
end

function NativeWraithAI:CreateFaceAlarmBehavior(Owner)
	self.NextBehavior = coroutine.create(NecronBehaviors.FaceAlarm)
	self.NextBehaviorName = "FaceAlarm"
	self.NextCleanup = nil
end
