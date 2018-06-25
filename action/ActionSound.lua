local ActionSound = class("ActionSound")

function ActionSound:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionSound:start_impl()
    if self.args.startSound then
        if self.args.isBgMusic then
            self.handler = audio.playMusic(pathMgr:uiMusic(self.args.startSound) , self.args.isLoop)
        else
            self.handler = guideMgr.soundQueue:playSound(pathMgr:uiMusic(self.args.startSound) , self.args.isLoop)
        end
    end
end

function ActionSound:stopPlay()
    if self.handler and self.args.stop then
        if self.args.isBgMusic then
            audio.stopMusic(self.handler)
        else
            audio.stopSound(self.handler)
        end
        self.handler = nil
    end
end

function ActionSound:finish_impl()
    self:stopPlay()
    if self.args.finishSound then
        if self.args.isBgMusic then
            audio.playMusic(pathMgr:uiMusic(self.args.finishSound) , self.args.isLoop)
        else
            guideMgr.soundQueue:playSound(pathMgr:uiMusic(self.args.finishSound) , self.args.isLoop)
        end
    end
end

function ActionSound:interrupt_impl()
    self:stopPlay()
end

return ActionSound