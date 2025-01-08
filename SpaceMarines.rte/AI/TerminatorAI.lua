
dofile("Base.rte/Constants.lua")
require("AI/NativeHumanAI")  --dofile("Base.rte/AI/NativeHumanAI.lua")
package.path = package.path .. ";Mods/SpaceMarines.rte/?.lua";
require("Scripts/terminatorAIBehaviourss")

function Create(self)
	self.AI = NativeHumanAI:Create(self)
	--You can turn features on and off here
	
	-- Start modded code --
	
	self.RTE = "SpaceMarines.rte";
	self.baseRTE = "SpaceMarines.rte";

	if math.random(0, 1) == 0 then
		self.voiceSounds = {
		Death = CreateSoundContainer("VOO Death VariantOne", "SpaceMarines.rte"),
		Spot = CreateSoundContainer("VOO Spot VariantOne", "SpaceMarines.rte"),};
	else
		self.voiceSounds = {
		Death = CreateSoundContainer("VOO Death VariantOne", "SpaceMarines.rte"),
		Spot = CreateSoundContainer("VOO Spot VariantOne", "SpaceMarines.rte"),};
	end
	
	self.voiceSound = CreateSoundContainer("VO Pain spacemarines", "SpaceMarines.rte");
	-- MEANINGLESS! this is just so we can do voiceSound.Pos without an if check first! it will be overwritten first actual VO play

	self.healDelayTimer = Timer();
	self.healTimer = Timer();
	
	self.healInitialDelay = 10000;
	self.healDelay = 2000;
	
	self.healJuice = 250;    -- not actually hp idk why, this translates to 100-150 hp heal
	self.healThreshold = 80; -- hp below which to try to heal
							 -- ideally i'd heal anytime below 100 but the sounds and the timers get iffy since we want to heal even when bleeding lightly

	self.altitude = 0;
	self.wasInAir = false;
	
	self.moveSoundTimer = Timer();
	self.moveSoundWalkTimer = Timer();
	self.wasCrouching = false;
	self.wasMoving = false;
	
	self.emotionTimer = Timer();
	self.emotionDuration = 0;
	
	self.blinkTimer = Timer();
	self.blinkDelay = math.random(5000, 11000);
	
	self.deathCloseTimer = Timer();
	self.deathCloseDelay = 750;
	
	self.Suppression = 0;
	self.Suppressed = false;
	
	self.reloadVoicelineTimer = Timer();
	self.reloadVoicelineDelay = 5000;
	
	self.suppressionUpdateTimer = Timer();
	
	self.suppressedVoicelineTimer = Timer();
	self.suppressedVoicelineDelay = 5000;
	
	self.healthUpdateTimer = Timer();
	self.oldHealth = self.Health;

	self.spotVoiceLineTimer = Timer();
	self.spotVoiceLineDelay = 15000;
	
	self.gunShotCounter = 0;
	self.suppressingVoiceLineTimer = Timer();
	self.suppressingVoiceLineDelay = 15000;
	
	self.leadVoiceLineTimer = Timer();
	self.leadVoiceLineDelay = 15000;
	
	 -- in MS
	self.spotDelayMin = 4000;
	self.spotDelayMax = 8000;
	
	 -- in percent
	self.spotIgnoreDelayChance = 10;
	self.spotNoVoicelineChance = 15;

	-- heal ability
	
		-- MEANINGLESS! also
		
		self.healDelayTimer = Timer();
		self.healTimer = Timer();
		
		self.healInitialDelay = 10000;
		self.healDelay = 2000;
		
		self.healJuice = 250;    -- not actually hp idk why, this translates to 100-150 hp heal
		self.healThreshold = 80; -- hp below which to try to heal
								 -- ideally i'd heal anytime below 100 but the sounds and the timers get iffy since we want to heal even when bleeding lightly

	-- Leg Collision Detection system
    self.feetContact = {false, false}
    self.feetTimers = {Timer(), Timer()}
	self.footstepTime = 100 -- 2 Timers to avoid noise

	-- End modded code
end

function Update(self)

	self.controller = self:GetController();
	
	-- Start modded code--
	
	self.voiceSound.Pos = self.Pos;
	
	if (self:IsDead() ~= true) then

		terminatorAIBehaviours.handleHealth(self);

		terminatorAIBehaviours.handleAITargetLogic(self);
		
	else
	
		terminatorAIBehaviours.handleDying(self);

	end

end
-- End modded code --

function UpdateAI(self)
	self.AI:Update(self)

end

function Destroy(self)
	self.AI:Destroy(self)
	
	-- Start modded code --
	
	if not self.ToSettle then -- we have been gibbed		
		self.voiceSound:Stop(-1);
	end
	
	-- End modded code --
	
end
