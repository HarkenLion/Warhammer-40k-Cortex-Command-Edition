function Create(self)
	self.fuseDelay = 5000;
	self.fuseDecreaseIncrement = 50;
	self.checkedSky = false
	self.activity = ActivityMan:GetActivity();
	self.addedParticles = {}
	self.stratDelay = Timer()
	self.Delay = Timer()
	self.DelayTime = 3000
	self.BombardTimer = Timer()
	self.BombsThrown = 0
	self.BombardTimer2 = Timer()
	self.BombsThrown2 = 0
	self.Option = 0
	self.Damn = 0
end

function Update(self)
	local glow = CreateMOPixel("Helldiver Beacon Glow 0");
	glow.Pos = self.Pos;
	glow.Vel = self.Vel;
	MovableMan:AddParticle(glow);

	if self.fuse then
		--Diminish fuse length on impact
		if self.TravelImpulse:MagnitudeIsGreaterThan(1) then
			self.fuseDelay = self.fuseDelay - self.TravelImpulse.Magnitude * self.fuseDecreaseIncrement;
		end

		if self.fuse:IsPastSimMS(self.fuseDelay) then
			if self.checkedSky then
				BeaconEffect(self)

				if not self.stratActive and self.stratDelay:IsPastSimMS(1000) then
					self.stratActive = true
				end

				if self.stratActive then
					ArtilleryLight(self)
				end
			else
				-- Check if we can see orbit
				if CanSeeSky(self) then
					self.checkedSky = true
					self.stratDelay:Reset()
				else
					self:GibThis()
				end
			end
		end
	elseif self:IsActivated() then
		self.fuse = Timer();
	end

	for i = 1, #self.addedParticles do
		MovableMan:AddParticle(self.addedParticles[i]);
	end
	self.addedParticles = {};
end

function CanSeeSky(self)
	local endPos = Vector(0, 0)
	local trace = Vector(0, -SceneMan.SceneHeight)
	local rayLength = SceneMan:CastTerrainPenetrationRay(self.Pos, trace, endPos, 1, 5);
	print("endPos: " .. tostring(endPos))
	print("CanSeeSky: " .. tostring(endPos.Y == SceneMan.SceneHeight))
	if endPos.Y <= 0 then
		return true
	else
		return false
	end
end

function BeaconEffect(self)
	local endPos = Vector(self.Pos.X, 0)
	local startPos = self.Pos
	local trace = SceneMan:ShortestDistance(startPos, endPos, SceneMan.SceneWrapsX);
	local particleCount = trace.Magnitude * RangeRand(0.4, 0.8);
	for i = 0, particleCount do
		local pix = nil
		if not self.stratActive then
			pix = CreateMOPixel("Helldiver Beacon Glow 1", "SuperEarth.rte");
		else
			pix = CreateMOPixel("Helldiver Beacon Glow 2", "SuperEarth.rte");
		end
		pix.Pos = startPos + trace * i/particleCount;
		pix.Vel = self.Vel;
		table.insert(self.addedParticles, pix);
	end
end

function ArtilleryLight(self)
	if not self.setupStrat then
		self.artilleryTimer = Timer()
		self.salvoTimer = Timer()
		self.shellsDropped = 0
		self.setupStrat = true
	end


	if self.salvoTimer:IsPastSimMS(1500) and self.artilleryTimer:IsPastSimMS(1500) then
		-- create new shell
		self.Bomb = CreateTDExplosive("Titan Artillery")
		self.Bomb.Pos = Vector(self.Pos.X + math.random(-1000, 1000), -10)
		self.Bomb.Vel = Vector(math.random(6, 10), 250 + math.random(20))
		MovableMan:AddParticle(self.Bomb)
		self.BombsThrown = self.BombsThrown + 1
		self.BombardTimer:Reset()
		self.Bomb2 = CreateTDExplosive("Titan Artillery2")
		self.Bomb2.Pos = Vector(self.Pos.X + math.random(-500, 500), -10)
		self.Bomb2.Vel = Vector(math.random(6, 10), 150 + math.random(20))
		MovableMan:AddParticle(self.Bomb2)
		self.BombsThrown2 = self.BombsThrown2 + 1
		self.BombardTimer2:Reset()
		self.Bomb.Team = self.Team
		self.Bomb2.Team = self.Team
		AudioMan:PlayMusic("imperialguard.rte/12191.flac", 0.1,-10);

		self.artilleryTimer:Reset()
		self.salvoTimer:Reset()
		if self.BombsThrown >=20 then
			self:GibThis()
		end
	end
end