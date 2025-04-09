function DynamicArmySoundtrackC:StartScript()
    self.actorRequirement = 7
    self.actorCount = 0
    self.requirementReached = false
end

function DynamicArmySoundtrackC:UpdateScript()
    if not self.requirementReached then
        self.actorCount = 0
        for actor in MovableMan.Actors do
            if actor.PresetName == "Black Legion Marine" then
                self.actorCount = self.actorCount + 1

                if self.actorCount == self.actorRequirement then
                    self.requirementReached = true
                end
            end
        end
    else
        if not self.playmusic then
                AudioMan:PlayMusic("ChaosSpaceMarines.rte/SM/OHGODd.ogg",0,-1)
            self.playmusic = true
        end
    end
end