function DynamicArmySoundtrackIM:StartScript()
    self.actorRequirement = 8;
    self.actorCount = 0;
    self.requirementReached = false;
    self.playmusic = false;
    self.musicPath = "SpaceMarines.rte/Music/Armageddon.ogg";
end

function DynamicArmySoundtrackIM:UpdateScript()
    if not self.requirementReached then
        self.actorCount = 0;

        for actor in MovableMan.Actors do
            if actor.ModuleName == self.ModuleName then
                self.actorCount = self.actorCount + 1;

                if self.actorCount == self.actorRequirement then
                    self.requirementReached = true;
                    break;
                end
            end
        end
    else
        if not self.playmusic then
            AudioMan:PlayMusic(self.musicPath, 0, -1);
            self.playmusic = true;
        end
    end
end