local SoundQueue = class("SoundQueue")

function SoundQueue:playSound(path , loop)
    if self.handler then
        audio.stopSound(self.handler)
    end
    self.handler = audio.playSound(path , loop)
end

function SoundQueue:reset()
    if self.handler then
        audio.stopSound(self.handler)
        self.handler = nil
    end
end

return SoundQueue