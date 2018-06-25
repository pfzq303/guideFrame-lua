local ActionGuideStart = class("ActionGuideStart")

function ActionGuideStart:ctor(args , text)
    self.args = clone(args)
    self.path = text
end

function ActionGuideStart:start_impl(step , ...)
    if not self.args.isFinish and self.args.id then
        guideMgr:add_group_by_config_id(self.args.id)
    end
end

function ActionGuideStart:finish_impl(step , ...)
    if self.args.isFinish and self.args.id then
        guideMgr:add_group_by_config_id(self.args.id)
    end
end

return ActionGuideStart