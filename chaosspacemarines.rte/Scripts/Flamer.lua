function Create(self)
	self.recoil = 0
	self.firecounter = 0
	self.recoilcooldown = 0.0003
	self.firetimer = Timer()
	self.muzflash = nil
end

function OnFire(self)
	local user
	user = MovableMan:GetMOFromID(self.RootID)

	if not MovableMan:ValidMO(self.muzflash) then
		self.muzflash = CreateAEmitter("Muzzle Flash Flamer A") -- Sound FX Emitter PresetName
		local randnum = math.random(0, 4)
		if randnum > 1 and randnum < 3 then
			self.muzflash = CreateAEmitter("Muzzle Flash Flamer B")
		end
		if randnum >= 3 then
			self.muzflash = CreateAEmitter("Muzzle Flash Flamer C")
		end
		local velFactor = GetPPM() * TimerMan.DeltaTimeSecs
		local checkVect = user.Vel * velFactor
		self.muzflash.Pos = self.MuzzlePos + (checkVect * 1.2)
		if self.HFlipped then
			self.muzflash.RotAngle = self.RotAngle + math.pi
		else
			self.muzflash.RotAngle = self.RotAngle
		end
		self.muzflash.Frame = math.random(0, 4)
		self.muzflash.LifeTime = math.random(90, 190)
		self.muzflash.Scale = math.random(5, 10) * 0.1
		MovableMan:AddParticle(self.muzflash)
	else
		self.muzflash.Pos = self.MuzzlePos
	end
end

function Update(self) end
