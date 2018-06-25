local ConditionDelayStart = class("ConditionDelayStart")

function ConditionDelayStart:ctor(time)
    self.time = time
    self.is_start = false
end

function ConditionDelayStart:check_start_impl(step)
    return self.time and self.time <= 0
end

function ConditionDelayStart:update_impl(step , dt)
    if self.time then
        self.time = self.time - dt
    end
end

return ConditionDelayStart