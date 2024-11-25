function Create(self)
      self.Scale = 0.9;
      self.coilheat = 0;   
      self.fTimer = Timer();              
end

function OnFire(self)
      self.coilheat=self.coilheat+20
      self.Frame = math.min(self.coilheat*0.1,5)
      self.fTimer:Reset();
end

function Update(self)
      if self.coilheat > 0 and self.fTimer:IsPastSimMS(50) then
            self.coilheat = self.coilheat - 1
            self.Frame = math.min(self.coilheat*0.1,5)
            self.fTimer:Reset();
      end
end