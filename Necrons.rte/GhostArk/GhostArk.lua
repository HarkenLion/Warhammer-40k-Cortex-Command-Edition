require("AI/PID")

function Create(self)
	--working variables

	self.enableselect = true
	self.selectTimer = Timer()
	self.garbTimer = Timer()
	self.Turret = {}

	self.Turret = CreateACrab("Necron Ghost Ark Broadside Control")
	self.Turret.Team = self.Team
	MovableMan:AddActor(self.Turret)
	self.Turret.Offset = Vector(0, 25)

	self.StaticTimer = Timer()
	self.statictime = 250
	---------------- AI variables start ----------------
	self.StuckTimer = Timer()
	self.HatchTimer = Timer()

	self.AvoidTimer = Timer()
	self.AvoidTimer:SetSimTimeLimitMS(500)

	self.PlayerInterferedTimer = Timer()
	self.PlayerInterferedTimer:SetSimTimeLimitMS(500)

	if self.AIMode == Actor.AIMODE_DELIVER and self:IsInventoryEmpty() then
		self.AIMode = Actor.AIMODE_STAY -- Stop the craft from returning to orbit immediately
	end

	self.Controller = self:GetController()
	self.LastAIMode = Actor.AIMODE_NONE

	-- The drop ship tries to hover this many pixels above the ground
	if self.AIMode == Actor.AIMODE_BRAINHUNT then
		self.hoverAlt = self.Radius * 1.7
	elseif self.AIMode == Actor.AIMODE_GOTO then
		self.hoverAlt = self.Radius * 7
	else
		self.hoverAlt = self.Radius * 2
	end

	-- The controllers
	self.XposPID = RegulatorPID:New({ p = 0.05, i = 0.01, d = 2.5, filter_leak = 0.8, integral_max = 50 })
	self.YposPID = RegulatorPID:New({ p = 0.1, d = 2.5, filter_leak = 0.6 })

	---------------- AI variables end ----------------
end

function Update(self)
	if self.Health > 0 then
		-- Stabilize

		if self.RotAngle > 0.2 then
			self.AngularVel = self.AngularVel - 0.2
		elseif self.RotAngle < -0.2 then
			self.AngularVel = self.AngularVel + 0.2
		else
			self.AngularVel = self.AngularVel * 0.98
		end
	end

	if self:IsPlayerControlled() == true then
		if self.enableselect == true then
			self.enableselect = false
			self.selectTimer:Reset()
		end
	else
		self.enableselect = true
	end

	if not self.selectTimer:IsPastSimMS(1200) then
		if not self.selectTimer:IsPastSimMS(600) then
			self.selected = CreateMOPixel("Ghost Ark Diagram 2")
			self.selected.Pos = self.Pos
			self.selected.PinStrength = 1000
			MovableMan:AddParticle(self.selected)
		else
			self.selected = CreateMOPixel("Ghost Ark Diagram")
			self.selected.Pos = self.Pos
			self.selected.PinStrength = 1000
			MovableMan:AddParticle(self.selected)
		end
	end

	--update turret spatial properties
	for i = 0, 1 do
		if MovableMan:IsActor(self.Turret) == true then
			--basic turret position upkeep (so it doesn't fall at 999999m/s)
			self.Turret.Vel.X = 0
			self.Turret.Vel.Y = 0
			--update turret position
			self.Turret.RotAngle = self.RotAngle
			self.Turret.Pos = self.Pos + self:RotateOffset(self.Turret.Offset)
		end
	end

	if self.Health < 70 and self.StaticTimer:IsPastSimMS(self.statictime) then
		self.StaticTimer:Reset()
		local rand = math.random(-80, 85)
		local rand2 = math.random(-65, 65)

		local chain7 = CreateMOPixel("Gauss Lightning Static Particle")
		chain7.Pos.X = self.Pos.X + rand
		chain7.Pos.Y = self.Pos.Y + rand2
		chain7.Vel = self.Vel
		chain7.Team = self.Team
		chain7.IgnoresTeamHits = true
		MovableMan:AddParticle(chain7)

		local soundfx = CreateAEmitter("Lightning Impact")
		soundfx.Pos = chain7.Pos
		MovableMan:AddParticle(soundfx)

		self.statictime = math.abs(self.Health) * 5
	end

	--GARBAGE COLLECTION
	if self.garbTimer:IsPastSimMS(10000) then
		collectgarbage("collect")
		self.garbTimer:Reset()
	end
end

function Destroy(self)
	if MovableMan:IsActor(self.Turret) == true then
		if self.Health < 1 then
			self.Turret:GibThis()
		else
			self.Turret.ToDelete = true
		end
	end
end

function UpdateAI(self)
	if self.AIMode ~= self.LastAIMode then -- We have new orders
		self.LastAIMode = self.AIMode

		if self.AIMode == Actor.AIMODE_RETURN then
			self.DeliveryState = ACraft.LAUNCH
			self.Waypoint = Vector(self.Pos.X, -500) -- Go to orbit
		else -- Actor.AIMODE_STAY and Actor.AIMODE_DELIVER
			local FuturePos = self.Pos + self.Vel * 20

			-- Make sure FuturePos is inside the scene
			if FuturePos.X > SceneMan.SceneWidth then
				if SceneMan.SceneWrapsX then
					FuturePos.X = FuturePos.X - SceneMan.SceneWidth
				else
					FuturePos.X = SceneMan.SceneWidth - self.Radius
				end
			elseif FuturePos.X < 0 then
				if SceneMan.SceneWrapsX then
					FuturePos.X = FuturePos.X + SceneMan.SceneWidth
				else
					FuturePos.X = self.Radius
				end
			end

			-- Use self:GetLastAIWaypoint() as a LZ so the AI can give orders to dropships
			local Wpt = self:GetLastAIWaypoint()
			if (self.Pos - Wpt).Largest > 1 then
				self.Waypoint = Wpt
			else
				local WptL = SceneMan:MovePointToGround(self.Pos - Vector(self.Radius, 0), self.hoverAlt, 12)
				local WptC = SceneMan:MovePointToGround(self.Pos, self.hoverAlt, 12)
				local WptR = SceneMan:MovePointToGround(self.Pos + Vector(self.Radius, 0), self.hoverAlt, 12)
				self.Waypoint = Vector(self.Pos.X, math.min(WptL.Y, WptC.Y, WptR.Y))
			end

			self.DeliveryState = ACraft.FALL
		end
	end

	if self.PlayerInterferedTimer:IsPastSimTimeLimit() then
		self.StuckTimer:Reset()

		local FuturePos = self.Pos + self.Vel * 20

		-- Make sure FuturePos is inside the scene
		if FuturePos.X > SceneMan.SceneWidth then
			if SceneMan.SceneWrapsX then
				FuturePos.X = FuturePos.X - SceneMan.SceneWidth
			else
				FuturePos.X = SceneMan.SceneWidth - self.Radius
			end
		elseif FuturePos.X < 0 then
			if SceneMan.SceneWrapsX then
				FuturePos.X = FuturePos.X + SceneMan.SceneWidth
			else
				FuturePos.X = self.Radius
			end
		end

		local Dist = SceneMan:ShortestDistance(FuturePos, self.Waypoint, false)
		if math.abs(Dist.X) > 100 then
			if self.DeliveryState == ACraft.LAUNCH then
				self.Waypoint.X = FuturePos.X
				self.Waypoint.Y = -500
			else
				local WptL = SceneMan:MovePointToGround(self.Pos - Vector(self.Radius, 0), self.hoverAlt, 12)
				local WptC = SceneMan:MovePointToGround(self.Pos, self.hoverAlt, 12)
				local WptR = SceneMan:MovePointToGround(self.Pos + Vector(self.Radius, 0), self.hoverAlt, 12)
				self.Waypoint = Vector(self.Pos.X, math.min(WptL.Y, WptC.Y, WptR.Y))
			end
		end
	end

	self.PlayerInterferedTimer:Reset()

	-- Control right/left movement
	local Dist = SceneMan:ShortestDistance(self.Pos + self.Vel * 30, self.Waypoint, false)
	local change = self.XposPID:Update(Dist.X, 0)
	if change > 2 then
		self.Controller.AnalogMove = Vector(change / 30, 0)
	elseif change < -2 then
		self.Controller.AnalogMove = Vector(change / 30, 0)
	end

	-- Control up/down movement
	Dist = SceneMan:ShortestDistance(self.Pos + self.Vel * 5, self.Waypoint, false)
	change = self.YposPID:Update(Dist.Y, 0)
	if change > 2 then
		self.AltitudeMoveState = ACraft.DESCEND
	elseif change < -2 then
		self.AltitudeMoveState = ACraft.ASCEND
	end

	-- Delivery Sequence logic
	if self.DeliveryState == ACraft.FALL then
		-- Don't descend if we have nothing to deliver
		if self:IsInventoryEmpty() and self.AIMode ~= Actor.AIMODE_BRAINHUNT then
			if self.AIMode ~= Actor.AIMODE_STAY then
				self.DeliveryState = ACraft.LAUNCH
				self.HatchTimer:Reset()
				self.Waypoint.Y = -500 -- Go to orbit
			end
		else
			local dist = SceneMan:ShortestDistance(self.Pos, self.Waypoint, false).Magnitude
			if dist < self.Radius and math.abs(change) < 3 and math.abs(self.Vel.X) < 4 then -- If we passed the hover check, check if we can start unloading
				local WptL = SceneMan:MovePointToGround(
					self.Pos + Vector(-self.Radius, -self.Radius),
					self.hoverAlt,
					12
				)
				local WptC = SceneMan:MovePointToGround(self.Pos + Vector(0, -self.Radius), self.hoverAlt, 12)
				local WptR = SceneMan:MovePointToGround(self.Pos + Vector(self.Radius, -self.Radius), self.hoverAlt, 12)
				self.Waypoint = Vector(self.Pos.X, math.min(WptL.Y, WptC.Y, WptR.Y))

				dist = SceneMan:ShortestDistance(self.Pos, self.Waypoint, false).Magnitude
				if dist < self.Diameter then
					-- We are close enough to our waypoint
					if self.AIMode == Actor.AIMODE_STAY then
						self.DeliveryState = ACraft.STANDBY
					else
						self.DeliveryState = ACraft.UNLOAD
						self.HatchTimer:Reset()
					end
				end
			else
				-- Check for something in the way of our descent, and hover to the side to avoid it
				if self.AvoidTimer:IsPastSimTimeLimit() then
					self.AvoidTimer:Reset()

					self.search = not self.search -- Search every second update
					if self.search then
						local obstID = self:DetectObstacle(self.Diameter + self.Vel.Magnitude * 70)
						if obstID > 0 and obstID < 255 then
							local MO = MovableMan:GetMOFromID(MovableMan:GetRootMOID(obstID))
							if MO.ClassName == "ACDropShip" or MO.ClassName == "ACRocket" then
								self.AvoidMoveState = ACraft.HOVER
								self.Waypoint.X = self.Waypoint.X + self.Diameter * 2

								-- Make sure the LZ is inside the scene
								if self.Waypoint.X > SceneMan.SceneWidth then
									if SceneMan.SceneWrapsX then
										self.Waypoint.X = self.Waypoint.X - SceneMan.SceneWidth
									else
										self.Waypoint.X = SceneMan.SceneWidth - self.Radius
									end
								end
							end
						else
							self.AvoidMoveState = nil
						end
					else -- Avoid terrain
						local Free = Vector()
						local Start = self.Pos + Vector(self.Radius, 0)
						local Trace = self.Vel * (self.Radius / 2) + Vector(0, 50)
						if PosRand() < 0.5 then
							Start.X = Start.X - self.Diameter
						end

						if SceneMan:CastStrengthRay(Start, Trace, 0, Free, 4, 0, true) then
							self.Waypoint.X = self.Pos.X
							self.Waypoint.Y = Free.Y - self.hoverAlt
						end
					end
				end

				if self.AvoidMoveState then
					self.AltitudeMoveState = self.AvoidMoveState
				end
			end
		end
	elseif self.DeliveryState == ACraft.UNLOAD then
		if self.HatchTimer:IsPastSimMS(500) then -- Start unloading if there's something to unload
			self.HatchTimer:Reset()
			self:OpenHatch()

			if self.AIMode == Actor.AIMODE_BRAINHUNT and self:HasObjectInGroup("Brains") then
				self.AIMode = Actor.AIMODE_RETURN
			else
				self.DeliveryState = ACraft.FALL
			end
		end
	elseif self.DeliveryState == ACraft.LAUNCH then
		if self.HatchTimer:IsPastSimMS(1000) then
			self.HatchTimer:Reset()
			self:CloseHatch()
		end

		-- Check for something in the way of our ascent, and hover to the side to avoid it
		if self.AvoidTimer:IsPastSimTimeLimit() then
			self.AvoidTimer:Reset()

			local obstID = self:DetectObstacle(self.Diameter + self.Vel.Magnitude * 70)
			if obstID > 0 and obstID < 255 then
				local MO = MovableMan:GetMOFromID(MovableMan:GetRootMOID(obstID))
				if MO.ClassName == "ACDropShip" or MO.ClassName == "ACRocket" then
					self.AvoidMoveState = ACraft.HOVER
					self.Waypoint.X = self.Waypoint.X - self.Diameter * 2

					-- Make sure the LZ is inside the scene
					if self.Waypoint.X < 0 then
						if SceneMan.SceneWrapsX then
							self.Waypoint.X = self.Waypoint.X + SceneMan.SceneWidth
						else
							self.Waypoint.X = self.Radius
						end
					end
				end
			else
				self.AvoidMoveState = nil
			end
		end

		if self.AvoidMoveState then
			self.AltitudeMoveState = self.AvoidMoveState
		end
	end

	-- Input translation
	if self.AltitudeMoveState == ACraft.ASCEND then
		self.Controller:SetState(Controller.MOVE_UP, true)
	elseif self.AltitudeMoveState == ACraft.DESCEND then
		self.Controller:SetState(Controller.MOVE_DOWN, true)
	else
		self.Controller:SetState(Controller.MOVE_UP, false)
		self.Controller:SetState(Controller.MOVE_DOWN, false)
	end

	-- If we are hopelessly stuck, self destruct
	if self.Vel.Largest > 3 or self.AIMode == Actor.AIMODE_STAY then
		self.StuckTimer:Reset()
	elseif self.AIMode == Actor.AIMODE_SCUTTLE or self.StuckTimer:IsPastSimMS(40000) then
		self:GibThis()
	end
end
