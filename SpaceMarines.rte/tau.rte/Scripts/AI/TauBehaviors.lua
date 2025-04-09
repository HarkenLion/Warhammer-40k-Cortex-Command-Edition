require("AI/PID")

TauBehaviors = {}

function TauBehaviors.LookForTargets(AI, Owner)
	local Origin
	local viewAng

	if AI.Target then -- widen the view angle to increase the chance of spotting new targets
		Origin = Owner.EyePos
		viewAng = 0.7
	elseif AI.deviceState == AHuman.AIMING then
		if Owner.EquippedItem then
			Origin = Owner.EquippedItem.Pos
		else
			Origin = Owner.EyePos
		end

		viewAng = 0.3
	elseif AI.deviceState == AHuman.POINTING then
		Origin = Owner.EyePos
		viewAng = 0.5
	elseif AI.deviceState == AHuman.THROWING then
		Origin = Owner.EyePos
		viewAng = 0.7
	else
		Origin = Owner.EyePos
		viewAng = RangeRand(0.5, 1.4)
	end

	local viewLen = SceneMan:ShortestDistance(Owner.EyePos, Owner.ViewPoint, false).Magnitude
		+ FrameMan.PlayerScreenWidth * 0.55
	local Trace = Vector(viewLen, 0):RadRotate(viewAng * NormalRand() + Owner:GetAimAngle(true))
	local ID = SceneMan:CastMORay(Origin, Trace, Owner.ID, Owner.IgnoresWhichTeam, rte.grassID, false, 5)

	if ID < rte.NoMOID then
		local HitPoint = SceneMan:GetLastRayHitPos()
		if not AI.isPlayerOwned or not SceneMan:IsUnseen(HitPoint.X, HitPoint.Y, Owner.Team) then -- AI-teams ignore the fog
			local MO = MovableMan:GetMOFromID(ID)
			if MO and ID ~= MO.RootID then
				MO = MovableMan:GetMOFromID(MO.RootID)
			end

			return MO, HitPoint
		end
	end
end

function TauBehaviors.CheckEnemyLOS(AI, Owner)
	if not AI.Enemies then -- add all enemy actors on our screen to a table and check LOS to them, one per frame
		AI.Enemies = {}
		for Act in MovableMan.Actors do
			if Act.Team ~= Owner.Team then
				if not AI.isPlayerOwned or not SceneMan:IsUnseen(Act.Pos.X, Act.Pos.Y, Owner.Team) then -- AI-teams ignore the fog
					local Dist = SceneMan:ShortestDistance(Owner.ViewPoint, Act.Pos, false)
					if
						(math.abs(Dist.X) - Act.Diameter < FrameMan.PlayerScreenWidth * 0.6)
						and (math.abs(Dist.Y) - Act.Diameter < FrameMan.PlayerScreenHeight * 0.6)
					then
						table.insert(AI.Enemies, Act)
					end
				end
			end
		end

		return TauBehaviors.LookForTargets(AI, Owner) -- cast rays like normal actors occasionally
	else
		local Enemy = table.remove(AI.Enemies)
		if Enemy then
			if MovableMan:ValidMO(Enemy) then
				local Origin
				if Owner.EquippedItem and AI.deviceState == AHuman.AIMING then
					Origin = Owner.EquippedItem.Pos
				else
					Origin = Owner.EyePos
				end

				local LookTarget
				if Enemy.ClassName == "ADoor" then
					local Door = ToADoor(Enemy).Door
					if Door and Door:IsAttached() then
						LookTarget = Door.Pos
					else
						return TauBehaviors.LookForTargets(AI, Owner) -- this door is destroyed, cast rays like normal actors
					end
				else
					LookTarget = Enemy.Pos
				end

				-- cast at body
				if not AI.isPlayerOwned or not SceneMan:IsUnseen(LookTarget.X, LookTarget.Y, Owner.Team) then -- AI-teams ignore the fog
					local Dist = SceneMan:ShortestDistance(Owner.ViewPoint, LookTarget, false)
					if
						(math.abs(Dist.X) - Enemy.Radius < FrameMan.PlayerScreenWidth * 0.52)
						and (math.abs(Dist.Y) - Enemy.Radius < FrameMan.PlayerScreenHeight * 0.52)
					then
						local Trace = SceneMan:ShortestDistance(Origin, LookTarget, false)
						local ID = SceneMan:CastMORay(
							Origin,
							Trace,
							Owner.ID,
							Owner.IgnoresWhichTeam,
							rte.grassID,
							false,
							5
						)
						if ID < rte.NoMOID then
							local MO = MovableMan:GetMOFromID(ID)
							if MO and ID ~= MO.RootID then
								MO = MovableMan:GetMOFromID(MO.RootID)
							end

							return MO, SceneMan:GetLastRayHitPos()
						end
					end
				end

				-- no LOS to the body, cast at head
				if
					Enemy.EyePos
					and (not AI.isPlayerOwned or not SceneMan:IsUnseen(Enemy.EyePos.X, Enemy.EyePos.Y, Owner.Team))
				then -- AI-teams ignore the fog
					local Dist = SceneMan:ShortestDistance(Owner.ViewPoint, Enemy.EyePos, false)
					if
						(math.abs(Dist.X) < FrameMan.PlayerScreenWidth * 0.52)
						and (math.abs(Dist.Y) < FrameMan.PlayerScreenHeight * 0.52)
					then
						local Trace = SceneMan:ShortestDistance(Origin, Enemy.EyePos, false)
						local ID = SceneMan:CastMORay(
							Origin,
							Trace,
							Owner.ID,
							Owner.IgnoresWhichTeam,
							rte.grassID,
							false,
							5
						)
						if ID < rte.NoMOID then
							local MO = MovableMan:GetMOFromID(ID)
							if MO and ID ~= MO.RootID then
								MO = MovableMan:GetMOFromID(MO.RootID)
							end

							return MO, SceneMan:GetLastRayHitPos()
						end
					end
				end
			end
		else
			AI.Enemies = nil
			return TauBehaviors.LookForTargets(AI, Owner) -- cast rays like normal actors occasionally
		end
	end
end

function TauBehaviors.CalculateThreatLevel(MO, Owner)
	-- prioritize closer targets
	local priority = -SceneMan:ShortestDistance(Owner.Pos, MO.Pos, false).Largest / FrameMan.PlayerScreenWidth

	-- prioritize the weaker humans over crabs
	if MO.ClassName == "AHuman" then
		if MO.FirearmIsReady then -- prioritize armed targets
			priority = priority + 1.0
		else
			priority = priority + 0.5
		end
	elseif MO.ClassName == "ACrab" then
		if MO.FirearmIsReady then -- prioritize armed targets
			priority = priority + 0.7
		else
			priority = priority + 0.3
		end
	end

	return priority - MO.Health / 500 -- prioritize damaged targets
end

function TauBehaviors.ProcessAlarmEvent(AI, Owner)
	AI.AlarmPos = nil

	local loudness, AlarmVec
	for Event in MovableMan.AlarmEvents do
		if Event.Team ~= Owner.Team then -- caused by some other team's activites - alarming!
			loudness = 30 + FrameMan.PlayerScreenWidth * 0.7 * Owner.Perceptiveness * (Event.Range / 500) -- adjust the audiable range to the screen resolution
			AlarmVec = SceneMan:ShortestDistance(Owner.EyePos, Event.ScenePos, false) -- see how far away the alarm situation is
			if AlarmVec.Largest < loudness then -- only react if the alarm is within hearing range
				-- if our relative position to the alarm location is the same, don't repeat the signal
				-- check if we have line of sight to the alarm point
				if not AI.LastAlarmVec or (AI.LastAlarmVec - AlarmVec).Largest > 10 then
					AI.LastAlarmVec = AlarmVec

					if AlarmVec.Largest < 100 then
						-- check more carfully at close range, and allow hearing of partially blocked alarm events
						if SceneMan:CastStrengthSumRay(Owner.EyePos, Event.ScenePos, 4, rte.grassID) < 100 then
							AI.AlarmPos = Vector(Event.ScenePos.X, Event.ScenePos.Y)
						end
					elseif not SceneMan:CastStrengthRay(Owner.EyePos, AlarmVec, 6, Vector(), 8, rte.grassID, true) then
						AI.AlarmPos = Vector(Event.ScenePos.X, Event.ScenePos.Y)
					end

					if AI.AlarmPos then
						AI:CreateFaceAlarmBehavior(Owner)
						return true
					end
				end
				-- sometimes try to shoot back at enemies outside our view range (400 is the range of the brain alarm)
			elseif not AI.flying and Event.Range > 400 and PosRand() < 0.6 and Owner.FirearmIsReady then
				-- only do this if we are facing the event and we or the target has changed position since the last check
				if (AlarmVec.X < 0 and Owner.HFlipped) or (AlarmVec.X > 0 and not Owner.HFlipped) then
					if
						AlarmVec.Largest < FrameMan.PlayerScreenWidth * 1.8
						and (not AI.LastAlarmVec or (AI.LastAlarmVec - AlarmVec).Largest > 20)
					then
						-- check LOS
						local ID = SceneMan:CastMORay(
							Owner.EyePos,
							AlarmVec,
							Owner.ID,
							Owner.IgnoresWhichTeam,
							rte.grassID,
							false,
							11
						)
						if ID < rte.NoMOID then
							local FoundMO = MovableMan:GetMOFromID(ID)
							if ID ~= FoundMO.RootID then
								FoundMO = MovableMan:GetMOFromID(FoundMO.RootID)
							end

							if FoundMO.ClassName == "AHuman" then
								FoundMO = ToAHuman(FoundMO)
								if FoundMO.EquippedItem and not ToHeldDevice(FoundMO.EquippedItem):IsWeapon() then
									FoundMO = nil -- don't shoot at actors using tools
								end
							elseif FoundMO.ClassName == "ACrab" then
								FoundMO = ToACrab(FoundMO)
							else
								FoundMO = nil
							end

							if
								FoundMO
								and FoundMO:GetController():IsState(Controller.WEAPON_FIRE)
								and FoundMO.Vel.Largest < 20
							then
								-- compare the enemy aim angle with the angle of the alarm vector
								local enemyAim = FoundMO:GetAimAngle(true) + math.pi -- rotate 180 degrees
								if enemyAim > math.pi * 2 then -- make sure the angle is in the [0..2*pi) range
									enemyAim = enemyAim - math.pi * 2
								elseif enemyAim < 0 then
									enemyAim = enemyAim + math.pi * 2
								end

								local angDiff = AlarmVec.AbsRadAngle - enemyAim
								if angDiff > math.pi then -- the difference between two angles can never be larger than pi
									angDiff = angDiff - math.pi * 2
								elseif angDiff < -math.pi then
									angDiff = angDiff + math.pi * 2
								end

								if math.abs(angDiff) < 0.7 then
									-- this actor is shooting in our direction
									AI.ReloadTimer:Reset()
									AI.TargetLostTimer:Reset()

									-- try to shoot back
									AI.UnseenTarget = FoundMO
									AI:CreateSuppressBehavior(Owner)

									AI.AlarmPos = Event.ScenePos
									return true
								end
							end
						else
							AI.LastAlarmVec = AlarmVec -- don't look here again if the raycast failed
						end
					end
				end
			end
		end
	end
end

function TauBehaviors.GetGrenadeAngle(AimPoint, TargetVel, StartPos, muzVel)
	local Dist = SceneMan:ShortestDistance(StartPos, AimPoint, false)
	local range = Dist.Magnitude

	-- compensate for gravity if the point we are trying to hit is more than 2m away
	if range > 40 then
		local timeToTarget = range / muzVel

		-- lead the target if target speed and projectile TTT is above the threshold
		if timeToTarget * TargetVel.Magnitude > 0.5 then
			AimPoint = AimPoint + TargetVel * timeToTarget
			Dist = SceneMan:ShortestDistance(StartPos, AimPoint, false)
		end

		Dist = Dist / GetPPM() -- convert from pixels to meters
		local velSqr = muzVel * muzVel
		local gravity = SceneMan.GlobalAcc.Y
		local root = math.sqrt(velSqr * velSqr - gravity * (gravity * Dist.X * Dist.X + 2 * -Dist.Y * velSqr))

		if root ~= root then
			return nil -- no solution exists if the root is NaN
		end

		return math.atan2(velSqr - root, gravity * Dist.X)
	end

	return Dist.AbsRadAngle
end

-- make sure we equip a primary weapon if we have one. return true if we must run this function again to be sure
function TauBehaviors.EquipPrimaryWeapon(AI, Owner)
	if Owner.EquippedItem then
		if
			Owner.InventorySize > 0
			and (not AI.PlayerPreferredHD or Owner.EquippedItem.PresetName ~= AI.PlayerPreferredHD)
			and not Owner.EquippedItem:HasObjectInGroup("Weapons - Primary")
			and Owner:HasObjectInGroup("Weapons - Primary")
		then
			-- the weapon equipped is not a primary weapon, but there is one in the inventory
			AI.Ctrl:SetState(Controller.WEAPON_CHANGE_NEXT, true)
			return true
		end
	elseif Owner.ClassName == "AHuman" then
		return Owner:EquipFirearm(true)
	end
end

-- in sentry behavior the agent only looks for new enemies, it sometimes sharp aims to increse spotting range
function TauBehaviors.Sentry(AI, Owner)
	local sweepUp = true
	local sweepDone = false
	local maxAng = 1.4
	local minAng = -1.4
	local aim

	if TauBehaviors.EquipPrimaryWeapon(AI, Owner) then
		local EquipTimer = Timer()
		while true do
			if EquipTimer:IsPastSimMS(500) then
				if not TauBehaviors.EquipPrimaryWeapon(AI, Owner) then
					break -- our current weapon is either a primary, we have no primary or we have no weapon
				end
			end

			coroutine.yield()
		end
	end

	if AI.OldTargetPos then -- try to reaquire an old target
		local Dist = SceneMan:ShortestDistance(Owner.EyePos, AI.OldTargetPos, false)
		AI.OldTargetPos = nil
		if (Dist.X < 0 and Owner.HFlipped) or (Dist.X > 0 and not Owner.HFlipped) then -- we are facing the target
			AI.deviceState = AHuman.AIMING
			AI.Ctrl.AnalogAim = Dist.Normalized

			for _ = 1, math.random(20, 30) do
				coroutine.yield() -- aim here for ~0.25s
			end
		end
	elseif not AI.isPlayerOwned then -- face the most likely enemy approach direction
		for _ = 1, math.random(5) do -- wait for a while
			coroutine.yield()
		end

		Owner:AddAISceneWaypoint(Vector(Owner.Pos.X, 0))
		Owner:UpdateMovePath()
		coroutine.yield() -- wait until next frame

		-- face the direction of the first waypoint
		for WptPos in Owner.MovePath do
			local Dist = SceneMan:ShortestDistance(Owner.Pos, WptPos, false)
			if Dist.X > 5 then
				AI.SentryFacing = false
				AI.Ctrl.AnalogAim = Dist.Normalized
			elseif Dist.X < -5 then
				AI.SentryFacing = true
				AI.Ctrl.AnalogAim = Dist.Normalized
			end

			break
		end
	end

	while true do -- start by looking forward
		aim = Owner:GetAimAngle(false)

		if sweepUp then
			if aim < maxAng / 3 then
				AI.Ctrl:SetState(Controller.AIM_UP, false)
				coroutine.yield() -- wait until next frame
				AI.Ctrl:SetState(Controller.AIM_UP, true)
			else
				sweepUp = false
			end
		else
			if aim > minAng / 3 then
				AI.Ctrl:SetState(Controller.AIM_DOWN, false)
				coroutine.yield() -- wait until next frame
				AI.Ctrl:SetState(Controller.AIM_DOWN, true)
			else
				sweepUp = true
				if sweepDone then
					break
				else
					sweepDone = true
				end
			end
		end

		coroutine.yield() -- wait until next frame
	end

	if Owner.HFlipped ~= AI.SentryFacing then
		Owner.HFlipped = AI.SentryFacing -- turn to the direction we have been order to guard
		return true -- restart this behavior
	end

	while true do -- look down
		aim = Owner:GetAimAngle(false)
		if aim > minAng then
			AI.Ctrl:SetState(Controller.AIM_DOWN, true)
		else
			break
		end

		coroutine.yield() -- wait until next frame
	end

	local Hit = Vector()
	local NoObstacle = {}
	local StartPos
	AI.deviceState = AHuman.AIMING

	while true do -- scan the area for obstacles
		aim = Owner:GetAimAngle(false)
		if aim < maxAng then
			AI.Ctrl:SetState(Controller.AIM_UP, true)
		else
			break
		end

		if Owner:EquipFirearm(false) and Owner.EquippedItem then
			StartPos = ToHeldDevice(Owner.EquippedItem).MuzzlePos
		else
			StartPos = Owner.EyePos
		end

		-- save the angle to a table if there is no obstacle
		if
			not SceneMan:CastStrengthRay(StartPos, Vector(60, 0):RadRotate(Owner:GetAimAngle(true)), 5, Hit, 2, 0, true)
		then
			table.insert(NoObstacle, aim) -- TODO: don't use a table for this
		end

		coroutine.yield() -- wait until next frame
	end

	local SharpTimer = Timer()
	local aimTime = 2000
	local angDiff = 1
	AI.deviceState = AHuman.POINTING

	if #NoObstacle > 1 then -- only aim where we know there are no obstacles, e.g. out of a gun port
		minAng = NoObstacle[1] * 0.95
		maxAng = NoObstacle[#NoObstacle] * 0.95
		angDiff = 1 / math.max(math.abs(maxAng - minAng), 0.1) -- sharp aim longer from a small aiming window
	end

	while true do
		if not Owner:EquipFirearm(false) and not Owner:EquipThrowable(false) then
			break
		end

		aim = Owner:GetAimAngle(false)

		if sweepUp then
			if aim < maxAng then
				if aim < maxAng / 5 and aim > minAng / 5 and PosRand() > 0.3 then
					AI.Ctrl:SetState(Controller.AIM_UP, false)
				else
					AI.Ctrl:SetState(Controller.AIM_UP, true)
				end
			else
				sweepUp = false
			end
		else
			if aim > minAng then
				if aim < maxAng / 5 and aim > minAng / 5 and PosRand() > 0.3 then
					AI.Ctrl:SetState(Controller.AIM_DOWN, false)
				else
					AI.Ctrl:SetState(Controller.AIM_DOWN, true)
				end
			else
				sweepUp = true
			end
		end

		if SharpTimer:IsPastSimMS(aimTime) then
			SharpTimer:Reset()

			if TauBehaviors.EquipPrimaryWeapon(AI, Owner) then
				aimTime = 500
			elseif AI.deviceState == AHuman.AIMING then
				aimTime = RangeRand(1000, 3000)
				AI.deviceState = AHuman.POINTING
			else
				aimTime = RangeRand(6000, 12000) * angDiff
				AI.deviceState = AHuman.AIMING
			end

			if SceneMan:ShortestDistance(Owner.Pos, AI.SentryPos, false).Magnitude > Owner.Height * 0.7 then
				AI.SentryPos = SceneMan:MovePointToGround(AI.SentryPos, Owner.Height * 0.25, 2)
				Owner:ClearAIWaypoints()
				Owner:AddAISceneWaypoint(AI.SentryPos)
				AI:CreateGoToBehavior(Owner) -- try to return to the sentry pos
				break
			elseif Owner.HFlipped ~= AI.SentryFacing then
				Owner.HFlipped = AI.SentryFacing -- turn to the direction we have been order to guard
				break -- restart this behavior
			end
		end

		coroutine.yield() -- wait until next frame
	end

	return true
end

function TauBehaviors.Patrol(AI, Owner)
	while AI.flying or Owner.Vel.Magnitude > 4 do -- wait untill we are stationary
		return true
	end

	if TauBehaviors.EquipPrimaryWeapon(AI, Owner) then
		local EquipTimer = Timer()
		while true do
			if EquipTimer:IsPastSimMS(500) then
				if not TauBehaviors.EquipPrimaryWeapon(AI, Owner) then
					break -- our current weapon is either a primary, we have no primary or we have no weapon
				end
			end

			coroutine.yield()
		end
	end

	local Free = Vector()
	local WptA, WptB

	-- look for a path to the right
	SceneMan:CastObstacleRay(
		Owner.Pos,
		Vector(512, 0),
		Vector(),
		Free,
		Owner.ID,
		Owner.IgnoresWhichTeam,
		rte.grassID,
		4
	)
	local Dist = SceneMan:ShortestDistance(Owner.Pos, Free, false)

	if Dist.Magnitude > 20 then
		Owner:ClearAIWaypoints()
		Owner:AddAISceneWaypoint(Free)
		coroutine.yield() -- wait until next frame
		Owner:UpdateMovePath()
		coroutine.yield() -- wait until next frame

		local PrevPos = Vector(Owner.Pos.X, Owner.Pos.Y)
		for WptPos in Owner.MovePath do
			if math.abs(PrevPos.Y - WptPos.Y) > 14 then
				break
			end

			WptA = Vector(PrevPos.X, PrevPos.Y)
			PrevPos:SetXY(WptPos.X, WptPos.Y)
		end
	end

	-- look for a path to the left
	SceneMan:CastObstacleRay(
		Owner.Pos,
		Vector(-512, 0),
		Vector(),
		Free,
		Owner.ID,
		Owner.IgnoresWhichTeam,
		rte.grassID,
		4
	)
	Dist = SceneMan:ShortestDistance(Owner.Pos, Free, false)

	if Dist.Magnitude > 20 then
		Owner:ClearAIWaypoints()
		Owner:AddAISceneWaypoint(Free)
		coroutine.yield() -- wait until next frame
		Owner:UpdateMovePath()
		coroutine.yield() -- wait until next frame

		local PrevPos = Vector(Owner.Pos.X, Owner.Pos.Y)
		for WptPos in Owner.MovePath do
			if math.abs(PrevPos.Y - WptPos.Y) > 14 then
				break
			end

			WptB = Vector(PrevPos.X, PrevPos.Y)
			PrevPos:SetXY(WptPos.X, WptPos.Y)
		end
	end

	Owner:ClearAIWaypoints()
	coroutine.yield() -- wait until next frame

	if WptA then
		Dist = SceneMan:ShortestDistance(Owner.Pos, WptA, false)
		if Dist.Magnitude > 20 then
			Owner:AddAISceneWaypoint(WptA)
		else
			WptA = nil
		end
	end

	if WptB then
		Dist = SceneMan:ShortestDistance(Owner.Pos, WptB, false)
		if Dist.Magnitude > 20 then
			Owner:AddAISceneWaypoint(WptB)
		else
			WptB = nil
		end
	end

	if WptA or WptB then
		AI:CreateGoToBehavior(Owner)
	else -- no path was found
		local FlipTimer = Timer()
		FlipTimer:SetSimTimeLimitMS(3000)
		while true do
			coroutine.yield() -- wait until next frame
			if FlipTimer:IsPastSimTimeLimit() then
				FlipTimer:Reset()
				FlipTimer:SetSimTimeLimitMS(RangeRand(2000, 5000))
				Owner.HFlipped = not Owner.HFlipped -- turn around and try the other direction sometimes
				if PosRand() < 0.3 then
					break -- end the behavior
				end
			end
		end
	end

	return true
end

function TauBehaviors.GoldDig(AI, Owner)
	if not Owner:EquipDiggingTool(false) then
		AI:CreateGetToolBehavior(Owner)
		return true
	end

	-- make sure our weapon have ammo before we start to dig, just in case we encounter an enemy while digging
	if
		Owner.EquippedItem
		and (Owner.FirearmNeedsReload or Owner.FirearmIsEmpty)
		and Owner.EquippedItem:HasObjectInGroup("Weapons")
	then
		Owner:ReloadFirearms()

		repeat
			coroutine.yield() -- wait until next frame
		until not Owner.FirearmIsEmpty
	end

	Owner:EquipDiggingTool(true)

	local aimAngle = 0.45
	local LookVec = Vector(180, 0):RadRotate(aimAngle)
	local GoldPos = Vector()
	local BestGoldPos = Vector()
	local smallestPenalty = math.huge

	while true do
		AI.Ctrl.AnalogAim = LookVec.Normalized
		if SceneMan:CastMaterialRay(Owner.EyePos, LookVec, rte.goldID, GoldPos, 1, true) then
			-- avoid gold close to the edeges of the scene
			if
				GoldPos.Y < SceneMan.SceneHeight - 25
				and (SceneMan.SceneWrapsX or (GoldPos.X > 50 and GoldPos.X < SceneMan.SceneWidth - 50))
			then
				local Dist = SceneMan:ShortestDistance(Owner.Pos, GoldPos, false) -- prioritize gold close to us
				local str = SceneMan:CastStrengthSumRay(Owner.EyePos, GoldPos, 3, rte.goldID) / 30 -- prioritize gold in soft ground
				local penalty = str + Dist.Magnitude + Dist.Y ^ 2

				-- prioritize gold located horizontaly relative to us
				if math.abs(Dist.X) > math.abs(Dist.Y) then
					penalty = penalty - 40
				end

				-- prioritize gold below us
				if Dist.Y > 0 then
					penalty = penalty - 5
				end

				if penalty < smallestPenalty then
					if Dist.Magnitude < 50 then -- dig to a point behind the gold
						GoldPos = Owner.Pos + Dist:SetMagnitude(55)
					end

					-- make sure there is no metal in our path
					if
						not SceneMan:CastStrengthRay(
							Owner.Pos,
							Dist:SetMagnitude(60),
							95,
							Vector(),
							2,
							rte.grassID,
							SceneMan.SceneWrapsX
						)
					then
						smallestPenalty = penalty + RangeRand(-10, 10)
						BestGoldPos:SetXY(GoldPos.X, GoldPos.Y)
					end
				end
			end
		end

		if aimAngle < -3.6 then
			break
		else
			aimAngle = aimAngle - 0.033

			-- search further away horizontaly
			if aimAngle < -0.8 and aimAngle > -2.4 then
				LookVec = Vector(120, 0):RadRotate(aimAngle)
			else
				LookVec = Vector(180, 0):RadRotate(aimAngle)
			end

			coroutine.yield() -- wait until next frame
		end
	end

	if BestGoldPos.Largest == 0 then
		if Owner.Pos.Y < SceneMan.SceneHeight - 50 then -- don't dig beyond the scene limit
			-- no gold found, so dig down and try again
			local rayLenght = 60
			local Target = Owner.Pos + Vector(rayLenght, rayLenght)
			local str_r = SceneMan:CastStrengthSumRay(Owner.Pos, Target, 6, rte.goldID)
			coroutine.yield() -- wait until next frame

			Target = Owner.Pos + Vector(-rayLenght, rayLenght)
			local str_l = SceneMan:CastStrengthSumRay(Owner.Pos, Target, 6, rte.goldID)
			coroutine.yield() -- wait until next frame

			if str_r < str_l then
				BestGoldPos = Owner.Pos + Vector(rayLenght, rayLenght)
			else
				BestGoldPos = Owner.Pos + Vector(-rayLenght, rayLenght)
			end
		else
			-- no gold here, and we cannot dig deeper, calculate average horizontal strength
			local rayLenght = 80
			local Target = Owner.Pos + Vector(rayLenght, -5)
			local Trace = SceneMan:ShortestDistance(Owner.Pos, Target, false)
			local str_r = SceneMan:CastStrengthSumRay(Owner.Pos, Target, 5, rte.goldID)
			local obst_r = SceneMan:CastStrengthRay(
				Owner.Pos,
				Trace,
				95,
				Vector(),
				2,
				rte.grassID,
				SceneMan.SceneWrapsX
			)
			coroutine.yield() -- wait until next frame

			Target = Owner.Pos + Vector(-rayLenght, -5)
			Trace = SceneMan:ShortestDistance(Owner.Pos, Target, false)
			local str_l = SceneMan:CastStrengthSumRay(Owner.Pos, Target, 5, rte.goldID)
			local obst_l = SceneMan:CastStrengthRay(
				Owner.Pos,
				Trace,
				95,
				Vector(),
				2,
				rte.grassID,
				SceneMan.SceneWrapsX
			)
			coroutine.yield() -- wait until next frame

			local goLeft
			if obst_l then
				goLeft = false
			elseif obst_r then
				goLeft = true
			else
				goLeft = math.random() > 0.5

				-- go towards the larger obstacle, unless metal
				if math.abs(str_l - str_r) > 200 then
					if str_r > str_l and not obst_r then
						goLeft = false
					elseif str_r < str_l and not obst_l then
						goLeft = true
					end
				end
			end

			if goLeft then
				BestGoldPos = Owner.Pos + Vector(-rayLenght, -5)
			else
				BestGoldPos = Owner.Pos + Vector(rayLenght, -5)
			end
		end
	end

	BestGoldPos.Y = math.min(BestGoldPos.Y, SceneMan.SceneHeight - 30)
	Owner:ClearAIWaypoints()
	Owner:AddAISceneWaypoint(BestGoldPos)
	AI:CreateGoToBehavior(Owner)

	return true
end

-- find the closest enemy brain
function TauBehaviors.BrainSearch(AI, Owner)
	if TauBehaviors.EquipPrimaryWeapon(AI, Owner) then
		local EquipTimer = Timer()
		while true do
			if EquipTimer:IsPastSimMS(500) then
				if not TauBehaviors.EquipPrimaryWeapon(AI, Owner) then
					break -- our current weapon is either a primary, we have no primary or we have no weapon
				end
			end

			coroutine.yield()
		end
	end

	local Brains = {}
	for Act in MovableMan.Actors do
		if Act.Team ~= Owner.Team and Act:HasObjectInGroup("Brains") then
			table.insert(Brains, Act)
		end
	end

	if #Brains < 1 then -- no bain actors found, check if some other actor is the brain
		local GmActiv = ActivityMan:GetActivity()
		for player = Activity.PLAYER_1, Activity.MAXPLAYERCOUNT - 1 do
			if GmActiv:PlayerActive(player) and GmActiv:GetTeamOfPlayer(player) ~= Owner.Team then
				local Act = GmActiv:GetPlayerBrain(player)
				if Act and MovableMan:IsActor(Act) then
					table.insert(Brains, Act)
				end
			end
		end
	end

	if #Brains > 0 then
		coroutine.yield() -- wait until next frame

		if #Brains == 1 then
			if MovableMan:IsActor(Brains[1]) then
				Owner:ClearAIWaypoints()
				AI.FollowingActor = Brains[1]
				Owner:AddAIMOWaypoint(AI.FollowingActor)
				AI:CreateGoToBehavior(Owner)
			end
		else
			local ClosestBrain
			local minDist = math.huge
			for _, Act in pairs(Brains) do
				-- measure how easy the path to the destination is to traverse
				if MovableMan:IsActor(Act) then
					Owner:ClearAIWaypoints()
					Owner:AddAISceneWaypoint(Act.Pos)
					Owner:UpdateMovePath()

					local OldWpt, deltaY
					local index = 0
					local height = 0
					local pathLength = 0
					local pathObstMaxHeight = 0
					for Wpt in Owner.MovePath do
						pathLength = pathLength + 1
						Wpt = SceneMan:MovePointToGround(Wpt, 15, 6)

						if OldWpt then
							deltaY = OldWpt.Y - Wpt.Y
							if deltaY > 20 then -- Wpt is more than n pixels above OldWpt in the scene
								if deltaY / math.abs(SceneMan:ShortestDistance(OldWpt, Wpt, false).X) > 1 then -- the slope is more than 45 degrees
									height = height + (OldWpt.Y - Wpt.Y)
									pathObstMaxHeight = math.max(pathObstMaxHeight, height)
								else
									height = 0
								end
							else
								height = 0
							end
						end

						OldWpt = Wpt

						if index > 30 then
							index = 0
							coroutine.yield() -- wait until the next frame
						else
							index = index + 1
						end
					end

					local score = pathLength * 0.55 + math.floor(pathObstMaxHeight / 27) * 8
					if score < minDist then
						minDist = score
						ClosestBrain = Act
					end

					coroutine.yield() -- wait until next frame
				end
			end

			Owner:ClearAIWaypoints()

			if MovableMan:IsActor(ClosestBrain) then
				AI.FollowingActor = ClosestBrain
				Owner:AddAIMOWaypoint(AI.FollowingActor)
				AI:CreateGoToBehavior(Owner)
			else
				return true -- the brain we found died while we where searching, restart this behavior next frame
			end
		end
	else -- no enemy brains left
		if AI.isPlayerOwned then
			Owner.AIMode = Actor.AIMODE_SENTRY
		else
			Owner.AIMode = Actor.AIMODE_PATROL
		end
	end

	return true
end

-- find a weapon to pick up
function TauBehaviors.WeaponSearch(AI, Owner)
	local range, minDist, HD
	local Devices = {}
	local pickupDiggers = not Owner:EquipDiggingTool(false)

	if AI.isPlayerOwned then
		minDist = 70 -- don't move player actors more than 3.5m
	else
		minDist = FrameMan.PlayerScreenWidth * 0.45
	end

	for Item in MovableMan.Items do -- store all HeldDevices of the correct type and within a cerain range in a table
		HD = ToHeldDevice(Item)
		if not HD:IsActivated() and HD.Vel.Magnitude < 2 then
			range = SceneMan:ShortestDistance(Owner.Pos, HD.Pos, false).Magnitude
			if range < minDist and not SceneMan:IsUnseen(HD.Pos.X, HD.Pos.Y, Owner.Team) then
				table.insert(Devices, HD)
			end
		end
	end

	if #Devices > 0 then
		coroutine.yield() -- wait until next frame

		local PrevWpt
		if not AI.FollowingActor then
			if Owner.AIMode == Actor.AIMODE_SENTRY and not AI.flying then
				PrevWpt = Vector(Owner.Pos.X, Owner.Pos.Y) -- return here after pick up
			else
				PrevWpt = Owner:GetLastAIWaypoint()
				if (PrevWpt - Owner.Pos).Largest < 1 then
					PrevWpt = nil -- we have no waypoint
				end
			end
		end

		if AI.isPlayerOwned then
			minDist = 10 -- # of waypoints
		else
			minDist = 48
		end

		local waypoints
		local DevicesToPickUp = {}
		for _, Item in pairs(Devices) do
			if MovableMan:IsDevice(Item) then
				Owner:ClearAIWaypoints()
				Owner:AddAISceneWaypoint(Item.Pos)
				Owner:UpdateMovePath()

				-- estimate the walking distance to the item
				if Item.ClassName == "TDExplosive" then
					waypoints = Owner.MovePathSize * 1.4 -- prioritize non-grenades
				elseif Item:IsTool() then
					if pickupDiggers then
						waypoints = Owner.MovePathSize * 1.8 -- prioritize non-diggers
					else
						waypoints = minDist -- don't pick up
					end
				else
					waypoints = Owner.MovePathSize
				end

				if waypoints < minDist then
					table.insert(DevicesToPickUp, { HD = Item, range = waypoints })
				end

				coroutine.yield() -- wait until next frame
			end
		end

		Owner:ClearAIWaypoints()
		table.sort(DevicesToPickUp, function(A, B)
			return A.range < B.range
		end) -- sort the items in order of distance
		coroutine.yield() -- wait until next frame

		AI.PickupHD = nil
		for _, Data in pairs(DevicesToPickUp) do
			if MovableMan:IsDevice(Data.HD) then
				AI.PickupHD = Data.HD
				break
			end
		end

		if AI.PickupHD then
			if PrevWpt then
				AI.PrevAIWaypoint = PrevWpt
			end

			Owner:AddAIMOWaypoint(AI.PickupHD)
			AI:CreateGoToBehavior(Owner)
		else -- no items found
			if AI.FollowingActor and MovableMan:IsActor(AI.FollowingActor) then
				Owner:AddAIMOWaypoint(AI.FollowingActor)
			elseif AI.PrevAIWaypoint then
				Owner:AddAISceneWaypoint(AI.PrevAIWaypoint)
			end
		end
	end

	return true
end

-- find a tool to pick up
function TauBehaviors.ToolSearch(AI, Owner)
	local range, minDist, HD
	local Devices = {}

	if Owner.AIMode == Actor.AIMODE_GOLDDIG then
		minDist = FrameMan.PlayerScreenWidth * 0.5 -- move up to half a screen when digging
	elseif AI.isPlayerOwned then
		minDist = 50 -- don't move player actors more than 2.5m
	else
		minDist = FrameMan.PlayerScreenWidth * 0.3
	end

	for Item in MovableMan.Items do -- store all HeldDevices of the correct type and within a cerain range in a table
		HD = ToHeldDevice(Item)
		if HD and HD:IsTool() and HD.Vel.Magnitude < 2 then
			range = SceneMan:ShortestDistance(Owner.Pos, HD.Pos, false).Magnitude
			if range < minDist and not SceneMan:IsUnseen(HD.Pos.X, HD.Pos.Y, Owner.Team) then
				table.insert(Devices, HD)
			end
		end
	end

	if #Devices > 0 then
		coroutine.yield() -- wait until next frame

		local PrevWpt
		if not AI.FollowingActor then
			if Owner.AIMode == Actor.AIMODE_SENTRY and not AI.flying then
				PrevWpt = Vector(Owner.Pos.X, Owner.Pos.Y) -- return here after pick up
			else
				PrevWpt = Owner:GetLastAIWaypoint()
				if (PrevWpt - Owner.Pos).Largest < 1 then
					PrevWpt = nil -- we have no waypoint
				end
			end
		end

		if Owner.AIMode == Actor.AIMODE_GOLDDIG then
			minDist = 30
		elseif AI.isPlayerOwned then
			minDist = 5
		else
			minDist = 15
		end

		for _, Item in pairs(Devices) do
			if MovableMan:IsDevice(Item) then
				Owner:ClearAIWaypoints()
				Owner:AddAISceneWaypoint(Item.Pos)
				Owner:UpdateMovePath()

				local waypoints = Owner.MovePathSize -- estimate the walking distance to the item
				if waypoints < minDist then
					minDist = waypoints
					AI.PickupHD = Item
				end

				coroutine.yield() -- wait until next frame
			end
		end

		Owner:ClearAIWaypoints()

		if MovableMan:IsDevice(AI.PickupHD) then
			if PrevWpt then
				AI.PrevAIWaypoint = PrevWpt
			end

			Owner:AddAIMOWaypoint(AI.PickupHD)
			AI:CreateGoToBehavior(Owner)
		else
			AI.PickupHD = nil -- the item became invalid while searching

			if AI.FollowingActor and MovableMan:IsActor(AI.FollowingActor) then
				Owner:AddAIMOWaypoint(AI.FollowingActor)
			elseif AI.PrevAIWaypoint then
				Owner:AddAISceneWaypoint(AI.PrevAIWaypoint)
			end
		end
	end

	return true
end

-- move to the next waypoint
function TauBehaviors.GoToWpt(AI, Owner)
	if not Owner.MOMoveTarget then
		if SceneMan:ShortestDistance(Owner:GetLastAIWaypoint(), Owner.Pos, false).Largest < 10 then
			Owner:ClearAIWaypoints()
			if Owner.AIMode == Actor.AIMODE_GOTO then
				Owner.AIMode = Actor.AIMODE_SENTRY
			end
			return true
		end
	end

	-- is Y1 lower down in the scene, compared to Y2?
	local Lower = function(Y1, Y2, margin)
		return Y1.Pos.Y - margin > Y2.Pos.Y
	end

	local ArrivedTimer = Timer()
	local BurstTimer = Timer()
	local UpdatePathTimer = Timer()

	if Owner.MOMoveTarget then
		UpdatePathTimer:SetSimTimeLimitMS(6000)
	else
		UpdatePathTimer:SetSimTimeLimitMS(15000)
	end

	local NoLOSTimer = Timer()
	NoLOSTimer:SetSimTimeLimitMS(1000)

	local StuckTimer = Timer()
	StuckTimer:SetSimTimeLimitMS(2000)

	local nextLatMove = AI.lateralMoveState
	local nextAimAngle = Owner:GetAimAngle(false) * 0.95
	local scanAng = 0 -- for obstacle detection
	local Obstacles = {}
	local PrevWptPos = Owner.Pos
	local sweepCW = true
	local sweepRange = 0
	local digState = AHuman.NOTDIGGING
	local obstacleState = Actor.PROCEEDING
	local WptList, Waypoint, Dist, CurrDist
	local Obst = { R_LOW = 1, R_FRONT = 2, R_HIGH = 3, R_UP = 5, L_UP = 6, L_HIGH = 8, L_FRONT = 9, L_LOW = 10 }

	while true do
		if Owner.Vel.Largest > 2 then
			StuckTimer:Reset()
		end

		if Owner.MOMoveTarget then -- make the last waypoint marker stick to the MO we are following
			if MovableMan:ValidMO(Owner.MOMoveTarget) then
				Owner:RemoveMovePathEnd()
				Owner:AddToMovePathEnd(Owner.MOMoveTarget.Pos)

				if Owner.Team == Owner.MOMoveTarget.Team and not AI.flying then -- we are following an ally, stop when close
					while
						SceneMan:ShortestDistance(Owner.Pos, Owner.MOMoveTarget.Pos, false).Magnitude
						< Owner.Radius + Owner.MOMoveTarget.Radius + 10
					do
						coroutine.yield() -- wait until next frame

						if not MovableMan:ValidMO(Owner.MOMoveTarget) then
							Owner:ClearMovePath()
							break
						end
					end
				end
			else
				Owner:ClearMovePath()
			end
		end

		if not AI.flying and UpdatePathTimer:IsPastSimTimeLimit() then
			UpdatePathTimer:Reset()

			if Waypoint and AI.BlockingActor then
				if MovableMan:IsActor(AI.BlockingActor) then
					CurrDist = SceneMan:ShortestDistance(Owner.Pos, Waypoint.Pos, false)
					if
						(Owner.Pos.X > AI.BlockingActor.Pos.X and CurrDist.X < Owner.Pos.X)
						or (Owner.Pos.X < AI.BlockingActor.Pos.X and CurrDist.X > Owner.Pos.X)
						or SceneMan:ShortestDistance(Owner.Pos, AI.BlockingActor.Pos, false).Magnitude
							> Owner.Diameter + AI.BlockingActor.Diameter
					then
						AI.BlockingActor = nil -- the blocking actor is not in the way any longer
						AI.teamBlockState = Actor.NOTBLOCKED
					else
						AI.BlockedTimer:Reset()
						AI.teamBlockState = Actor.IGNORINGBLOCK
						AI:CreateMoveAroundBehavior(Owner)
						break -- end this behavior
					end
				else
					AI.BlockingActor = nil
				end
			end

			AI.deviceState = AHuman.STILL
			AI.proneState = AHuman.NOTPRONE
			AI.jump = false
			nextLatMove = Actor.LAT_STILL
			digState = AHuman.NOTDIGGING
			Waypoint = nil
			WptList = nil
		elseif StuckTimer:IsPastSimTimeLimit() then -- dislodge
			if AI.jump then
				if Owner.JetTimeLeft < TimerMan.DeltaTimeMS * 3 then -- out of fuel
					AI.jump = false
					AI.refuel = true
					nextLatMove = Actor.LAT_STILL
				else
					local chance = PosRand()
					if chance < 0.1 then
						nextLatMove = Actor.LAT_LEFT
					elseif chance > 0.9 then
						nextLatMove = Actor.LAT_RIGHT
					else
						nextLatMove = Actor.LAT_STILL
					end
				end
			else
				if PosRand() < 0.2 then
					if AI.lateralMoveState == Actor.LAT_LEFT then
						nextLatMove = Actor.LAT_RIGHT
					else
						nextLatMove = Actor.LAT_LEFT
					end
				end

				if AI.refuel and Owner.JetTimeLeft > Owner.JetTimeTotal * 0.95 then
					AI.jump = true
					BurstTimer:SetSimTimeLimitMS(500) -- this burst last until the BurstTimer expire
					BurstTimer:Reset()
				end
			end
		elseif WptList then -- we have a list of waypoints, folow it
			if #WptList < 1 and not Waypoint then -- arrived
				if Owner.MOMoveTarget and MovableMan:ValidMO(Owner.MOMoveTarget) then
					if Owner.Team ~= Owner.MOMoveTarget.Team then
						Waypoint = { Pos = Owner.MOMoveTarget.Pos }
					else
						nextLatMove = Actor.LAT_STILL
						AI.jump = false
						coroutine.yield() -- wait until next frame
					end
				else
					break
				end
			else
				if not Waypoint then -- get the next waypoint in the list
					-- we must update the path more often if we are following someone
					if Owner.MOMoveTarget and MovableMan:ValidMO(Owner.MOMoveTarget) then
						if
							SceneMan:ShortestDistance(Owner:GetLastAIWaypoint(), Owner.MOMoveTarget.Pos, false).Largest
							> 80
						then -- the target has moved
							WptList = nil
							Waypoint = nil
						else
							UpdatePathTimer:Reset()
						end
					else
						UpdatePathTimer:Reset()
					end

					if WptList then
						local NextWptPos = WptList[1].Pos
						Dist = SceneMan:ShortestDistance(Owner.Pos, NextWptPos, false)
						if Dist.Y < -25 and math.abs(Dist.X) < 30 then -- avoid any corners if the next waypoint is above us
							local cornerType
							local CornerPos = Vector(NextWptPos.X, NextWptPos.Y)
							if Owner.Pos.X > CornerPos.X then
								CornerPos = CornerPos + Vector(25, -40)
								cornerType = "right"
							else
								CornerPos = CornerPos + Vector(-25, -40)
								cornerType = "left"
							end

							local Free = Vector()
							Dist = SceneMan:ShortestDistance(NextWptPos, CornerPos, false)
							-- make sure the corner waypoint is not inside terrain
							local pixels = SceneMan:CastObstacleRay(
								NextWptPos,
								Dist,
								Vector(),
								Free,
								Owner.ID,
								Owner.IgnoresWhichTeam,
								rte.grassID,
								3
							)
							if pixels == 0 then
								break -- the waypoint is inside terrain, plot a new path
							elseif pixels > 0 then
								CornerPos = (NextWptPos + Free) / 2 -- compensate for obstacles
							end

							coroutine.yield() -- wait until next frame

							-- check if we have LOS
							Dist = SceneMan:ShortestDistance(Owner.Pos, CornerPos, false)
							if
								0
								<= SceneMan:CastObstacleRay(
									Owner.Pos,
									Dist,
									Vector(),
									Vector(),
									Owner.ID,
									Owner.IgnoresWhichTeam,
									rte.grassID,
									4
								)
							then
								-- CornerPos is blocked
								CornerPos.X = Owner.Pos.X -- move CornerPos straight above us
								cornerType = "air"
							end

							coroutine.yield() -- wait until next frame

							Waypoint = { Pos = CornerPos, Type = cornerType }
							if #WptList > 1 and not WptList[1].Type then -- remove the waypoint after the corner if possible
								table.remove(WptList, 1)
								Owner:RemoveMovePathBeginning() -- clean up the graphical representation of the path
							end

							Owner:AddToMovePathBeginning(Waypoint.Pos)
						else
							Waypoint = table.remove(WptList, 1)
							if Waypoint.Type ~= "air" then
								local Free = Vector()

								-- only if we have a digging tool
								if
									(Owner.AIMode == Actor.AIMODE_GOLDDIG or Waypoint.Type ~= "drop")
									and Owner:EquipDiggingTool(false)
								then
									local PathSegRay = SceneMan:ShortestDistance(PrevWptPos, Waypoint.Pos, false) -- detect material blocking the path and start digging through it
									if
										AI.teamBlockState ~= Actor.BLOCKED
										and SceneMan:CastStrengthRay(
											PrevWptPos,
											PathSegRay,
											4,
											Free,
											2,
											rte.doorID,
											true
										)
									then
										if
											SceneMan:ShortestDistance(Owner.Pos, Free, false).Magnitude
											< Owner.Height * 0.5
										then -- check that we're close enough to start digging
											digState = AHuman.STARTDIG
											AI.deviceState = AHuman.DIGGING
											obstacleState = Actor.DIGPAUSING
											nextLatMove = Actor.LAT_STILL
											sweepRange = math.pi / 4
											StuckTimer:SetSimTimeLimitMS(6000)
											AI.Ctrl.AnalogAim = SceneMan:ShortestDistance(
												Owner.Pos,
												Waypoint.Pos,
												false
											).Normalized -- aim in the direction of the next waypoint
										else
											digState = AHuman.NOTDIGGING
											obstacleState = Actor.PROCEEDING
										end

										coroutine.yield() -- wait until next frame
									else
										digState = AHuman.NOTDIGGING
										obstacleState = Actor.PROCEEDING
										StuckTimer:SetSimTimeLimitMS(1500)
									end
								end

								if digState == AHuman.NOTDIGGING and AI.deviceState ~= AHuman.DIGGING then
									-- if our path isn't blocked enough to dig, but the headroom is too little, start crawling to get through
									local Heading = SceneMan
										:ShortestDistance(Owner.Pos, Waypoint.Pos, false)
										:SetMagnitude(Owner.Height * 0.5)

									-- don't crawl if it's too steep, climb then instead
									if
										math.abs(Heading.X) > math.abs(Heading.Y)
										and Owner.Head
										and Owner.Head:IsAttached()
									then
										local TopHeadPos = Owner.Head.Pos - Vector(0, Owner.Head.Radius * 0.7)

										-- first check up to the top of the head, and then from there forward
										if
											SceneMan:CastStrengthRay(
												Owner.Pos,
												TopHeadPos - Owner.Pos,
												5,
												Free,
												4,
												rte.doorID,
												true
											)
											or SceneMan:CastStrengthRay(
												TopHeadPos,
												Heading,
												5,
												Free,
												4,
												rte.doorID,
												true
											)
										then
											AI.proneState = AHuman.PRONE
										else
											AI.proneState = AHuman.NOTPRONE
										end

										coroutine.yield() -- wait until next frame
									else
										AI.proneState = AHuman.NOTPRONE
									end
								end
							end
						end

						if not Waypoint.Type then
							ArrivedTimer:SetSimTimeLimitMS(100)
						elseif Waypoint.Type == "last" then
							ArrivedTimer:SetSimTimeLimitMS(500)
						else -- air or corner wpt
							ArrivedTimer:SetSimTimeLimitMS(25)
						end
					end
				elseif #WptList > 1 then -- check if some other waypoint is closer
					local test = math.random(1, 15)
					local RandomWpt = WptList[test]
					if RandomWpt then
						Dist = SceneMan:ShortestDistance(Owner.Pos, RandomWpt.Pos, false)
						local mag = Dist.Magnitude
						if
							mag < 50 and mag < SceneMan:ShortestDistance(Owner.Pos, Waypoint.Pos, false).Magnitude / 3
						then
							-- this waypoint is closer, check LOS
							if
								-1
								== SceneMan:CastObstacleRay(
									Owner.Pos,
									Dist,
									Vector(),
									Vector(),
									Owner.ID,
									Owner.IgnoresWhichTeam,
									rte.grassID,
									4
								)
							then
								Waypoint = RandomWpt -- go here instead
								if WptList[test - 1] then
									PrevWptPos = WptList[test - 1].Pos
								else
									PrevWptPos = Owner.Pos
								end

								test = math.min(test, #WptList)
								for _ = 1, test do -- delete the earlier waypoints
									table.remove(WptList, 1)
									if #WptList > 0 then
										Owner:RemoveMovePathBeginning()
									end
								end
							end
						end
					end
				end

				if Waypoint then
					CurrDist = SceneMan:ShortestDistance(Owner.Pos, Waypoint.Pos, false)

					-- digging
					if digState ~= AHuman.NOTDIGGING then
						if not AI.Target and Owner:EquipDiggingTool(true) then -- switch to the digger if we have one
							if Owner.FirearmIsEmpty then -- reload if it's empty
								AI.fire = false
								AI.Ctrl:SetState(Controller.WEAPON_RELOAD, true)
							else
								if AI.teamBlockState == Actor.BLOCKED then
									AI.fire = false
									nextLatMove = Actor.LAT_STILL
								else
									if obstacleState == Actor.PROCEEDING then
										if CurrDist.X < -1 then
											nextLatMove = Actor.LAT_LEFT
										elseif CurrDist.X > 1 then
											nextLatMove = Actor.LAT_RIGHT
										end
									else
										nextLatMove = Actor.LAT_STILL
									end

									-- check if we are close enough to dig
									if
										SceneMan:ShortestDistance(PrevWptPos, Owner.Pos, false).Magnitude
											> Owner.Height * 0.5
										and SceneMan:ShortestDistance(Owner.Pos, Waypoint.Pos, false).Magnitude
											> Owner.Height * 0.5
									then
										digState = AHuman.NOTDIGGING
										obstacleState = Actor.PROCEEDING
										AI.deviceState = AHuman.STILL
										AI.fire = false
										Owner:EquipFirearm(true)
									else
										-- see if we have dug out all that we can in the sweep area without moving closer
										local centerAngle = CurrDist.AbsRadAngle
										local Ray = Vector(Owner.Height * 0.3, 0):RadRotate(centerAngle) -- center
										if SceneMan:CastNotMaterialRay(Owner.Pos, Ray, 0, 3, false) < 0 then
											coroutine.yield() -- wait until next frame

											-- now check the tunnel's thickness
											Ray = Vector(Owner.Height * 0.3, 0):RadRotate(centerAngle + sweepRange) -- up
											if SceneMan:CastNotMaterialRay(Owner.Pos, Ray, rte.airID, 3, false) < 0 then
												coroutine.yield() -- wait until next frame

												Ray = Vector(Owner.Height * 0.3, 0):RadRotate(centerAngle - sweepRange) -- down
												if
													SceneMan:CastNotMaterialRay(Owner.Pos, Ray, rte.airID, 3, false) < 0
												then
													obstacleState = Actor.PROCEEDING -- ok the tunnel section is clear, so start walking forward while still digging
												else
													obstacleState = Actor.DIGPAUSING -- tunnel cavity not clear yet, so stay put and dig some more
												end
											end
										else
											obstacleState = Actor.DIGPAUSING -- tunnel cavity not clear yet, so stay put and dig some more
										end

										coroutine.yield() -- wait until next frame

										local aimAngle = Owner:GetAimAngle(true)
										local AimVec = Vector(1, 0):RadRotate(aimAngle)

										local angDiff = math.asin(AimVec:Cross(CurrDist.Normalized)) -- the angle between CurrDist and AimVec
										if math.abs(angDiff) < sweepRange then
											AI.fire = true -- only fire the digger at the obstacle
										else
											AI.fire = false
										end

										-- sweep the digger between the two endpoints of the obstacle
										local DigTarget
										if sweepCW then
											DigTarget = Vector(Owner.Height * 0.4, 0):RadRotate(
												centerAngle + sweepRange
											)
										else
											DigTarget = Vector(Owner.Height * 0.4, 0):RadRotate(
												centerAngle - sweepRange
											)
										end

										angDiff = math.asin(AimVec:Cross(DigTarget.Normalized)) -- The angle between DigTarget and AimVec
										if math.abs(angDiff) < 0.1 then
											sweepCW = not sweepCW -- this is close enough, go in the other direction next frame
										else
											AI.Ctrl.AnalogAim = Vector(AimVec.X, AimVec.Y):RadRotate(-angDiff * 0.1)
										end

										-- check if we are done when we get close enough to the waypoint
										if
											SceneMan:ShortestDistance(Owner.Pos, Waypoint.Pos, false).Magnitude
											< Owner.Height * 0.25
										then
											if
												not SceneMan:CastStrengthRay(
													PrevWptPos,
													SceneMan:ShortestDistance(PrevWptPos, Waypoint.Pos, false),
													5,
													Vector(),
													1,
													rte.doorID,
													true
												)
												and not SceneMan:CastStrengthRay(
													Owner.EyePos,
													SceneMan:ShortestDistance(Owner.EyePos, Waypoint.Pos, false),
													5,
													Vector(),
													1,
													rte.doorID,
													true
												)
											then
												-- advance to the next waypoint, if there are any
												if #WptList > 0 then
													UpdatePathTimer:Reset()
													PrevWptPos = Waypoint.Pos
													Waypoint = table.remove(WptList, 1)
													if #WptList > 0 then
														Owner:RemoveMovePathBeginning()
													end
												end
											end

											coroutine.yield() -- wait until next frame
										end
									end
								end
							end
						else
							digState = AHuman.NOTDIGGING
							obstacleState = Actor.PROCEEDING
							AI.deviceState = AHuman.STILL
							AI.fire = false
							Owner:EquipFirearm(true)
						end
					else -- not digging
						if not AI.Target then
							AI.fire = false
						end

						-- Scan for obstacles
						local Trace = Vector(Owner.Diameter * 0.85, 0):RadRotate(scanAng)
						local Free = Vector()
						local index = math.floor(scanAng * 2.5 + 2.01)
						if
							SceneMan:CastObstacleRay(
								Owner.Pos,
								Trace,
								Vector(),
								Free,
								Owner.ID,
								Owner.IgnoresWhichTeam,
								rte.grassID,
								3
							) > -1
						then
							Obstacles[index] = true
						else
							Obstacles[index] = false
						end

						if scanAng < 1.57 then -- pi/2
							if scanAng > 1.2 then
								scanAng = 1.89
							else
								scanAng = scanAng + 0.55
							end
						else
							if scanAng > 3.5 then
								scanAng = -0.4
							else
								scanAng = scanAng + 0.55
							end
						end

						if not AI.jump and not AI.flying then
							coroutine.yield() -- wait until next frame
						end

						if CurrDist.Magnitude > Owner.Height / 3 then -- not close enough to the waypoint
							ArrivedTimer:Reset()

							-- check if we have LOS to the waypoint
							if
								SceneMan:CastObstacleRay(
									Owner.Pos,
									CurrDist,
									Vector(),
									Vector(),
									Owner.ID,
									Owner.IgnoresWhichTeam,
									rte.grassID,
									9
								) < 0
							then
								NoLOSTimer:Reset()
							elseif NoLOSTimer:IsPastSimTimeLimit() then -- calulate new path
								Waypoint = nil
								WptList = nil

								if
									Owner.AIMode == Actor.AIMODE_GOLDDIG
									and digState == AHuman.NOTDIGGING
									and math.random() < 0.5
								then
									return true -- end this behavior and look for gold again
								end
							end

							if not AI.jump and not AI.flying then
								coroutine.yield() -- wait until next frame
							end
						elseif ArrivedTimer:IsPastSimTimeLimit() then -- only remove a waypoint if we have been close to it for a while
							PrevWptPos = Waypoint.Pos
							Owner:RemoveMovePathBeginning()
							Waypoint = nil
						elseif AI.refuel and Owner.Vel.Y < 5 then
							if
								Owner.JetTimeLeft > Owner.JetTimeTotal * 0.95
								or (AI.flying and Owner.Vel.Y < -3 and Owner.JetTimeLeft > 0.5)
							then
								AI.refuel = false
							else
								AI.jump = false -- wait until the jetpack is full
								nextLatMove = Actor.LAT_STILL
							end
						end

						if Waypoint and not AI.refuel then -- move towards the waypoint
							nextAimAngle = Owner:GetAimAngle(false) * 0.95 -- look straight ahead

							-- control vertical movement
							local change
							if AI.flying then
								change = AI.YposPID:Update(CurrDist.Y + Owner.Vel.Y * 3, 0)
							else
								change = AI.YposPID:Update(CurrDist.Y, 0) -- ignore our velocity if on the ground
							end

							if
								math.abs(Owner.RotAngle) < 0.5
								and Owner.Vel.Y > -10
								and (change < -1 or Owner.Vel.Y > 10)
							then
								if not AI.jump then
									AI.jump = true
									BurstTimer:Reset() -- this burst last until the BurstTimer expire
								end

								if change < -6 then
									BurstTimer:SetSimTimeLimitMS(250)
								elseif change < -3 then
									BurstTimer:SetSimTimeLimitMS(500)
								else
									BurstTimer:SetSimTimeLimitMS(1000)
								end
							else
								AI.jump = false
							end

							-- control horisontal movement
							if AI.jump then
								if AI.flying then
									change = AI.XposPID:Update(CurrDist.X + Owner.Vel.X * 3, 0)
								else
									change = AI.XposPID:Update(CurrDist.X, 0) -- ignore our velocity if on the ground
								end

								if change < -0.5 then
									nextLatMove = Actor.LAT_LEFT
								elseif change > 0.5 then
									nextLatMove = Actor.LAT_RIGHT
								else
									nextAimAngle = nextAimAngle - (nextAimAngle - 1.2) * 0.2 -- look up to aim jetpack down
								end
							elseif Owner.FGLeg or Owner.BGLeg then
								if CurrDist.X < -3 then
									nextLatMove = Actor.LAT_LEFT
								elseif CurrDist.X > 3 then
									nextLatMove = Actor.LAT_RIGHT
								else
									nextLatMove = Actor.LAT_STILL
								end
							elseif (CurrDist.X < -5 and Owner.HFlipped) or (CurrDist.X > 5 and not Owner.HFlipped) then
								-- no legs, jump forward
								BurstTimer:Reset()
								AI.jump = true
							end

							if Waypoint.Type == "right" then
								if CurrDist.X > -3 then
									nextLatMove = Actor.LAT_RIGHT
								end
							elseif Waypoint.Type == "left" then
								if CurrDist.X < 3 then
									nextLatMove = Actor.LAT_LEFT
								end
							end

							-- must fire thrusters to move sideways when in the air
							if
								not AI.jump
								and AI.flying
								and Waypoint.Type ~= "drop"
								and Owner.Vel.Y > -5
								and CurrDist.Y - Owner.Vel.Y * 3 < 20 --TODO: use Ychange here?
							then
								change = math.abs(AI.XposPID:Update(CurrDist.X + Owner.Vel.X * 3, 0))
								if change > 0.5 then
									AI.jump = true
								end
							end

							if AI.jump then
								-- obstacle right
								for i = Obst.R_FRONT, Obst.R_UP do
									if Obstacles[i] then
										if Obstacles[Obst.R_UP] then
											AI.jump = false
										else
											nextAimAngle = nextAimAngle - (nextAimAngle - 1.2) * 0.2 -- look up to aim jetpack down
										end

										break
									end
								end

								-- obstacle left
								for i = Obst.L_UP, Obst.L_FRONT do
									if Obstacles[i] then
										if Obstacles[Obst.L_UP] then
											AI.jump = false
										else
											nextAimAngle = nextAimAngle - (nextAimAngle - 1.2) * 0.2 -- look up to aim jetpack down
										end

										break
									end
								end
							elseif Waypoint.Type ~= "drop" and not Lower(Waypoint, Owner, 20) then
								-- jump over low obstacles unless we want to jump off a ledge
								if
									nextLatMove == Actor.LAT_RIGHT
									and (Obstacles[Obst.R_LOW] or Obstacles[Obst.R_FRONT])
									and not Obstacles[Obst.R_UP]
								then
									AI.jump = true
									if Obstacles[Obst.R_HIGH] then
										nextLatMove = Actor.LAT_LEFT -- TODO: only when too close to the obstacle?
									end
								elseif
									nextLatMove == Actor.LAT_LEFT
									and (Obstacles[Obst.L_LOW] or Obstacles[Obst.L_FRONT])
									and not Obstacles[Obst.L_UP]
								then
									AI.jump = true
									if Obstacles[Obst.L_HIGH] then
										nextLatMove = Actor.LAT_RIGHT -- TODO: only when too close to the obstacle?
									end
								end
							end

							if math.abs(Owner.RotAngle) > 0.5 then
								AI.jump = false
							end
						end

						if not AI.Target then
							Owner:SetAimAngle(nextAimAngle)
						end
					end
				end
			end
		else
			-- ignore the path-finding and plot waypoints in a straight line to the target, if there is no metal in the way
			local Trace = SceneMan:ShortestDistance(Owner.Pos, Owner:GetLastAIWaypoint(), false)
			if
				Owner.AIMode == Actor.AIMODE_GOLDDIG
				and not AI.Target
				and not SceneMan:CastStrengthRay(Owner.Pos, Trace, 105, Vector(), 2, 0, true)
			then
				WptList = {} -- store the waypoints we want in our path here

				local wpts = math.ceil(Trace.Magnitude / 60)
				Trace:CapMagnitude(60)
				for i = 1, wpts do
					local TmpPos = Owner.Pos + Trace * i
					table.insert(WptList, { Pos = SceneMan:MovePointToGround(TmpPos, Owner.Height / 4, 4) })
				end

				-- create the move path seen on the screen
				for _, Wpt in pairs(WptList) do
					Owner:AddToMovePathEnd(Wpt.Pos)
				end

				Owner:DrawWaypoints(true)
				NoLOSTimer:Reset()
			else -- no waypoint list, create one in several small steps to reduce lag
				Owner:DrawWaypoints(false)
				Owner:UpdateMovePath()
				coroutine.yield() -- wait until next frame

				if Owner.MovePathSize < 1 then
					break
				end

				-- copy the MovePath to a temporary table so we can yield safely while working on the path
				local PathDump = {}
				for WptPos in Owner.MovePath do
					table.insert(PathDump, WptPos)
				end

				coroutine.yield() -- wait until next frame

				-- copy useful waypoints to a temporary path
				local TmpWpts = {}
				table.insert(TmpWpts, { Pos = Owner.Pos })
				local Origin
				local LastPos = PathDump[1]
				for _, WptPos in pairs(PathDump) do
					Origin = TmpWpts[#TmpWpts].Pos
					WptPos = SceneMan:MovePointToGround(WptPos, Owner.Height / 4, 4)
					if
						SceneMan:ShortestDistance(Origin, WptPos, false).Magnitude > 100 -- skip any waypoint too close to the previous one
						or SceneMan:CastStrengthSumRay(Origin, WptPos, 3, rte.grassID) > 5
					then
						table.insert(TmpWpts, { Pos = LastPos })
					end

					LastPos = WptPos
					coroutine.yield() -- wait until next frame
				end

				table.insert(TmpWpts, { Pos = PathDump[#PathDump] }) -- add the last waypoint in the MovePath

				coroutine.yield() -- wait until next frame

				WptList = {} -- store the waypoints we want in our path here
				local StartWpt = table.remove(TmpWpts, 1)
				while #TmpWpts > 0 do
					local NextWpt = table.remove(TmpWpts, 1)

					if Lower(NextWpt, StartWpt, 30) then -- scan for sharp drops	TODO: check the slope instead?
						NextWpt.Type = "drop"

						local GapList = {}
						for j, JumpWpt in pairs(TmpWpts) do -- look for the other side
							local Gap = SceneMan:ShortestDistance(StartWpt.Pos, JumpWpt.Pos, false)
							if Gap.Magnitude > 400 - Gap.Y then -- TODO: use actor properties here
								break -- too far
							end

							if Gap.Y > -40 then -- no more than 2m above
								table.insert(GapList, { Wpt = JumpWpt, score = math.abs(Gap.X / Gap.Y), index = j })
							end
						end

						coroutine.yield() -- wait until next frame

						table.sort(GapList, function(A, B)
							return A.score > B.score
						end) -- sort largest first

						for _, LZ in pairs(GapList) do
							-- check if we can jump
							local Trace = SceneMan:ShortestDistance(StartWpt.Pos, LZ.Wpt.Pos, false)
							if
								-1
								== SceneMan:CastObstacleRay(
									StartWpt.Pos,
									Trace,
									Vector(),
									Vector(),
									Owner.ID,
									Owner.IgnoresWhichTeam,
									rte.grassID,
									4
								)
							then
								-- find a point mid-air
								local TestPos = StartWpt.Pos + Trace / 2
								local Free = Vector()
								if
									0
									~= SceneMan:CastObstacleRay(
										TestPos,
										Vector(0, -math.abs(Trace.X) / 2),
										Vector(),
										Free,
										Owner.ID,
										Owner.IgnoresWhichTeam,
										rte.grassID,
										2
									)
								then -- TODO: check LOS? what if 0?
									table.insert(WptList, { Pos = Free + Vector(0, Owner.Height / 4), Type = "air" }) -- guide point in the air
									NextWpt = LZ.Wpt

									-- delete any waypoints between StartWpt and the LZ
									for i = LZ.index, 1, -1 do
										table.remove(TmpWpts, i)
									end

									break
								end
							end

							coroutine.yield() -- wait until next frame
						end
					end

					table.insert(WptList, NextWpt)
					StartWpt = NextWpt
				end

				WptList[#WptList].Type = "last"

				coroutine.yield() -- wait until next frame

				-- create the move path seen on the screen
				Owner:ClearMovePath()
				for _, Wpt in pairs(WptList) do
					Owner:AddToMovePathEnd(Wpt.Pos)
				end

				Owner:DrawWaypoints(true)
				NoLOSTimer:Reset()
			end
		end

		-- movement commands
		if AI.Target and AI.BehaviorName ~= "AttackTarget" then
			AI.lateralMoveState = Actor.LAT_STILL

			if AI.flying then
				if AI.jump and BurstTimer:IsPastSimTimeLimit() then -- trigger jetpack bursts
					BurstTimer:Reset()
					AI.jump = false
				end
			else
				AI.jump = false
			end
		else
			AI.lateralMoveState = nextLatMove
			if AI.jump and BurstTimer:IsPastSimTimeLimit() then -- trigger jetpack bursts
				BurstTimer:Reset()
				AI.jump = false
			end
		end

		if AI.BlockingActor then
			if
				not MovableMan:IsActor(AI.BlockingActor)
				or SceneMan:ShortestDistance(Owner.Pos, AI.BlockingActor.Pos, false).Magnitude
					> (Owner.Diameter + AI.BlockingActor.Diameter) * 1.2
			then
				AI.BlockingActor = nil
				AI.teamBlockState = Actor.NOTBLOCKED

				if Owner.AIMode == Actor.AIMODE_BRAINHUNT and AI.FollowingActor then
					AI.FollowingActor = nil
					break -- end this behavior
				end
			elseif AI.teamBlockState == Actor.NOTBLOCKED and Waypoint then
				if
					(Waypoint.Pos.X > Owner.Pos.X and AI.BlockingActor.Pos.X > Owner.Pos.X)
					or (Waypoint.Pos.X < Owner.Pos.X and AI.BlockingActor.Pos.X < Owner.Pos.X)
				then
					AI.teamBlockState = Actor.BLOCKED
					if
						Owner.AIMode == Actor.AIMODE_BRAINHUNT
						and Owner.AIMode == AI.BlockingActor.AIMode
						and (not AI.BlockingActor.MOMoveTarget or AI.BlockingActor.MOMoveTarget.ID ~= Owner.ID)
					then -- don't follow an actor that is following us
						AI.FollowingActor = AI.BlockingActor
						Owner:ClearAIWaypoints()
						Owner:AddAIMOWaypoint(AI.FollowingActor)
						AI:CreateGoToBehavior(Owner)
					end
				else
					AI.BlockingActor = nil
				end
			end
		end

		coroutine.yield() -- wait until next frame
	end

	return true
end

-- go prone if we can shoot from the prone position and return the result
function TauBehaviors.GoProne(AI, Owner, TargetPos, targetID)
	if not Owner.Head or AI.proneState == AHuman.PRONE then
		return false
	end

	-- only go prone if we can see the ground near the target
	local AimPoint = SceneMan:MovePointToGround(TargetPos, 10, 3)
	local ground = Owner.Pos.Y + Owner.Height * 0.25
	local Dist = SceneMan:ShortestDistance(Owner.Pos, AimPoint, false)
	local PronePos

	-- check if there is room to go prone here
	if Dist.X > 100 then
		-- to the right
		PronePos = Owner.EyePos + Vector(Owner.Height * 0.3, 0)

		local x_pos = Owner.Pos.X + 10
		for _ = 1, math.ceil(Owner.Height / 16) do
			x_pos = x_pos + 7
			if SceneMan.SceneWrapsX and x_pos > SceneMan.SceneWidth then
				x_pos = SceneMan.SceneWidth - x_pos
			end

			if 0 == SceneMan:GetTerrMatter(x_pos, ground) then
				return false
			end
		end
	elseif Dist.X < -100 then
		-- to the left
		PronePos = Owner.EyePos + Vector(-Owner.Height * 0.3, 0)

		local x_pos = Owner.Pos.X - 10
		for _ = 1, math.ceil(Owner.Height / 16) do
			x_pos = x_pos - 7
			if SceneMan.SceneWrapsX and x_pos < 0 then
				x_pos = x_pos + SceneMan.SceneWidth
			end

			if 0 == SceneMan:GetTerrMatter(x_pos, ground) then
				return false
			end
		end
	else
		return false -- target is too close
	end

	PronePos = SceneMan:MovePointToGround(PronePos, Owner.Head.Radius + 3, 2)
	Dist = SceneMan:ShortestDistance(PronePos, AimPoint, false)

	-- check LOS from the prone position
	--if not SceneMan:CastFindMORay(PronePos, Dist, targetID, Hit, rte.grassID, false, 8) then
	if
		SceneMan:CastObstacleRay(PronePos, Dist, Vector(), Vector(), targetID, Owner.IgnoresWhichTeam, rte.grassID, 9)
		> -1
	then
		return false
	else
		-- check for obstacles more more carefully
		Dist:CapMagnitude(60)
		if
			SceneMan:CastObstacleRay(PronePos, Dist, Vector(), Vector(), 0, Owner.IgnoresWhichTeam, rte.grassID, 1) > -1
		then
			return false
		end
	end

	AI.proneState = AHuman.PRONE
	if Dist.X > 0 then
		AI.lateralMoveState = Actor.LAT_RIGHT
	else
		AI.lateralMoveState = Actor.LAT_LEFT
	end

	return true
end

-- get the projectile properties from the magazine
-- in the future each magazine should have its own AI-script that explais to the AI how to use the item properly
function TauBehaviors.GetProjectileData(Owner)
	local Weapon = ToHDFirearm(Owner.EquippedItem)
	local Round = Weapon.Magazine.NextRound
	local Projectile = Round.NextParticle
	local PrjDat = { MagazineName = Weapon.Magazine.PresetName }

	if Round.IsEmpty then -- set default values if there is no particle
		PrjDat.g = 0
		PrjDat.vel = 100
		PrjDat.rng = math.huge
	else
		if Weapon:HasObjectInGroup("Weapons - Explosive") then
			PrjDat.exp = true -- this weapon have a blast radius
		end

		PrjDat.vel = Round.FireVel -- muzzle velocity
		if Projectile.ClassName == "MOPixel" then
			-- half of the theoretical upper limit for the total amount of material strength this weapon can destroy in 250ms
			PrjDat.pen = 0.5
				* Projectile.Mass
				* Projectile.Sharpness
				* PrjDat.vel
				* math.max((Weapon.RateOfFire / 240), 1)
		elseif Projectile.ClassName == "AEmitter" then
			PrjDat.vel = math.max(PrjDat.vel, Projectile.Sharpness) -- AEmitters can have FireVel overriden by Sharpness
		end

		PrjDat.g = SceneMan.GlobalAcc.Y * 0.67 * math.max(Projectile.GlobalAccScalar, 0) -- underestimate gravity
		PrjDat.vsq = PrjDat.vel ^ 2 -- muzzle velocity squared
		PrjDat.vqu = PrjDat.vsq ^ 2 -- muzzle velocity quadrat
		PrjDat.drg = 1 - Projectile.AirResistance * TimerMan.DeltaTimeSecs -- AirResistance is stored as the ini-value times 60
		PrjDat.thr = math.min(Projectile.AirThreshold, PrjDat.vel)

		-- estimate theoretical max range with ...
		local lifeTime = Projectile.Lifetime
		if lifeTime < 1 then -- infinite life time
			PrjDat.rng = math.huge
		elseif PrjDat.drg < 1 then -- AirResistance
			PrjDat.rng = 0
			local threshold = PrjDat.thr * GetPPM() * TimerMan.DeltaTimeSecs -- AirThreshold in pixels/frame
			local vel = PrjDat.vel * GetPPM() * TimerMan.DeltaTimeSecs -- muzzle velocity in pixels/frame
			for _ = 0, math.ceil(lifeTime / TimerMan.DeltaTimeMS) do
				PrjDat.rng = PrjDat.rng + vel
				if vel > threshold then
					vel = vel * PrjDat.drg
				end
			end
		else -- no AirResistance
			PrjDat.rng = PrjDat.vel * GetPPM() * TimerMan.DeltaTimeSecs * (lifeTime / TimerMan.DeltaTimeMS)
		end
	end

	return PrjDat
end

-- open fire on the selected target
function TauBehaviors.ShootTarget(AI, Owner)
	if not MovableMan:IsActor(AI.Target) then
		return true
	end

	AI.canHitTarget = false
	AI.TargetLostTimer:SetSimTimeLimitMS(700)

	local LOSTimer = Timer()
	LOSTimer:SetSimTimeLimitMS(170)

	local ShootTimer = Timer()
	local shootDelay = RangeRand(450, 670)
	local AimPoint = AI.Target.Pos + AI.TargetOffset
	if not AI.flying and AI.Target.Vel.Largest < 4 and TauBehaviors.GoProne(AI, Owner, AimPoint, AI.Target.ID) then
		shootDelay = shootDelay + 250
	end

	local PrjDat, OldWaypoint
	local openFire = 0
	local checkAim = true
	local canSwitchWeapon = Owner.InventorySize
	local TargetAvgVel = Vector(AI.Target.Vel.X, AI.Target.Vel.Y)
	local Dist = SceneMan:ShortestDistance(Owner.Pos, AimPoint, false)

	-- make sure we are facing the right direction
	if Owner.HFlipped then
		if Dist.X > 0 then
			Owner.HFlipped = false
		end
	elseif Dist.X < 0 then
		Owner.HFlipped = true
	end

	coroutine.yield() -- wait until next frame

	local ErrorOffset = Vector(RangeRand(40, 80), 0):RadRotate(RangeRand(1, 7))
	if Dist.Largest < 250 then
		ErrorOffset = ErrorOffset * 0.5
	end

	local aimTarget = SceneMan:ShortestDistance(Owner.Pos, AimPoint + ErrorOffset, false).AbsRadAngle

	while true do
		if not AI.Target or AI.Target:IsDead() then
			AI.Target = nil

			-- the target is gone, try to find another right away
			local ClosestEnemy
			local best = math.huge
			for Act in MovableMan.Actors do
				if Act.Team ~= Owner.Team then
					local distance = SceneMan:ShortestDistance(Act.Pos, AimPoint, false).Largest
					if distance < best then
						best = distance
						ClosestEnemy = Act
					end
				end
			end

			if best < 200 then
				-- check if the target is inside our "screen"
				local ViewDist = SceneMan:ShortestDistance(Owner.ViewPoint, ClosestEnemy.Pos, false)
				if
					(math.abs(ViewDist.X) - ClosestEnemy.Radius < FrameMan.PlayerScreenWidth * 0.5)
					and (math.abs(ViewDist.Y) - ClosestEnemy.Radius < FrameMan.PlayerScreenHeight * 0.5)
				then
					if
						not AI.isPlayerOwned
						or not SceneMan:IsUnseen(ClosestEnemy.Pos.X, ClosestEnemy.Pos.Y, Owner.Team)
					then -- AI-teams ignore the fog
						if SceneMan:CastStrengthSumRay(Owner.EyePos, ClosestEnemy.Pos, 6, rte.grassID) < 120 then
							AI.Target = ClosestEnemy
							AI.TargetOffset = Vector()
						end
					end
				end
			end

			-- no new target found
			if not AI.Target then
				if OldWaypoint then
					Owner:ClearAIWaypoints()
					Owner:AddAISceneWaypoint(OldWaypoint)
					AI:CreateGoToBehavior(Owner)
				end

				break
			end
		end

		if Owner.FirearmIsReady then
			-- it is now safe to get the ammo stats since FirearmIsReady
			local Weapon = ToHDFirearm(Owner.EquippedItem)
			if not PrjDat or PrjDat.MagazineName ~= Weapon.Magazine.PresetName then
				PrjDat = TauBehaviors.GetProjectileData(Owner)

				-- uncomment these to get the range of the weapon
				--ConsoleMan:PrintString(Weapon.PresetName .. " range = " .. PrjDat.rng .. " px")
				--ConsoleMan:PrintString(AI.Target.PresetName .. " range = " .. SceneMan:ShortestDistance(Owner.Pos, AI.Target.Pos, false).Magnitude .. " px")

				-- Aim longer with lo-cap weapons
				if Weapon.Magazine.Capacity > -1 and Weapon.Magazine.Capacity < 7 and Dist.Largest > 150 then
					ErrorOffset = ErrorOffset * 0.6
					shootDelay = shootDelay + 500
				end
			else
				TargetAvgVel = TargetAvgVel * 0.6 + AI.Target.Vel * 0.4 -- smooth the target's velocity
				AimPoint = AI.Target.Pos + AI.TargetOffset + ErrorOffset

				Dist = SceneMan:ShortestDistance(Weapon.Pos, AimPoint, false)
				local range = Dist.Magnitude

				-- move the aimpoint towards the center of the target at close ranges
				if range < 100 then
					AI.TargetOffset = AI.TargetOffset * 0.65
				end

				if checkAim then
					checkAim = false -- only check every second frame

					if range < 100 then -- within 5m
						-- it is not safe to fire an explosive projectile at this distance
						aimTarget = Dist.AbsRadAngle
						AI.canHitTarget = true
						if PrjDat.exp and Owner.InventorySize > 0 then -- we have more things in the inventory
							if Owner:EquipDiggingTool(false) then
								AI:CreateHtHBehavior(Owner)
								break
							elseif
								canSwitchWeapon > 0 and Owner:HasObjectInGroup("Weapons - Primary")
								or Owner:HasObjectInGroup("Weapons - Secondary")
							then
								canSwitchWeapon = canSwitchWeapon - 1
								AI.Ctrl:SetState(Controller.WEAPON_CHANGE_NEXT, true)
								PrjDat = nil -- get the ammo info from the new weapon the next update
								AI.canHitTarget = false
							end
						end
					elseif range < PrjDat.rng then
						-- lead the target if target speed and projectile TTT is above the threshold
						local timeToTarget = range / PrjDat.vel
						if timeToTarget * AI.Target.Vel.Magnitude > 2 then
							timeToTarget = timeToTarget * RangeRand(1.6, 2.2) -- ~double this value since we only do this every second update
							Dist = SceneMan:ShortestDistance(
								Weapon.Pos,
								AimPoint + (Owner.Vel * 0.5 + AI.Target.Vel) * timeToTarget,
								false
							)
						end

						aimTarget = TauBehaviors.GetAngleToHit(PrjDat, Dist)
						if aimTarget then
							AI.canHitTarget = true
						else
							AI.canHitTarget = false

							-- the target is too far away; switch weapon, move closer or run away
							if
								canSwitchWeapon > 0
								and (
									Owner:HasObjectInGroup("Weapons - Primary")
									or Owner:HasObjectInGroup("Weapons - Secondary")
								)
							then
								canSwitchWeapon = canSwitchWeapon - 1
								AI.Ctrl:SetState(Controller.WEAPON_CHANGE_NEXT, true)
								PrjDat = nil -- get the ammo info from the new weapon the next update
							elseif not AI.isPlayerOwned or Owner.AIMode ~= Actor.AIMODE_SENTRY then
								if
									not Owner.MOMoveTarget
									or not MovableMan:ValidMO(Owner.MOMoveTarget)
									or Owner.MOMoveTarget.RootID ~= AI.Target.RootID
								then -- move towards the target
									OldWaypoint = Owner:GetLastAIWaypoint()
									if (OldWaypoint - Owner.Pos).Largest < 1 then
										OldWaypoint = Vector(Owner.Pos.X, Owner.Pos.Y) -- move back here later
									end

									Owner:ClearAIWaypoints()
									Owner:AddAIMOWaypoint(AI.Target)
									AI:CreateGoToBehavior(Owner)
									AI.proneState = AHuman.NOTPRONE
								end
							else
								-- TODO: run away or duck?
								break
							end
						end
					elseif not AI.isPlayerOwned or Owner.AIMode ~= Actor.AIMODE_SENTRY then -- target out of reach; move towards it
						-- check if we are already moving towards an actor
						if
							not Owner.MOMoveTarget
							or not MovableMan:ValidMO(Owner.MOMoveTarget)
							or Owner.MOMoveTarget.RootID ~= AI.Target.RootID
						then -- move towards the target
							OldWaypoint = Owner:GetLastAIWaypoint()
							if (OldWaypoint - Owner.Pos).Largest < 1 then
								OldWaypoint = Vector(Owner.Pos.X, Owner.Pos.Y) -- move back here later
							end

							Owner:ClearAIWaypoints()
							Owner:AddAIMOWaypoint(AI.Target)
							AI:CreateGoToBehavior(Owner)
							AI.proneState = AHuman.NOTPRONE
							AI.canHitTarget = false
						end
					end
				else
					checkAim = true

					-- periodically check that we have LOS to the target
					if LOSTimer:IsPastSimTimeLimit() then
						LOSTimer:Reset()
						local TargetPoint = AI.Target.Pos + AI.TargetOffset

						if
							(range < 30 + Weapon.SharpLength + FrameMan.PlayerScreenWidth * 0.5)
							and (
								not AI.isPlayerOwned or not SceneMan:IsUnseen(TargetPoint.X, TargetPoint.Y, Owner.Team)
							)
						then
							if PrjDat.pen then
								if
									SceneMan:CastStrengthSumRay(Weapon.Pos, TargetPoint, 6, rte.grassID) * 5
									< PrjDat.pen
								then
									AI.TargetLostTimer:Reset() -- we can shoot at the target
								end
							else
								if SceneMan:CastStrengthSumRay(Weapon.Pos, TargetPoint, 6, rte.grassID) < 120 then
									AI.TargetLostTimer:Reset() -- we can shoot at the target
								end
							end
						end
					end
				end

				if AI.canHitTarget then
					AI.lateralMoveState = Actor.LAT_STILL
					if not AI.flying then
						AI.deviceState = AHuman.AIMING
					end
				end

				local aim = Owner:GetAimAngle(true)
				if AI.flying then
					aimTarget = (aimTarget or aim) + RangeRand(-0.05, 0.05)
				else
					aimTarget = (aimTarget or aim) + math.min(math.max(RangeRand(-15, 15) / (range + 50), -0.1), 0.1)
				end

				local angDiff = aim - aimTarget
				if angDiff > math.pi then
					angDiff = angDiff - math.pi * 2
				elseif angDiff < -math.pi then
					angDiff = angDiff + math.pi * 2
				end

				if PrjDat and ShootTimer:IsPastRealMS(shootDelay) then
					ErrorOffset = ErrorOffset * 0.8 -- reduce the aim point error
					AI.Ctrl.AnalogAim = Vector(1, 0):RadRotate(aim - math.max(math.min(angDiff * 0.1, 0.25), -0.25))

					if AI.canHitTarget and angDiff < 0.7 then
						if Weapon.FullAuto then -- open fire if our aim overlap the target
							if math.abs(angDiff) < math.tanh((2 * AI.Target.Diameter) / (range + 0.1)) then
								openFire = 5 -- don't stop shooting just because we lose the target for a few frames
							else
								openFire = openFire - 1
							end
						elseif not AI.fire then -- open fire if our aim overlap the target
							if math.abs(angDiff) < math.tanh((1.5 * AI.Target.Diameter) / (range + 0.1)) then
								openFire = 1
							else
								openFire = 0
							end
						else
							openFire = openFire - 1 -- release the trigger if semi auto
						end

						-- check for obstacles if the ammo have a blast radius
						if openFire > 0 and PrjDat.exp then
							if
								SceneMan:CastObstacleRay(
									Weapon.MuzzlePos,
									Weapon:RotateOffset(Vector(40, 0)),
									Vector(),
									Vector(),
									Owner.ID,
									Owner.IgnoresWhichTeam,
									rte.grassID,
									2
								) > -1
							then
								openFire = 0
							end
						end
					else
						openFire = openFire - 1
					end
				else
					ErrorOffset = ErrorOffset * 0.82 -- reduce the aim point error
					AI.Ctrl.AnalogAim = Vector(1, 0):RadRotate(
						aim - math.max(math.min(angDiff * 0.065, 0.07), -0.07) + RangeRand(-0.04, 0.04)
					)
					openFire = 0
				end

				if openFire > 0 then
					AI.fire = true
				else
					AI.fire = false
				end
			end
		else
			if Owner.EquippedItem and ToHeldDevice(Owner.EquippedItem):IsReloading() then
				ShootTimer:Reset()
				AI.Ctrl.AnalogAim = SceneMan:ShortestDistance(Owner.Pos, AI.Target.Pos, false)
			elseif Owner:EquipFirearm(true) then
				shootDelay = RangeRand(320, 410)
				AI.deviceState = AHuman.POINTING
				AI.fire = false

				if Owner.FirearmIsEmpty then
					Owner:ReloadFirearms()
					-- TODO: check if ducking is appropriate while reloading (when we can make the actor stand up reliably)
				end
			else
				AI:CreateGetWeaponBehavior(Owner)
				break -- no firearm avaliable
			end
		end

		-- make sure we are facing the right direction
		if Owner.HFlipped then
			if Dist.X > 0 then
				Owner.HFlipped = false
			end
		elseif Dist.X < 0 then
			Owner.HFlipped = true
		end

		coroutine.yield() -- wait until next frame
	end

	return true
end

-- throw a grenade at the selected target
function TauBehaviors.ThrowTarget(AI, Owner)
	local ThrowTimer = Timer()
	local aimTime = RangeRand(1000, 1500)
	local scan = 0
	local miss = 0 -- stop scanning after a few missed atempts
	local AimPoint, Dist, MO, ID, rootID, aim, LOS

	AI.TargetLostTimer:SetSimTimeLimitMS(1500)

	while true do
		if not MovableMan:IsActor(AI.Target) then
			break
		end

		if scan < 1 then
			if AI.Target.Door then
				AimPoint = AI.Target.Door.Pos
			else
				AimPoint = AI.Target.Pos -- look for the center
				if AI.Target.EyePos then
					AimPoint = (AimPoint + AI.Target.EyePos) / 2
				end
			end

			ID = rte.NoMOID
			if Owner:IsWithinRange(Vector(AimPoint.X, AimPoint.Y)) then -- TODO: use grenade properies to decide this
				Dist = SceneMan:ShortestDistance(Owner.EyePos, AimPoint, false)
				ID = SceneMan:CastMORay(Owner.EyePos, Dist, Owner.ID, Owner.IgnoresWhichTeam, rte.grassID, false, 3)
				if ID < 1 or ID > 254 then -- not found, look for any head or legs
					AimPoint = AI.Target.EyePos -- the head
					if AimPoint then
						coroutine.yield() -- wait until next frame
						if not MovableMan:IsActor(AI.Target) then -- must verify that the target exist after a yield
							break
						end

						Dist = SceneMan:ShortestDistance(Owner.EyePos, AimPoint, false)
						ID = SceneMan:CastMORay(
							Owner.EyePos,
							Dist,
							Owner.ID,
							Owner.IgnoresWhichTeam,
							rte.grassID,
							false,
							3
						)
					end

					if ID < 1 or ID > 254 then
						local Legs = AI.Target.FGLeg or AI.Target.BGLeg -- the legs
						if Legs then
							coroutine.yield() -- wait until next frame
							if not MovableMan:IsActor(AI.Target) then -- must verify that the target exist after a yield
								break
							end

							AimPoint = Legs.Pos
							Dist = SceneMan:ShortestDistance(Owner.EyePos, AimPoint, false)
							ID = SceneMan:CastMORay(
								Owner.EyePos,
								Dist,
								Owner.ID,
								Owner.IgnoresWhichTeam,
								rte.grassID,
								false,
								3
							)
						end
					end
				end
			else
				break -- out of range
			end

			if ID > 0 and ID < rte.NoMOID then -- MO found
				scan = 6 -- skip the LOS check the next n frames
				miss = 0
				LOS = true -- we have line of sight to the target

				-- check what target we will hit
				rootID = MovableMan:GetRootMOID(ID)
				if rootID ~= AI.Target.ID then
					MO = MovableMan:GetMOFromID(rootID)
					if MovableMan:IsActor(MO) then
						if MO.Team ~= Owner.Team then
							if MO.ClassName == "AHuman" then
								AI.Target = ToAHuman(MO)
							elseif MO.ClassName == "ACrab" then
								AI.Target = ToACrab(MO)
							elseif MO.ClassName == "ACRocket" then
								AI.Target = ToACRocket(MO)
							elseif MO.ClassName == "ACDropShip" then
								AI.Target = ToACDropShip(MO)
							elseif MO.ClassName == "ADoor" then
								AI.Target = ToADoor(MO)
							elseif MO.ClassName == "Actor" then
								AI.Target = ToActor(MO)
							else
								break
							end
						else
							break -- don't shoot friendlies
						end
					end
				end
			else
				miss = miss + 1
				if miss > 4 then -- stop looking if we cannot find anything after n atempts
					break
				else
					scan = 3 -- check LOS a little bit more often if no MO was found
				end
			end

			if LOS then -- don't sharp aim until LOS has been confirmed
				if Owner.ThrowableIsReady then
					aim = TauBehaviors.GetGrenadeAngle(
						AimPoint,
						AI.Target.Vel / RangeRand(0.5, 1.75),
						ToHeldDevice(Owner.EquippedItem).MuzzlePos,
						18
					)
					if aim then
						AI.Ctrl.AnalogAim = Vector(1, 0):RadRotate(aim + RangeRand(-0.1, 0.1))
					else
						break -- target out of range
					end

					if not ThrowTimer:IsPastSimMS(aimTime) then
						AI.fire = true
					else
						ThrowTimer:Reset()
						AI.fire = false
						aimTime = RangeRand(1000, 1500)
					end
				else
					break -- no grenades left
				end
			end
		else
			scan = scan - 1
		end

		coroutine.yield() -- wait until next frame
	end

	return true
end

-- attack the target in hand-to-hand
function TauBehaviors.AttackTarget(AI, Owner)
	if not AI.Target or not MovableMan:IsActor(AI.Target) then
		return true
	end

	AI.TargetLostTimer:SetSimTimeLimitMS(5000)

	-- move towards the target
	local OldWaypoint
	if
		not Owner.MOMoveTarget
		or not MovableMan:ValidMO(Owner.MOMoveTarget)
		or Owner.MOMoveTarget.RootID ~= AI.Target.RootID
	then
		OldWaypoint = Owner:GetLastAIWaypoint()
		if (OldWaypoint - Owner.Pos).Largest < 1 then
			OldWaypoint = nil
		end

		Owner:ClearAIWaypoints()
		Owner:AddAIMOWaypoint(AI.Target)
		AI:CreateGoToBehavior(Owner)
	end

	local HD
	while true do
		coroutine.yield() -- wait until next frame

		if not AI.Target or not MovableMan:IsActor(AI.Target) then
			Owner:ClearAIWaypoints()
			if OldWaypoint then -- move towards the old wpt
				Owner:AddAISceneWaypoint(OldWaypoint)
				AI:CreateGoToBehavior(Owner)
			end

			break
		end

		if Owner.EquippedItem then
			HD = ToHeldDevice(Owner.EquippedItem)
			if HD:IsTool() then -- attack with digger
				local Dist = SceneMan:ShortestDistance(HD.MuzzlePos, AI.Target.Pos, false)
				if Dist.Magnitude < 40 then
					AI.Ctrl.AnalogAim = SceneMan:ShortestDistance(Owner.EyePos, AI.Target.Pos, false).Normalized
					AI.fire = true
				else
					AI.fire = false
				end
			else
				break
			end
			-- else TODO: periodically look for weapons?
		end
	end

	return true
end

-- move around another actor
function TauBehaviors.MoveAroundActor(AI, Owner)
	if not MovableMan:IsActor(AI.BlockingActor) then
		AI.teamBlockState = Actor.NOTBLOCKED
		AI.BlockingActor = nil
		return true
	end

	local BurstTimer = Timer()
	local refuel = false
	local Dist

	BurstTimer:SetSimTimeLimitMS(200) -- a burst last until the BurstTimer expire
	AI.jump = true

	-- look above the blocking actor
	Dist = SceneMan:ShortestDistance(Owner.Pos, AI.BlockingActor.Pos, false)
	if Dist.X > 0 then
		AI.Ctrl.AnalogAim = Vector(1, 0):RadRotate(1.20)
	else
		AI.Ctrl.AnalogAim = Vector(1, 0):RadRotate(1.94)
	end

	while true do
		if BurstTimer:IsPastSimTimeLimit() then -- trigger jetpack bursts
			BurstTimer:Reset()
			AI.jump = false

			Dist = SceneMan:ShortestDistance(Owner.Pos, AI.BlockingActor.Pos, false)
			if Dist.Y + Owner.Vel.Y * 3 > (Owner.Diameter + AI.BlockingActor.Diameter) * 0.67 then
				Owner:SetAimAngle(-0.5)

				if math.abs(Dist.X) > math.max(Owner.Diameter, AI.BlockingActor.Diameter) / 2 then
					return true
				end
			end
		else
			AI.jump = true
			if Owner.Vel.Y < -9 then
				AI.jump = false
			end
		end

		if refuel then
			AI.jump = false
			if Owner.JetTimeLeft > Owner.JetTimeTotal * 0.9 then
				refuel = false
			end
		elseif Owner.JetTimeLeft < Owner.JetTimeTotal * 0.1 then
			refuel = true
		end

		coroutine.yield() -- wait until next frame
		if not MovableMan:IsActor(AI.BlockingActor) then
			AI.teamBlockState = Actor.NOTBLOCKED
			AI.BlockingActor = nil
			return true
		end
	end

	return true
end

function TauBehaviors.GetAngleToHit(PrjDat, Dist)
	if PrjDat.g == 0 then -- this projectile is not affected by gravity
		return Dist.AbsRadAngle
	else -- compensate for gravity
		local rootSq, muzVelSq
		local D = Dist / GetPPM() -- convert from pixels to meters
		if PrjDat.drg < 1 then -- compensate for air resistance
			local rng = D.Magnitude
			local timeToTarget = math.floor(
				(rng / math.max(PrjDat.vel * PrjDat.drg ^ math.floor(rng / (PrjDat.vel + 1) + 0.5), PrjDat.thr))
					/ TimerMan.DeltaTimeSecs
			) -- estimate time of flight in frames

			if timeToTarget > 1 then
				local muzVel = 0.9 * math.max(PrjDat.vel * PrjDat.drg ^ timeToTarget, PrjDat.thr) + 0.1 * PrjDat.vel -- compensate for velocity reduction during flight
				muzVelSq = muzVel * muzVel
				rootSq = muzVelSq * muzVelSq - PrjDat.g * (PrjDat.g * D.X * D.X + 2 * -D.Y * muzVelSq)
			else
				muzVelSq = PrjDat.vsq
				rootSq = PrjDat.vqu - PrjDat.g * (PrjDat.g * D.X * D.X + 2 * -D.Y * muzVelSq)
			end
		else
			muzVelSq = PrjDat.vsq
			rootSq = PrjDat.vqu - PrjDat.g * (PrjDat.g * D.X * D.X + 2 * -D.Y * muzVelSq)
		end

		if rootSq >= 0 then -- no solution exists if rootSq is below zero
			local ang1 = math.atan2(muzVelSq - math.sqrt(rootSq), PrjDat.g * D.X)
			local ang2 = math.atan2(muzVelSq + math.sqrt(rootSq), PrjDat.g * D.X)
			if ang1 + ang2 > math.pi then -- both angles in the second or third quadrant
				if ang1 > math.pi or ang2 > math.pi then -- one or more angle in the third quadrant
					return math.min(ang1, ang2)
				else
					return math.max(ang1, ang2)
				end
			else -- both angles in the firs quadrant
				return math.min(ang1, ang2)
			end
		end
	end
end

-- open fire on the area around the selected target
function TauBehaviors.ShootArea(AI, Owner)
	if not MovableMan:IsActor(AI.UnseenTarget) or not Owner.FirearmIsReady then
		return true
	end

	-- see if we can shoot from the prone position
	local ShootTimer = Timer()
	local aimTime = RangeRand(100, 300)
	if
		not AI.flying
		and AI.UnseenTarget.Vel.Largest < 12
		and TauBehaviors.GoProne(AI, Owner, AI.UnseenTarget.Pos, AI.UnseenTarget.ID)
	then
		aimTime = aimTime + 500
	end

	local StartPos = Vector(AI.UnseenTarget.Pos.X, AI.UnseenTarget.Pos.Y)

	-- aim at the target in case we can see it when sharp aiming
	Owner:SetAimAngle(SceneMan:ShortestDistance(Owner.EyePos, StartPos, false).AbsRadAngle)
	AI.deviceState = AHuman.AIMING

	-- aim for ~160ms
	for _ = 1, 10 do
		coroutine.yield() -- wait until next frame
	end

	if not Owner.FirearmIsReady then
		return true
	end

	local AimPoint
	for _ = 1, 5 do -- try up to five times to find a target area that is resonably close to the target
		AimPoint = StartPos + Vector(RangeRand(-100, 100), RangeRand(-100, 50))
		if AimPoint.X > SceneMan.SceneWidth then
			AimPoint.X = SceneMan.SceneWidth - AimPoint.X
		elseif AimPoint.X < 0 then
			AimPoint.X = AimPoint.X + SceneMan.SceneWidth
		end

		-- check if we can fire at the AimPoint
		local Trace = SceneMan:ShortestDistance(Owner.EyePos, AimPoint, false)
		local rayLenght = SceneMan:CastObstacleRay(
			Owner.EyePos,
			Trace,
			Vector(),
			Vector(),
			rte.NoMOID,
			Owner.IgnoresWhichTeam,
			rte.grassID,
			11
		)
		if Trace.Magnitude * 0.67 < rayLenght then
			break -- the AimPoint is close enough to the target, start shooting
		end

		coroutine.yield() -- wait until next frame
	end

	if not Owner.FirearmIsReady then
		return true
	end

	local aim
	local PrjDat = TauBehaviors.GetProjectileData(Owner)
	local Dist = SceneMan:ShortestDistance(Owner.EquippedItem.Pos, AimPoint, false)
	if Dist.Magnitude < PrjDat.rng then
		aim = TauBehaviors.GetAngleToHit(PrjDat, Dist)
	else
		return true -- target out of range
	end

	local CheckTargetTimer = Timer()
	local aimError = RangeRand(-0.15, 0.15)

	while aim do
		if Owner.FirearmIsReady then
			AI.deviceState = AHuman.AIMING
			AI.Ctrl.AnalogAim = Vector(1, 0):RadRotate(aim + aimError + RangeRand(-0.02, 0.02))

			if ShootTimer:IsPastSimMS(aimTime) then
				AI.fire = true
				aimError = aimError * 0.985
			else
				AI.fire = false
			end
		else
			AI.deviceState = AHuman.POINTING
			AI.fire = false

			ShootTimer:Reset()
			if Owner.FirearmIsEmpty then
				Owner:ReloadFirearms()
			end

			break -- stop this behavior when the mag is empty
		end

		coroutine.yield() -- wait until next frame

		if AI.UnseenTarget and CheckTargetTimer:IsPastSimMS(400) then
			if
				MovableMan:IsActor(AI.UnseenTarget)
				and (AI.UnseenTarget.ClassName == "AHuman" or AI.UnseenTarget.ClassName == "ACrab")
			then
				CheckTargetTimer:Reset()
				if AI.UnseenTarget:GetController():IsState(Controller.WEAPON_FIRE) then
					-- compare the enemy aim angle with the angle of the alarm vector
					local enemyAim = AI.UnseenTarget:GetAimAngle(true)
					if enemyAim > math.pi * 2 then -- make sure the angle is in the [0..2*pi] range
						enemyAim = enemyAim - math.pi * 2
					elseif enemyAim < 0 then
						enemyAim = enemyAim + math.pi * 2
					end

					local angDiff = SceneMan:ShortestDistance(AI.UnseenTarget.Pos, Owner.Pos, false).AbsRadAngle
						- enemyAim
					if angDiff > math.pi then -- the difference between two angles can never be larger than pi
						angDiff = angDiff - math.pi * 2
					elseif angDiff < -math.pi then
						angDiff = angDiff + math.pi * 2
					end

					if math.abs(angDiff) < 0.5 then
						-- this actor is shooting in our direction
						AimPoint = AI.UnseenTarget.Pos
							+ SceneMan:ShortestDistance(AI.UnseenTarget.Pos, AimPoint, false) / 2
							+ Vector(RangeRand(-30, 30), RangeRand(-30, 30))
						aimError = RangeRand(-0.13, 0.13)

						Dist = SceneMan:ShortestDistance(Owner.EquippedItem.Pos, AimPoint, false)
						if Dist.Magnitude < PrjDat.rng then
							aim = TauBehaviors.GetAngleToHit(PrjDat, Dist)
						end
					end
				end
			else
				AI.UnseenTarget = nil
			end
		end
	end

	return true
end

-- look at the alarm event
function TauBehaviors.FaceAlarm(AI, Owner)
	local TargetPoint = AI.AlarmPos or AI.OldTargetPos
	if TargetPoint then
		local AlarmDist = SceneMan:ShortestDistance(Owner.EyePos, TargetPoint, false)
		for _ = 1, math.ceil(400 / TimerMan.DeltaTimeMS) do
			AI.deviceState = AHuman.AIMING
			AI.lateralMoveState = Actor.LAT_STILL
			AI.Ctrl.AnalogAim = AlarmDist
			coroutine.yield() -- wait until next frame
		end
	end

	return true
end

-- stop the user fom inadvertently modifying the storage table
local Proxy = {}
local Mt = {
	__index = TauBehaviors,
	__newindex = function(Table, k, v)
		error("The TauBehaviors table is read-only.", 2)
	end,
}
setmetatable(Proxy, Mt)
TauBehaviors = Proxy
