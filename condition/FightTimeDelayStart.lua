local ConditionDelayStart = class("ConditionDelayStart")

function ConditionDelayStart:ctor(time)
    self.time = time
end

function ConditionDelayStart:init_impl(step)
    self.is_start = true
    if GuideConst.gameInst and GuideConst.gameInst._runTime then
        self.start_time = GuideConst.gameInst._runTime
    end
end

function ConditionDelayStart:check_start_impl(step)
    if not self.start_time then
        if GuideConst.gameInst and GuideConst.gameInst._runTime then
            self.start_time = GuideConst.gameInst._runTime
        end
    end
    return self.start_time and GuideConst.gameInst._runTime - self.start_time >= self.time
end

return ConditionDelayStart