local ActionGuideLock = class("ActionGuideLock")
local GuideStep = packMgr:addPackage("app.guide.GuideStep")
function ActionGuideLock:ctor(args , text, action_index)
    self.action_index = action_index
end

function ActionGuideLock:start_impl(step , ...)
    print("Lock Guide:" , self.action_index)
    GuideStep.lock()
    self.islock = true
    self.lockTime = self.args.lockTime
end

function ActionGuideLock:unlock()
    print("unLock Guide:" , self.action_index)
    if self.islock then
        GuideStep.unlock()
        self.islock = nil
    end
end

function ActionGuideLock:finish_impl(step , ...)
    self:unlock()
end

function ActionGuideLock:update_impl(step , dt)
    if self.lockTime then
        self.lockTime = self.lockTime - dt
        if self.lockTime <= 0 then
            self:unlock()
        end
    end
end

return ActionGuideLock