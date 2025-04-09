local coolColours = {168, 169, 170};
local coolDelay = 4000;
local coolVariation = 2500;

function Create(self)
	self.Age = self.Age + math.random(coolVariation)
	local var = {};
	var.coolColour = coolColours[math.random(#coolColours)];
	var.coolTimer = Timer();
	var.coolDelay = coolDelay - self.Age;
	
	self.var = var;
end

function ThreadedUpdate(self)
	local var = self.var;
	if var.coolTimer:IsPastSimMS(var.coolDelay) then
		self.ToSettle = true;
	end
	
	if self.ToSettle then
		self:SetColorIndex(var.coolColour);
	end
end

function OnMessage(self, message, context)
	if message == "HPOM_Slag" then
		self.var.coolColour = context;
	end
end