function Create(self)

	self.num = 0;

	self.draw = true;
	self.windup = false;
	self.swing = false;
	self.cooldown = false;
	self.connect = false;
	self.bounced = false;
	self.lastAngle = 0;
	self.crits = 0;		-- track critical hits
	self.critsMax = 5;	-- max amount of critical hits per swing

	self.speed = 0.5;	-- variable(not)
	self.equipSound = CreateSoundContainer("Powersword Equip", "SpaceMarines.rte");
	self.swingSound = CreateSoundContainer("Powersword Swing", "SpaceMarines.rte");
	self.bounceSound = CreateSoundContainer("Powersword Bounce", "SpaceMarines.rte");
	self.swingTimer = Timer();
end

function OnAttach(self)
	self.equipSound:Play(self.Pos);
end

function OnDetach(self)
	self.equipSound:Play(self.Pos);
end

function Update(self)
	local parent = self:GetRootParent();
	if parent and IsAHuman(parent) then
		parent = ToAHuman(parent);
		local speed = self.speed;
		local pAngle = parent:GetAimAngle(false);
		local arc = self.lastAngle - pAngle;

		if self.Magazine then
			self.Magazine.Scale = 1;
			self.Scale = 0;
		end

		local rotAngle = -(-0.2 * (2 * math.pi) - math.sin(self.num) * 1.9 - arc);

		if self.cooldown == true then
			self.swing = false;
			--SWING is COMPLETED or CONNECTED HIT reaches DELAY END
			local recovertime = math.max(0,350-100*parent.Sharpness)
			if self.num > 2 * math.pi or self.swingTimer:IsPastSimMS(recovertime) then
				self.cooldown = false;
				self.num = 0;
			else
				if not self.swingTimer:IsPastSimMS(55) then
					if self.bounced == false then
						self.num = self.num + 0.2*math.sin(0.25*self.swingTimer.ElapsedSimTimeMS)
					else
						self.num = self.num - 0.1*(55-self.swingTimer.ElapsedSimTimeMS)
					end
				end
			end

		elseif self.swing == true then

			self.windup = false;
			if self.connect == true or self.num > math.pi * 1.5 then
				self.cooldown = true;
				self.swingTimer:Reset();
			else
				self.num = self.num + speed;
				local velBonus = (parent.PrevVel.X * 0.2 - parent.AngularVel * 2) * parent.FlipFactor + math.abs(parent.PrevVel.Y * 0.1);
				local tracevec = parent.Vel + Vector((61 + velBonus) * self.FlipFactor, 0):RadRotate(rotAngle - 0.3)
				local moid = SceneMan:CastMORay(self.MuzzlePos, tracevec, self.ID, self.Team, 0, false, 3)
				
				local part = CreateMOPixel("Particle Powersword 2");
				part.Pos = self.MuzzlePos;

				part.Vel = 	parent.Vel + Vector((85 + velBonus) * self.FlipFactor, 0):RadRotate(rotAngle - 0.3);

				part.Mass = 0.1 * RangeRand(0.75, 1.25);
				part.Sharpness = 350 * RangeRand(0.75, 1.25);

				part.Team = self.Team;
				part.IgnoresTeamHits = true;

				MovableMan:AddParticle(part);

				if moid ~= 255 and moid ~= 0 then
					for i = 0, 2 do
						local part = CreateMOPixel("Particle Powersword 2");
						part.Pos = SceneMan:GetLastRayHitPos()
						part.Vel = 	parent.Vel + Vector((85 + velBonus) * self.FlipFactor, 0):RadRotate(rotAngle - 0.3);
						part.Mass = 0.1 * RangeRand(0.75, 1.25);
						part.Sharpness = 350 * RangeRand(0.75, 1.25);
						part.Team = self.Team;
						part.IgnoresTeamHits = true;

						MovableMan:AddParticle(part);
					end
					local hitMO = MovableMan:GetMOFromID(moid)
					local root = MovableMan:GetMOFromID(hitMO.RootID)

					if hitMO and (MovableMan:IsActor(root)) then
						self.zapman = ToActor(root)
						self.zapman:SetAimAngle(math.random(math.pi / -2, math.pi / 2))
						self.zapman:FlashWhite(25)
		
						self.zapman:GetController():SetState(Controller.WEAPON_FIRE, false)
		
						local soundfx = CreateAEmitter("Lightning Impact")
						soundfx.Pos = SceneMan:GetLastRayHitPos()
						MovableMan:AddParticle(soundfx)
					end

					--CHECK CONNECT POINT FOR TOUGHNESS, IF IT'S TOO TOUGH THEN BLADE STOPS
					local startvec = SceneMan:GetLastRayHitPos()
					local tracevec = Vector((7) * self.FlipFactor, 0):RadRotate(rotAngle - 0.3)
					local ustren = 95+parent.Sharpness*5 --90 --100
					local hitvec = Vector();
					local sray = SceneMan:CastStrengthRay(startvec,tracevec,ustren,hitvec,2,0,true)
					if sray == true then
						--CHECK FOR BOUNCING OFF
						local sray2 = SceneMan:CastStrengthRay(startvec,tracevec,ustren+25,hitvec,2,0,true) 
						if sray2 == true then
							self.num = self.num - speed*2;
							self.bounceSound:Play(self.Pos);
							self.bounced = true;
						--NO BOUNCE, ADVANCE TO STICKING ROTATION
						else
							self.num = self.num-speed*0.065
						end
						--ENGAGE CONNECTED HIT TIMER and CONDITIONS
						self.connect = true;
						self.swingTimer:Reset();
					end
				end


			end

		elseif self.windup == true then

			if self.num > math.pi * 0.5 then

				if parent:IsPlayerControlled() == false then
					self:Deactivate();
				end

				if self:IsActivated() then
					self.num = 0.5 * math.pi;
				else
					self.swingSound:Play(self.Pos);
					self.swing = true;
					self.connect = false;
					self.bounced = false;
					self.crits = 0;
				end
			else
				self.num = self.num + speed * 0.3;
			end

		elseif self:IsActivated() then
			self.windup = true;
		end

		local offset = Vector(0,0)
		if self.windup ~= true and self.swing ~= true then
			offset = Vector(11, 14):RadRotate(-0.25 + math.sin(self.num) * 1.4);
			rotAngle = rotAngle -0.9
			self.Supportable = false
		else
			offset = Vector(17, 2):RadRotate(-0.25 + math.sin(self.num) * 1.2);
			self.Supportable = true 
		end
		--local offset = Vector(15, 1):RadRotate(-0.25 + math.sin(self.num) * 1.4);

		self.StanceOffset = offset;
		self.SharpStanceOffset = offset;
		self.InheritedRotAngleOffset = rotAngle;

		self.lastAngle = pAngle;
	else
		self.num = 0;

		self.draw = true;
		self.windup = false;
		self.swing = false;


		self.Scale = 1;
		if self.Magazine then
			self.Magazine.Scale = 0;
		end
	end
end