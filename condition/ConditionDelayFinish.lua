local ConditionDelayFinish = class("ConditionDelayFinish")

function ConditionDelayFinish:ctor(time)
    self.time = time
    self.is_start = false
end

function ConditionDelayFinish:check_finish_impl(step)
    self.is_start = true
    return self.time and self.time <= 0
end

function ConditionDelayFinish:update_impl(step , dt)
    if self.is_start and self.time then
        self.time = self.time - dt
    end
end

return ConditionDelayFinish