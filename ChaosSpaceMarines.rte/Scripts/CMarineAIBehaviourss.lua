ChaosBeh = {}

-- function ChaosBeh.createSoundEffect(self, effectName, variations)
-- if effectName ~= nil then
-- self.soundEffect = AudioMan:PlaySound(effectName .. math.random(1, variations) .. ".ogg", self.Pos, -1, 0, 130, 1, 400, false);
-- end
-- end

-- no longer needed as of pre3!

function ChaosBeh.createVoiceSoundEffect(self, soundContainer, priority, emotion, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1
	else
		usingPriority = priority
	end
	if self.Head and soundContainer ~= nil then
		if self.voiceSound then
			if self.voiceSound:IsBeingPlayed() then
				if self.lastPriority <= usingPriority then
					if emotion then
						ChaosBeh.createEmotion(self, emotion, priority, 0, canOverridePriority)
					end
					self.voiceSound:Stop()
					self.voiceSound = soundContainer
					soundContainer:Play(self.Pos)
					self.lastPriority = priority
					return true
				end
			else
				if emotion then
					ChaosBeh.createEmotion(self, emotion, priority, 0, canOverridePriority)
				end
				self.voiceSound = soundContainer
				soundContainer:Play(self.Pos)
				self.lastPriority = priority
				return true
			end
		else
			if emotion then
				ChaosBeh.createEmotion(self, emotion, priority, 0, canOverridePriority)
			end
			self.voiceSound = soundContainer
			soundContainer:Play(self.Pos)
			self.lastPriority = priority
			return true
		end
	end
end

function ChaosBeh.createEmotion(self, emotion, priority, duration, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1
	else
		usingPriority = priority
	end
	if emotion then
		self.emotionApplied = false -- applied later in handleheadframes
		self.Emotion = emotion
		if duration then
			self.emotionTimer:Reset()
			self.emotionDuration = duration
		else
			self.emotionDuration = 0 -- will follow voiceSound length
		end
		self.lastEmotionPriority = priority
		self.deathCloseTimer:Reset()
	end
end

function ChaosBeh.createVoiceSoundEffect(self, soundContainer, priority, emotion, canOverridePriority)
	if canOverridePriority == nil then
		canOverridePriority = false
	end
	local usingPriority
	if canOverridePriority == false then
		usingPriority = priority - 1
	else
		usingPriority = priority
	end
	if self.Head and soundContainer ~= nil then
		if self.voiceSound then
			if self.voiceSound:IsBeingPlayed() then
				if self.lastPriority <= usingPriority then
					if emotion then
						ChaosBeh.createEmotion(self, emotion, priority, 0, canOverridePriority)
					end
					self.voiceSound:Stop()
					self.voiceSound = soundContainer
					soundContainer:Play(self.Pos)
					self.lastPriority = priority
					return true
				end
			else
				if emotion then
					ChaosBeh.createEmotion(self, emotion, priority, 0, canOverridePriority)
				end
				self.voiceSound = soundContainer
				soundContainer:Play(self.Pos)
				self.lastPriority = priority
				return true
			end
		else
			if emotion then
				ChaosBeh.createEmotion(self, emotion, priority, 0, canOverridePriority)
			end
			self.voiceSound = soundContainer
			soundContainer:Play(self.Pos)
			self.lastPriority = priority
			return true
		end
	end
end

function ChaosBeh.handleMovement(self)
	local crouching = self.controller:IsState(Controller.BODY_CROUCH)
	local moving = self.controller:IsState(Controller.MOVE_LEFT) or self.controller:IsState(Controller.MOVE_RIGHT)

	--NOTE: you could also put in things like your falling scream here easily with very little overhead

	-- Leg Collision Detection system
	--local i = 0
	for i = 1, 2 do
		--local foot = self.feet[i]
		local foot = nil
		--local leg = self.legs[i]
		if i == 1 then
			foot = self.FGFoot
		else
			foot = self.BGFoot
		end
		--if foot ~= nil and leg ~= nil and leg.ID ~= rte.NoMOID then
		if foot ~= nil then
			local footPos = foot.Pos
			local mat = nil
			local pixelPos = footPos + Vector(0, 4)
			self.footPixel = SceneMan:GetTerrMatter(pixelPos.X, pixelPos.Y)
			--PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13)
			if self.footPixel ~= 0 then
				mat = SceneMan:GetMaterialFromID(self.footPixel)
				--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 162);
				--else
				--	PrimitiveMan:DrawLinePrimitive(pixelPos, pixelPos, 13);
			end

			local movement = (
					self.controller:IsState(Controller.MOVE_LEFT) == true
					or self.controller:IsState(Controller.MOVE_RIGHT) == true
					or self.Vel.Magnitude > 3
				)
			if mat ~= nil then
				--PrimitiveMan:DrawTextPrimitive(footPos, mat.PresetName, true, 0);
				if self.feetContact[i] == false then
					self.feetContact[i] = true
					if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then
						self.feetTimers[i]:Reset()
					end
				end
			else
				if self.feetContact[i] == true then
					self.feetContact[i] = false
					if self.feetTimers[i]:IsPastSimMS(self.footstepTime) and movement then
						self.feetTimers[i]:Reset()
					end
				end
			end
		end
	end

	if crouching then
		if not self.wasCrouching and self.moveSoundTimer:IsPastSimMS(600) then
			self.movementSounds.Crouch:Play(self.Pos)
		end
		if moving then
			if self.moveSoundWalkTimer:IsPastSimMS(700) then
				self.movementSounds.Step:Play(self.Pos)
				self.moveSoundWalkTimer:Reset()
			end
		end
	else
		if self.wasCrouching and self.moveSoundTimer:IsPastSimMS(600) then
			self.movementSounds.Stand:Play(self.Pos)
			self.moveSoundTimer:Reset()
		end
	end

	if self.Vel.Y > 10 then
		self.wasInAir = true
	else
		self.wasInAir = false
	end

	self.wasCrouching = crouching
	self.wasMoving = moving
end

function ChaosBeh.handleHealth(self)
	local healthTimerReady = self.healthUpdateTimer:IsPastSimMS(750)
	local wasLightlyInjured = self.Health < (self.oldHealth - 5)
	local wasInjured = self.Health < (self.oldHealth - 25)
	local wasHeavilyInjured = self.Health < (self.oldHealth - 50)

	if healthTimerReady or wasLightlyInjured or wasInjured or wasHeavilyInjured then
		self.oldHealth = self.Health
		self.healthUpdateTimer:Reset()

		if not self.FGArm and (self.FGArmLost ~= true) then
			self.Suppression = self.Suppression + 100
			self.FGArmLost = true
			ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.suppressedHigh, 5, 4)
		end
		if not self.BGArm and (self.BGArmLost ~= true) then
			self.Suppression = self.Suppression + 100
			self.BGArmLost = true
			ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.suppressedHigh, 5, 4)
		end
		if not self.FGLeg and (self.FGLegLost ~= true) then
			self.Suppression = self.Suppression + 100
			self.FGLegLost = true
			ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.suppressedHigh, 5, 4)
		end
		if not self.BGLeg and (self.BGLegLost ~= true) then
			self.Suppression = self.Suppression + 100
			self.BGLegLost = true
			ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.suppressedHigh, 5, 4)
		end

		if wasHeavilyInjured then
			self.Suppression = self.Suppression + 100
			if self.Healing == true then
				self.Healing = false
				if self:IsPlayerControlled() then
					self.healSounds.healStereoInterrupt:Play(self.Pos)
					self.healSound = healSounds.healStereoInterrupt
				else
					self.healSounds.healMonoInterrupt:Play(self.Pos)
					self.healSound = self.healSounds.healMonoInterrupt
				end
			end
			self.healWarned = false
			self.toHeal = false
			self.healTimer:Reset()
			self.healDelayTimer:Reset()
		elseif wasInjured then
			self.Suppression = self.Suppression + 50
			if self.Healing == true then
				self.Healing = false
				if self:IsPlayerControlled() then
					self.healSounds.healStereoInterrupt:Play(self.Pos)
					self.healSound = healSounds.healStereoInterrupt
				else
					self.healSounds.healMonoInterrupt:Play(self.Pos)
					self.healSound = self.healSounds.healMonoInterrupt
				end
			end
			self.healWarned = false
			self.toHeal = false
			self.healTimer:Reset()
			self.healDelayTimer:Reset()
		elseif wasLightlyInjured then
			ChaosBeh.createEmotion(self, 2, 1, 500)
			self.Suppression = self.Suppression + math.random(15, 25)
			if self.Healing == true then
				self.Healing = false
				if self:IsPlayerControlled() then
					self.healSounds.healStereoInterrupt:Play(self.Pos)
					self.healSound = self.healSounds.healStereoInterrupt
				else
					self.healSounds.healMonoInterrupt:Play(self.Pos)
					self.healSound = self.healSounds.healMonoInterrupt
				end
			end
			self.healWarned = false
			self.toHeal = false
			self.healTimer:Reset()
			self.healDelayTimer:Reset()
		end

		if wasInjured or wasHeavilyInjured and self.Head then
			if self.Health > 0 then
				ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.Pain, 2, 2)
			else
				ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.Death, 10, 4)
			end
		end
	end
end

function ChaosBeh.handleDying(self)
	if self.Head then
		if self.deathSoundPlayed ~= true then
			self.deathSoundPlayed = true
			ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.Death, 10, 4)
			self.deathCloseTimer:Reset()
		end
		if self.deathCloseTimer:IsPastSimMS(self.deathCloseDelay) then
			self.Head.Frame = self.baseHeadFrame + 1 -- (+1: eyes closed. rest in peace grunt)
		end
	end
end

function ChaosBeh.handleSuppression(self)
	local blinkTimerReady = self.blinkTimer:IsPastSimMS(self.blinkDelay)
	local suppressionTimerReady = self.suppressionUpdateTimer:IsPastSimMS(1500)

	if blinkTimerReady and not self.Suppressed and self.Head then
		if self.Head.Frame == self.baseHeadFrame then
			ChaosBeh.createEmotion(self, 1, 0, 100)
			self.blinkTimer:Reset()
			self.blinkDelay = math.random(5000, 11000)
		end
	end

	if suppressionTimerReady then
		if self.Suppression > 25 then
			if self.suppressedVoicelineTimer:IsPastSimMS(self.suppressedVoicelineDelay) then
				if self.Suppression > 99 then
					-- keep playing voicelines if we keep being suppressed
					ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.suppressedHigh, 5, 4)
					self.suppressedVoicelineTimer:Reset()
					self.suppressionUpdates = 0
				elseif self.Suppression > 80 then
					ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.suppressedMedium, 4, 4)
					self.suppressedVoicelineTimer:Reset()
					self.suppressionUpdates = 0
				end
				if self.Suppressed == false then -- initial voiceline
					if self.Suppression > 55 then
						ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.suppressedMedium, 4, 4)
					else
						ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.suppressedLow, 3, 2)
					end
					self.suppressedVoicelineTimer:Reset()
				end
			end
			self.Suppressed = true
		else
			self.Suppressed = false
		end
		self.Suppression = math.min(self.Suppression, 100)
		if self.Suppression > 0 then
			self.Suppression = self.Suppression - 7
		end
		self.Suppression = math.max(self.Suppression, 0)
		self.suppressionUpdateTimer:Reset()
	end
end

function ChaosBeh.handleAITargetLogic(self)
	-- SPOT ENEMY REACTION
	-- works off of the native AI's target

	if not self.LastTargetID then
		self.LastTargetID = -1
	end

	-- AGRESSIVENESS
	if not self.Suppressed and self.Health > 55 and self.UniqueID % 2 == 0 then
		self.aggressive = true
	else
		self.aggressive = false
	end

	--spotEnemy

	if (not self:IsPlayerControlled()) and self.AI.Target and IsAHuman(self.AI.Target) then
		self.spotVoiceLineTimer:Reset()

		local posDifference = SceneMan:ShortestDistance(self.Pos, self.AI.Target.Pos, SceneMan.SceneWrapsX)
		local distance = posDifference.Magnitude

		if self.spotAllowed ~= false then
			if self.LastTargetID == -1 then
				self.LastTargetID = self.AI.Target.UniqueID
				-- Target spotted
				--local posDifference = SceneMan:ShortestDistance(self.Pos,self.AI.Target.Pos,SceneMan.SceneWrapsX)

				if
					not self.AI.Target:NumberValueExists("Heat Enemy Spotted Age") -- If no timer exists
					or self.AI.Target:GetNumberValue("Heat Enemy Spotted Age") < (self.AI.Target.Age - self.AI.Target:GetNumberValue(
						"Heat Enemy Spotted Delay"
					)) -- If the timer runs out of time limit
					or math.random(0, 100) < self.spotIgnoreDelayChance -- Small chance to ignore timers, to spice things up
				then
					-- Setup the delay timer
					self.AI.Target:SetNumberValue("Heat Enemy Spotted Age", self.AI.Target.Age)
					self.AI.Target:SetNumberValue(
						"Heat Enemy Spotted Delay",
						math.random(self.spotDelayMin, self.spotDelayMax)
					)

					self.spotAllowed = false

					ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.Spot, 3)
				end
			else
				-- Refresh the delay timer
				if self.AI.Target:NumberValueExists("Heat Enemy Spotted Age") then
					self.AI.Target:SetNumberValue("Heat Enemy Spotted Age", self.AI.Target.Age)
				end
			end
		end
	else
		if self.spotVoiceLineTimer:IsPastSimMS(self.spotVoiceLineDelay) then
			self.spotAllowed = true
		end
		if self.LastTargetID ~= -1 then
			self.LastTargetID = -1
			-- Target lost
			--print("TARGET LOST!")
		end
	end
end

function ChaosBeh.handleDying(self)
	if self.Head then
		if self.deathSoundPlayed ~= true then
			self.deathSoundPlayed = true
			ChaosBeh.createVoiceSoundEffect(self, self.voiceSounds.Death, 10)
		end
	end
end

function ChaosBeh.handleVoicelines(self)
	-- DEVICE RELATED VOICELINES
	
	if self.EquippedItem then	
		-- SUPPRESSING
		if (IsHDFirearm(self.EquippedItem)) then	
			if self.EquippedItem:IsInGroup("Weapons - Primary") then
				local gun = ToHDFirearm(self.EquippedItem);
				local gunMag = gun.Magazine
				
				if gun.FullAuto == true and gunMag and gunMag.Capacity > 10  and gun:IsActivated() then
					if gun.FiredFrame then
						self.gunShotCounter = self.gunShotCounter + 1;
					end
					if self.gunShotCounter > (gunMag.Capacity*0.7) and self.suppressingVoiceLineTimer:IsPastSimMS(self.suppressingVoiceLineDelay) then
						CyborgAIBehaviours.createVoiceSoundEffect(self, self.voiceSounds.Battlecry, 3);
						self.suppressingVoiceLineTimer:Reset();
					end
				else
					self.gunShotCounter = 0;
				end
			end
		end
	end
end