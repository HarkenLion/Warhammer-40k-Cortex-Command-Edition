function Create(self)

	local Effect
	local Offset = self.Vel*(20*TimerMan.DeltaTimeSecs)	-- the effect will be created the next frame so move it one frame backwards towards the barrel
	
	for i = 1, 2 do
		Effect = CreateMOSParticle("Tiny Smoke Ball 1", "Base.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset
			Effect.Vel = (self.Vel + Vector(RangeRand(-20,20), RangeRand(-20,20))) / 30
			MovableMan:AddParticle(Effect)
		end
	end
	
	if PosRand() < 0.5 then
		Effect = CreateMOSParticle("Side Thruster Blast Ball 1", "Base.rte")
		if Effect then
			Effect.Pos = self.Pos - Offset
			Effect.Vel = self.Vel / 10
			MovableMan:AddParticle(Effect)
		end
	end

self.Mass = 0.35
self.Sharpness = 5

local speed = math.abs(self.Vel.Magnitude);

if speed > 50 then

local velFactor = GetPPM() * TimerMan.DeltaTimeSecs; 
local checkVect = self.Vel * velFactor; 
local moid = SceneMan:CastMORay(self.Pos,checkVect,self.ID,self.Team,0,false,0); 
	
if moid ~= 255 and moid ~= 0 then 
	self.Mass = 0.45
	self.Sharpness = 6
	local hitMO = MovableMan:GetMOFromID(moid);
	local root = MovableMan:GetMOFromID(hitMO.RootID);

--KILLING HIT

if root:IsActor() and root.ClassName == "AHuman" and root.Mass < 100 then
	local part1 = (7950/root.Mass);

	if part1 < 65 then
		part1 = 85;
	end

	ToActor(root).Health = ToActor(root).Health-part1;

	local swishfx = CreateAEmitter("SMSniper Bullet Flesh Hit Sound");
	swishfx.Pos = self.Pos;
	MovableMan:AddParticle(swishfx);

	ToActor(root):ClearMovePath();
	ToActor(root):SetAimAngle(ToActor(root):GetAimAngle(true) + 0.35);
end

--DISARM
if hitMO:IsHeldDevice() and hitMO.Mass > 5 and hitMO.ClassName == "HDFirearm" and hitMO.PresetName ~= "" then 
	hitMO:AddImpulseForce((checkVect/velFactor) * (self.Mass), Vector(0,0));
	local swishfx = CreateAEmitter("SMSniper Bullet Metal Hit Sound");
	swishfx.Pos = self.Pos;
	MovableMan:AddParticle(swishfx);	
end

--SUNDER ARMOR
if (hitMO.ClassName == "Attachable") and hitMO.Mass < 15 and ((string.find(hitMO.PresetName,"Armor") ~= nil) or (string.find(hitMO.PresetName,"Plate") ~= nil)) then
	hitMO:AddImpulseForce((checkVect/velFactor) * (self.Mass), Vector(0,0));	
	hitMO.AngularVel = 0;
	hitMO.Vel = Vector(0,0);
end

--HEADSHOT DAMAGE
if ((string.find(hitMO.PresetName,"Head") ~= nil) or (string.find(hitMO.PresetName,"Helmet") ~= nil) or (string.find(hitMO.PresetName,"Hat") ~= nil)) then
	local HSPix = CreateMOPixel("Particle SMSniper Pistol Headshot Damage");
	HSPix.Pos = self.Pos;
	HSPix.Vel = self.Vel;
	MovableMan:AddParticle(HSPix);
end

--KNOCKBACK LIMBS
if (hitMO.ClassName == "Attachable") and hitMO.Mass < 45 and ( (string.find(hitMO.PresetName,"Arm") ~= nil) or (string.find(hitMO.PresetName,"Leg") ~= nil)) then
	hitMO:AddAbsForce((checkVect/velFactor) * ((self.Mass * 1.15) + (hitMO.Mass * 0.45)), Vector(0,0));		
end

else
	self.Mass = 0.14
	self.Sharpness = 12
end 		

end


end

function Update(self)

local speed = math.abs(self.Vel.Magnitude);

if speed > 70 then

local velFactor = GetPPM() * TimerMan.DeltaTimeSecs; 
local checkVect = self.Vel * velFactor; 
local moid = SceneMan:CastMORay(self.Pos,checkVect,self.ID,self.Team,0,false,0); 

if moid ~= 255 and moid ~= 0 then
	self.Mass = 0.35
	self.Sharpness = 9
	local hitMO = MovableMan:GetMOFromID(moid);
	local root = MovableMan:GetMOFromID(hitMO.RootID);

--KILLING HIT

if root:IsActor() and root.ClassName == "AHuman" and root.Mass < 100 then 
	local part1 = (7950/root.Mass);

	if part1 < 65 then
		part1 = 85;
	end

	ToActor(root).Health = ToActor(root).Health-part1;

	local swishfx = CreateAEmitter("SMSniper Bullet Flesh Hit Sound");
	swishfx.Pos = self.Pos;
	MovableMan:AddParticle(swishfx);

	ToActor(root):ClearMovePath();
	ToActor(root):SetAimAngle(ToActor(root):GetAimAngle(true) + 0.35);
end

--DISARM
if hitMO:IsHeldDevice() and hitMO.Mass > 5 and hitMO.ClassName == "HDFirearm" and hitMO.PresetName ~= "" then 
	hitMO:AddImpulseForce((checkVect/velFactor) * (self.Mass * 1.5), Vector(0,0));	
	local swishfx = CreateAEmitter("SMSniper Bullet Metal Hit Sound");
	swishfx.Pos = self.Pos;
	MovableMan:AddParticle(swishfx);	
end

--SUNDER ARMOR
if (hitMO.ClassName == "Attachable") and hitMO.Mass < 15 and ((string.find(hitMO.PresetName,"Armor") ~= nil) or (string.find(hitMO.PresetName,"Plate") ~= nil)) then
	hitMO:AddImpulseForce((checkVect/velFactor) * (self.Mass), Vector(0,0));	
	hitMO.AngularVel = 0;
	hitMO.Vel = Vector(0,0);
end

--HEADSHOT DAMAGE
if ((string.find(hitMO.PresetName,"Head") ~= nil) or (string.find(hitMO.PresetName,"Helmet") ~= nil) or (string.find(hitMO.PresetName,"Hat") ~= nil)) then
	local HSPix = CreateMOPixel("Particle SMSniper Pistol Headshot Damage");
	HSPix.Pos = self.Pos;
	HSPix.Vel = self.Vel * 0.5;
	MovableMan:AddParticle(HSPix);

	local HSPix2 = CreateMOPixel("Particle SMSniper Pistol Headshot Damage");
	HSPix2.Pos = self.Pos;
	HSPix2.Vel = self.Vel * 0.5;
	MovableMan:AddParticle(HSPix2);
end

--KNOCKBACK LIMBS
if (hitMO.ClassName == "Attachable") and hitMO.Mass < 45 and ( (string.find(hitMO.PresetName,"Arm") ~= nil) or (string.find(hitMO.PresetName,"Leg") ~= nil)) then
	hitMO:AddAbsForce((checkVect/velFactor) * ((self.Mass * 1.15) + (hitMO.Mass * 0.45)), Vector(0,0));		
end

else
	self.Mass = 0.14
	self.Sharpness = 12
end 

end

end