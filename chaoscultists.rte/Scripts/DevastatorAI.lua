dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI")

function Create(self)
	self.AI = NativeHumanAI:Create(self)

	self.enableselect = true
	self.prevHealth = 44
end

function Update(self)
	if not self:IsDead() then
		if self:IsPlayerControlled() == true then
			if self.enableselect == true then
				self.selected = CreateAEmitter("Marine Select")
				self.selected.Pos = self.Pos
				self.selected.PinStrength = 1000
				MovableMan:AddParticle(self.selected)
				self.enableselect = false
			end
		else
			self.enableselect = true
		end

		health = self.Health

		if health < 45 and health > 0 then
			if health < self.prevHealth then
				local rand = math.random(0, 10)
				if rand > (7 - self.Sharpness) then
					self.Health = self.prevHealth --FEEL NO PAIN
				else
					self.prevHealth = health
				end
			end
		end
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
