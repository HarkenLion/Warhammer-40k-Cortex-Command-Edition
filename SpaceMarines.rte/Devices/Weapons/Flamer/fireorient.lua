function Create(self)
    self.hit = 0
    self.LifeTimer = Timer();
    self.hittime = math.random(0,250)
    self.hitTimer = Timer();
end

function OnCollideWithMO(self,hitmo,rootmo)
    if self.hitTimer:IsPastSimMS(100) then
        local FlameBall = CreateMOSRotating("SM Heavy Burn Particle", "SpaceMarines.rte")
        FlameBall.Vel = self.Vel      
        FlameBall.Pos = self.Pos
        MovableMan:AddParticle(FlameBall)

        if MovableMan:ValidMO(rootmo) then
            self:SetWhichMOToNotHit(root, 119)
        else
            self:SetWhichMOToNotHit(hitmo, 119)
        end
        self.hitTimer:Reset();
    end
end


function Update(self)
    if self.HitsMOs == false and self.LifeTimer:IsPastSimMS(self.hittime) then
        self.HitsMOs = true
    end
end