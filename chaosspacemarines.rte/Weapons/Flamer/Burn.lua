function Create(self)
	self.FlashTimer = Timer()
	self.target = nil

	self.stickpositionX = 0
	self.stickpositionY = 0
	self.stickrotation = 0
	self.stickdirection = 0
	self.startflipped = false

	self.stundelay = 500 -- delay before stunning (MS)
	self.stuntime = 1000 -- how long target is stunned (MS)
	self.hit = 0
	self.HitsMOs = true
end

function OnCollideWithMO(self, hitmo)
	if self.target == nil then
		self.target = hitmo --MovableMan:GetMOFromID(hitmo); --self.stickobject);
		self.stickpositionX = self.Pos.X - self.target.Pos.X
		self.stickpositionY = self.Pos.Y - self.target.Pos.Y
		self.stickrotation = self.target.RotAngle
		self.stickdirection = self.RotAngle
		self.startflipped = self.target.HFlipped
	end
end

function Update(self)
	if self.target ~= nil and self.target.ID ~= 255 then
		self.ToDelete = false
		self.ToSettle = false
		self.Pos = self.target.Pos
			+ Vector(self.stickpositionX, self.stickpositionY):RadRotate(self.target.RotAngle - self.stickrotation)
		self.RotAngle = self.stickdirection + (self.target.RotAngle - self.stickrotation)
		self.Vel = Vector(0, 0)
		self.PinStrength = 1000

		self.actor = MovableMan:GetMOFromID(self.target.RootID)

		if MovableMan:IsActor(self.actor) then
			if self.FlashTimer:IsPastSimMS(125) then
				self.FlashTimer:Reset()
				if ToActor(self.actor).Health < 3 then
					ToActor(self.actor).Health = 0
					self.ToDelete = true
				end
				ToActor(self.actor).Health = ToActor(self.actor).Health - 1
				if self.hit > 4 then
					local randx = math.random(-10, 10)
					local randy = math.random(-10, 10)
					local FlameBall = CreateMOSRotating("Flame Ball 1 No Glow", "spacemarines.rte")
					FlameBall.Vel = self.actor.Vel
					FlameBall.Pos.X = self.actor.Pos.X + randx
					FlameBall.Pos.Y = self.actor.Pos.Y + randy
					MovableMan:AddParticle(FlameBall)
					self.ToDelete = true
				end
				self.hit = self.hit + 1
			end
		end
	elseif self.target ~= nil and self.target.ID == 255 then
		self:GibThis()
	end
end
