function Create(self)
	self.newMag = true
end

function Update(self)
	if self.Magazine ~= nil then
		if self.newMag == true then
			self.Magazine.Frame = 6
			self.newMag = false
		end

		if self.Magazine.RoundCount < 6 then
			self.Magazine.Frame = self.Magazine.RoundCount
		else
			if self.FiredFrame then
				if self.Magazine.Frame < 8 then
					self.Magazine.Frame = self.Magazine.Frame + 1
				else
					self.Magazine.Frame = 6
				end
			end
		end
	else
		self.newMag = true
	end
end
