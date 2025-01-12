dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	self.BuffTime = Timer()
	self.mapwrapx = SceneMan.SceneWrapsX
	self.LookOutSirTimer = Timer()
end

function Update(self)
	if self.BuffTime:IsPastSimMS(300) then
		self.BuffTime:Reset()
		--for actor in MovableMan.Actors do
		for actor in MovableMan:GetMOsInRadius(self.Pos, 165, -1) do
			--if actor.Team == self.Team then
			local parvector = SceneMan:ShortestDistance(self.Pos, actor.Pos, self.mapwrapx)
			--local pardist = parvector.Magnitude;
			if parvector:MagnitudeIsLessThan(165) then
				if ToActor(actor).Health < 100 and ToActor(actor).Mass < 160 then
					ToActor(actor).Health = ToActor(actor).Health + 1
				end
			end

			if
				parvector:MagnitudeIsLessThan(45)
				and actor.PresetName ~= "Imperial Commissar"
				and actor.PresetName ~= "Imperial Commissar Field Commander"
			then
				self.LookOutSirTimer:Reset()
			end
			--end
		end
	end

	if not self.LookOutSirTimer:IsPastSimMS(300) then
		self.GetsHitByMOs = false
	elseif self.LookOutSirTimer:IsPastSimMS(300) and not self.LookOutSirTimer:IsPastSimMS(320) then
		self.GetsHitByMOs = true
	end
end

function UpdateAI(self)
	self.AI:Update(self)
end
