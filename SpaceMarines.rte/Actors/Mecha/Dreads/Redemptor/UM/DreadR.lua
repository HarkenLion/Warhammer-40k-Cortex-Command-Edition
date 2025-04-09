
dofile("Base.rte/Constants.lua")
dofile("SpaceMarines.rte/AI/NativeSpaceMarineAI.lua")


function Create(self)
	self.enableselect = true;
	self.Turret = {};
	self.Turret[1] = CreateTurret("Broadside Shoulder Pod");
	self.Turret[1].Team = self.Team;
	self.Turret[1].Offset = Vector(6,-48);
	self:AddAttachable(self.Turret[1])
	self.AI = NativeSpaceMarineAI:Create(self)
	self.c = self:GetController();
	self.triggerang = math.pi/3 --4
	self.musclemult = 0.5 -- --1.25 --2.5 --1.5
	self.pscale = GetPPM()*self.musclemult
	self.FGFootPrevPos = self.FGFoot.Pos.X-self.Pos.X
	self.BGFootPrevPos = self.BGFoot.Pos.X-self.Pos.X
	self.kneedist = 12
	self.fglegpushed = false;
	self.bglegpushed = false;
end

function Update(self)
end
