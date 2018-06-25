local FightTimeDelayFinish = class("FightTimeDelayFinish")

function FightTimeDelayFinish:ctor(time)
    self.time = time
end

function FightTimeDelayFinish:init_impl(step)
    self.is_start = true
    if GuideConst.gameInst and GuideConst.gameInst._runTime then
        self.start_time = GuideConst.gameInst._runTime
    end
end

function FightTimeDelayFinish:check_finish_impl(step)
    if not self.start_time then
        if GuideConst.gameInst and GuideConst.gameInst._runTime then
            self.start_time = GuideConst.gameInst._runTime
        end
    end
    return self.start_time and GuideConst.gameInst._runTime - self.start_time >= self.time
end

return FightTimeDelayFinish