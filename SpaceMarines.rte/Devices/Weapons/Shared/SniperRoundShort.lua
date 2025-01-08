function Create(self)
self.HitsMOs = false
self.Mass = 0.10
self.Sharpness = 9

local velFactor = GetPPM() * TimerMan.DeltaTimeSecs; 
local checkVect = self.Vel * velFactor * 1.5; 
local moid = SceneMan:CastMORay(self.Pos,checkVect,self.ID,self.Team,0,false,0); 
	
if moid ~= 255 and moid ~= 0 then 
	self.Mass = 0.35
	self.Sharpness = 9
	local hitMO = MovableMan:GetMOFromID(moid);
	local root = MovableMan:GetMOFromID(hitMO.RootID);

--KILLING HIT

if root:IsActor() and root.ClassName == "AHuman" and root.Mass < 150 then


	local part1 = (1250/root.Mass);

	ToActor(root).Health = ToActor(root).Health-part1;

	local swishfx = CreateAEmitter("SMSniper Bullet Flesh Hit Sound");
	swishfx.Pos = self.Pos;
	MovableMan:AddParticle(swishfx);

	ToActor(root):ClearMovePath();
	ToActor(root):SetAimAngle(ToActor(root):GetAimAngle(true) + 0.35);
end


else
	self.Mass = 0.14
	self.Sharpness = 12
end 		


end

function Update(self)

local velFactor = GetPPM() * TimerMan.DeltaTimeSecs; 
local checkVect = self.Vel * velFactor; 
local moid = SceneMan:CastMORay(self.Pos,checkVect,self.ID,self.Team,0,false,0); 

if moid ~= 255 and moid ~= 0 then
	self.Mass = 0.35
	self.Sharpness = 9
	local hitMO = MovableMan:GetMOFromID(moid);
	local root = MovableMan:GetMOFromID(hitMO.RootID);

--KILLING HIT

if root:IsActor() and root.ClassName == "AHuman" and root.Mass < 150 then 


	local part1 = (1250/root.Mass);

	ToActor(root).Health = ToActor(root).Health-part1;

	local swishfx = CreateAEmitter("SMSniper Bullet Flesh Hit Sound");
	swishfx.Pos = self.Pos;
	MovableMan:AddParticle(swishfx);

	ToActor(root):ClearMovePath();
	ToActor(root):SetAimAngle(ToActor(root):GetAimAngle(true) + 0.35);

end

else
	self.Mass = 0.14
	self.Sharpness = 12
end 
	

end